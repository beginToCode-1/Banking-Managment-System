from sqlalchemy.orm import Session
from app.models.loan import Loan
from app.schemas.loan import LoanCreate

def get_loan(db: Session, loan_id: int):
    """Retrieve loan by database ID."""
    return db.query(Loan).filter(Loan.id == loan_id).first()

def get_user_loans(db: Session, customer_id: int):
    """Get all loans requested by a customer."""
    return db.query(Loan).filter(Loan.customer_id == customer_id).all()

def get_pending_loans(db: Session):
    """Get all loans that are currently pending audit."""
    return db.query(Loan).filter(Loan.status == "pending").all()

def create_loan(db: Session, customer_id: int, loan: LoanCreate) -> Loan:
    """Submit a new loan application."""
    # Fixed standard 5.5% interest rate for bank loans
    interest_rate = 5.5
    db_loan = Loan(
        customer_id=customer_id,
        amount=loan.amount,
        interest_rate=interest_rate,
        term_months=loan.term_months,
        status="pending"
    )
    db.add(db_loan)
    db.commit()
    db.refresh(db_loan)
    return db_loan

def update_loan_status(db: Session, loan: Loan, status: str, employee_id: int) -> Loan:
    """Approve or reject a loan application."""
    loan.status = status
    if status == "approved":
        loan.approved_by_employee_id = employee_id
    db.commit()
    db.refresh(loan)
    return loan
