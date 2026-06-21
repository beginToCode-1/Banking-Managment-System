from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List

from app.core import deps
from app.crud import user as crud_user
from app.crud import loan as crud_loan
from app.crud import account as crud_account
from app.crud import transaction as crud_tx
from app.crud import notification as crud_notif
from app.schemas import user as schema_user
from app.schemas import loan as schema_loan
from app.models.user import User

router = APIRouter()

# Allow both Employee and Admin roles to access employee endpoints
employee_checker = deps.RoleChecker(allowed_roles=["employee", "admin"])

@router.get("/customers", response_model=List[schema_user.UserResponse])
def get_customers(
    db: Session = Depends(deps.get_db),
    current_user: User = Depends(employee_checker)
):
    """List all registered customers."""
    return crud_user.get_users_by_role(db, role="customer")

@router.get("/loans/pending", response_model=List[schema_loan.LoanResponse])
def get_pending_loans(
    db: Session = Depends(deps.get_db),
    current_user: User = Depends(employee_checker)
):
    """Retrieve all pending loan applications requiring employee review."""
    return crud_loan.get_pending_loans(db)

@router.post("/loans/{loan_id}/review", response_model=schema_loan.LoanResponse)
def review_loan(
    loan_id: int,
    review: schema_loan.LoanReview,
    db: Session = Depends(deps.get_db),
    current_user: User = Depends(employee_checker)
):
    """Review a pending loan. If approved, disbursement is automatically deposited into the customer's primary account."""
    loan = crud_loan.get_loan(db, loan_id=loan_id)
    if not loan:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Loan application not found"
        )
        
    if loan.status != "pending":
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Loan application has already been reviewed"
        )
        
    if review.status not in ["approved", "rejected"]:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid review status"
        )
        
    updated_loan = crud_loan.update_loan_status(db, loan=loan, status=review.status, employee_id=current_user.id)
    
    if review.status == "approved":
        customer_accounts = crud_account.get_user_accounts(db, user_id=loan.customer_id)
        if customer_accounts:
            # Disburse funds into their first account (Savings)
            target_acc = customer_accounts[0]
            crud_tx.make_deposit(
                db,
                account_id=target_acc.id,
                amount=loan.amount,
                description=f"Loan Approved Disbursement (Loan ID #{loan.id})"
            )
            crud_notif.create_notification(
                db,
                user_id=loan.customer_id,
                title="Loan Disbursed",
                message=f"Your loan request of ${loan.amount:.2f} was approved and deposited into account ending in ...{target_acc.account_number[-4:]}."
            )
        else:
            crud_notif.create_notification(
                db,
                user_id=loan.customer_id,
                title="Loan Approved",
                message=f"Your loan request of ${loan.amount:.2f} was approved. Create an active checking/savings account to process disbursement."
            )
    else:
        crud_notif.create_notification(
            db,
            user_id=loan.customer_id,
            title="Loan Application Rejected",
            message=f"Unfortunately, your loan request of ${loan.amount:.2f} was rejected."
        )
        
    return updated_loan

@router.put("/customers/{customer_id}/status", response_model=schema_user.UserResponse)
def change_customer_status(
    customer_id: int,
    status_update: schema_user.UserUpdate,
    db: Session = Depends(deps.get_db),
    current_user: User = Depends(employee_checker)
):
    """Change status of a customer (active/suspended)."""
    customer = crud_user.get_user(db, user_id=customer_id)
    if not customer or customer.role != "customer":
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Customer not found"
        )
        
    if not status_update.status or status_update.status not in ["active", "suspended"]:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid status parameter (must be 'active' or 'suspended')"
        )
        
    crud_user.update_user_status(db, user=customer, status=status_update.status)
    
    crud_notif.create_notification(
        db,
        user_id=customer_id,
        title="Account Status Changed",
        message=f"Your account status was updated to '{status_update.status}' by staff."
    )
    return customer
