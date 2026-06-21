from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from sqlalchemy import func
from typing import List

from app.core import deps
from app.crud import user as crud_user
from app.crud import transaction as crud_tx
from app.schemas import user as schema_user
from app.schemas import transaction as schema_tx
from app.models.user import User
from app.models.account import Account
from app.models.loan import Loan
from app.models.transaction import Transaction

router = APIRouter()

admin_checker = deps.RoleChecker(allowed_roles=["admin"])

@router.get("/dashboard-stats")
def get_dashboard_stats(
    db: Session = Depends(deps.get_db),
    current_user: User = Depends(admin_checker)
):
    """Retrieve global statistics of the bank."""
    total_users = db.query(User).count()
    total_customers = db.query(User).filter(User.role == "customer").count()
    total_employees = db.query(User).filter(User.role == "employee").count()

    total_deposits_result = db.query(func.sum(Account.balance)).scalar()
    total_deposits = float(total_deposits_result) if total_deposits_result else 0.0

    total_transactions = db.query(Transaction).count()

    total_loans_result = db.query(func.sum(Loan.amount)).filter(Loan.status == "approved").scalar()
    active_loans_volume = float(total_loans_result) if total_loans_result else 0.0
    pending_loans_count = db.query(Loan).filter(Loan.status == "pending").count()

    return {
        "total_users": total_users,
        "total_customers": total_customers,
        "total_employees": total_employees,
        "total_deposits": total_deposits,
        "total_transactions": total_transactions,
        "active_loans_volume": active_loans_volume,
        "pending_loans_count": pending_loans_count
    }

@router.post("/employees", response_model=schema_user.UserResponse, status_code=status.HTTP_201_CREATED)
def create_new_employee(
    employee_in: schema_user.EmployeeCreate,
    db: Session = Depends(deps.get_db),
    current_user: User = Depends(admin_checker)
):
    """Create a new employee user account."""
    db_user = crud_user.get_user_by_email(db, email=employee_in.email)
    if db_user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="A user with this email already exists"
        )
    return crud_user.create_employee(db, employee_in)

@router.get("/employees", response_model=List[schema_user.UserResponse])
def list_employees(
    db: Session = Depends(deps.get_db),
    current_user: User = Depends(admin_checker)
):
    """List all registered employee accounts."""
    return crud_user.get_users_by_role(db, role="employee")

@router.get("/transactions", response_model=List[schema_tx.TransactionResponse])
def get_all_transactions(
    db: Session = Depends(deps.get_db),
    current_user: User = Depends(admin_checker)
):
    """List all system-wide transactions for auditing."""
    return crud_tx.get_all_transactions(db)
