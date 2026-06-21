import os

# Enforce a separate test database environment variable before any imports
os.environ["DATABASE_URL"] = "sqlite:///./test_bank.db"

# Clear out previous test database if it exists
if os.path.exists("./test_bank.db"):
    try:
        os.remove("./test_bank.db")
    except Exception:
        pass

from fastapi.testclient import TestClient
from app.main import app
from app.database import Base, engine, SessionLocal
from app.models.user import User
from app.core import security

client = TestClient(app)

def test_banking_flow():
    # Seed admin user manually for the test runner
    db = SessionLocal()
    try:
        admin_email = "admin@smartbank.com"
        exists = db.query(User).filter(User.email == admin_email).first()
        if not exists:
            hashed_pwd = security.get_password_hash("adminpassword123")
            new_admin = User(
                name="System Administrator",
                email=admin_email,
                password_hash=hashed_pwd,
                role="admin",
                status="active"
            )
            db.add(new_admin)
            db.commit()
    finally:
        db.close()

    # -------------------------------------------------------------
    # 1. Root Check
    # -------------------------------------------------------------
    res = client.get("/")
    assert res.status_code == 200
    assert res.json()["status"] == "online"

    # -------------------------------------------------------------
    # 2. Registration & Default Account Seeding
    # -------------------------------------------------------------
    reg_payload = {
        "name": "Jane Customer",
        "email": "customer1@smartbank.com",
        "password": "customerpassword"
    }
    res = client.post("/api/auth/register", json=reg_payload)
    assert res.status_code == 201
    user_data = res.json()
    assert user_data["name"] == "Jane Customer"
    assert user_data["email"] == "customer1@smartbank.com"
    assert user_data["role"] == "customer"
    assert user_data["status"] == "active"

    # -------------------------------------------------------------
    # 3. Login (Customer & Seeded Admin)
    # -------------------------------------------------------------
    # Customer login
    res = client.post("/api/auth/login", json={
        "username": "customer1@smartbank.com",
        "password": "customerpassword"
    })
    assert res.status_code == 200
    customer_token = res.json()["access_token"]
    cust_headers = {"Authorization": f"Bearer {customer_token}"}

    # Admin login (using default seeded admin)
    res = client.post("/api/auth/login", json={
        "username": "admin@smartbank.com",
        "password": "adminpassword123"
    })
    assert res.status_code == 200
    admin_token = res.json()["access_token"]
    admin_headers = {"Authorization": f"Bearer {admin_token}"}

    # Verify Current User
    res = client.get("/api/auth/me", headers=cust_headers)
    assert res.status_code == 200
    assert res.json()["email"] == "customer1@smartbank.com"

    # -------------------------------------------------------------
    # 4. Admin Creates Employee
    # -------------------------------------------------------------
    emp_payload = {
        "name": "John Employee",
        "email": "employee1@smartbank.com",
        "password": "employeepassword"
    }
    res = client.post("/api/admin/employees", json=emp_payload, headers=admin_headers)
    assert res.status_code == 201
    assert res.json()["role"] == "employee"

    # Employee Login
    res = client.post("/api/auth/login", json={
        "username": "employee1@smartbank.com",
        "password": "employeepassword"
    })
    assert res.status_code == 200
    employee_token = res.json()["access_token"]
    emp_headers = {"Authorization": f"Bearer {employee_token}"}

    # -------------------------------------------------------------
    # 5. Accounts Management
    # -------------------------------------------------------------
    # Check default account created during registration
    res = client.get("/api/customer/accounts", headers=cust_headers)
    assert res.status_code == 200
    accounts = res.json()
    assert len(accounts) == 1
    savings_account = accounts[0]
    assert savings_account["account_type"] == "savings"
    assert savings_account["balance"] == 0.0
    savings_account_id = savings_account["id"]
    savings_account_num = savings_account["account_number"]

    # Create a secondary Checking Account
    res = client.post("/api/customer/accounts", json={"account_type": "checking"}, headers=cust_headers)
    assert res.status_code == 201
    checking_account = res.json()
    assert checking_account["account_type"] == "checking"
    checking_account_id = checking_account["id"]
    checking_account_num = checking_account["account_number"]

    # -------------------------------------------------------------
    # 6. Money Transactions (Deposit, Withdraw, Transfer)
    # -------------------------------------------------------------
    # Deposit $1500 into Savings account
    res = client.post("/api/customer/transactions/deposit", json={
        "account_id": savings_account_id,
        "amount": 1500.00,
        "description": "Initial Savings deposit"
    }, headers=cust_headers)
    assert res.status_code == 200
    assert res.json()["type"] == "deposit"

    # Verify Balance
    res = client.get("/api/customer/accounts", headers=cust_headers)
    assert res.json()[0]["balance"] == 1500.00

    # Withdraw $200 from Savings account
    res = client.post("/api/customer/transactions/withdraw", json={
        "account_id": savings_account_id,
        "amount": 200.00,
        "description": "ATM withdrawal"
    }, headers=cust_headers)
    assert res.status_code == 200
    assert res.json()["type"] == "withdraw"

    # Verify Balance
    res = client.get("/api/customer/accounts", headers=cust_headers)
    assert res.json()[0]["balance"] == 1300.00

    # Transfer $400 from Savings account to Checking account
    res = client.post("/api/customer/transactions/transfer", json={
        "sender_account_id": savings_account_id,
        "receiver_account_number": checking_account_num,
        "amount": 400.00,
        "description": "Rent fund transfer"
    }, headers=cust_headers)
    assert res.status_code == 200
    assert res.json()["type"] == "transfer"

    # Verify Balances after Transfer
    res = client.get("/api/customer/accounts", headers=cust_headers)
    accts = {a["id"]: a["balance"] for a in res.json()}
    assert accts[savings_account_id] == 900.00
    assert accts[checking_account_id] == 400.00

    # -------------------------------------------------------------
    # 7. Loans Submission & Staff Audit
    # -------------------------------------------------------------
    # Apply for loan of $8000
    res = client.post("/api/customer/loans/apply", json={
        "amount": 8000.00,
        "term_months": 24
    }, headers=cust_headers)
    assert res.status_code == 200
    loan_id = res.json()["id"]
    assert res.json()["status"] == "pending"

    # Employee lists pending loans
    res = client.get("/api/employee/loans/pending", headers=emp_headers)
    assert res.status_code == 200
    assert len(res.json()) == 1
    assert res.json()[0]["id"] == loan_id

    # Employee approves the loan
    res = client.post(f"/api/employee/loans/{loan_id}/review", json={"status": "approved"}, headers=emp_headers)
    assert res.status_code == 200
    assert res.json()["status"] == "approved"

    # Verify Loan disbursement: Savings balance should now be $900 + $8000 = $8900
    res = client.get("/api/customer/accounts", headers=cust_headers)
    accts = {a["id"]: a["balance"] for a in res.json()}
    assert accts[savings_account_id] == 8900.00

    # -------------------------------------------------------------
    # 8. Notifications check
    # -------------------------------------------------------------
    res = client.get("/api/customer/notifications", headers=cust_headers)
    assert res.status_code == 200
    notifs = res.json()
    assert len(notifs) > 0
    # Read the newest notification
    latest_notif_id = notifs[0]["id"]
    res = client.put(f"/api/customer/notifications/{latest_notif_id}/read", headers=cust_headers)
    assert res.status_code == 200
    assert res.json()["is_read"] is True

    # -------------------------------------------------------------
    # 9. Admin Stats Check
    # -------------------------------------------------------------
    res = client.get("/api/admin/dashboard-stats", headers=admin_headers)
    assert res.status_code == 200
    stats = res.json()
    assert stats["total_users"] == 3  # Admin, Customer, Employee
    assert stats["total_customers"] == 1
    assert stats["total_employees"] == 1
    assert stats["total_deposits"] == 9300.00  # $8900 Savings + $400 Checking
    assert stats["active_loans_volume"] == 8000.00

    print("\n--- ALL BACKEND INTEGRATION TESTS PASSED SUCCESSFULLY! ---")

if __name__ == "__main__":
    test_banking_flow()
