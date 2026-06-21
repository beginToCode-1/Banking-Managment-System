from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List

from app.core import deps
from app.crud import account as crud_account
from app.crud import transaction as crud_tx
from app.crud import loan as crud_loan
from app.crud import notification as crud_notif
from app.schemas import account as schema_acc
from app.schemas import transaction as schema_tx
from app.schemas import loan as schema_loan
from app.schemas import notification as schema_notif
from app.models.user import User
from app.models.notification import Notification

router = APIRouter()

# Customer role permission checker
customer_checker = deps.RoleChecker(allowed_roles=["customer"])

@router.get("/accounts", response_model=List[schema_acc.AccountResponse])
def get_my_accounts(
    db: Session = Depends(deps.get_db),
    current_user: User = Depends(customer_checker)
):
    """Retrieve all accounts owned by the current customer."""
    return crud_account.get_user_accounts(db, user_id=current_user.id)

@router.post("/accounts", response_model=schema_acc.AccountResponse, status_code=status.HTTP_201_CREATED)
def create_my_account(
    account_in: schema_acc.AccountCreate,
    db: Session = Depends(deps.get_db),
    current_user: User = Depends(customer_checker)
):
    """Create a new checking/savings account for the current customer (limit 5)."""
    existing = crud_account.get_user_accounts(db, user_id=current_user.id)
    if len(existing) >= 5:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Maximum limit of 5 accounts reached"
        )
    return crud_account.create_account(db, user_id=current_user.id, account=account_in)

@router.get("/accounts/{account_id}/transactions", response_model=List[schema_tx.TransactionResponse])
def get_my_account_transactions(
    account_id: int,
    db: Session = Depends(deps.get_db),
    current_user: User = Depends(customer_checker)
):
    """Fetch transaction history for a specific account owned by the customer."""
    account = crud_account.get_account(db, account_id=account_id)
    if not account or account.user_id != current_user.id:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Account not found or access denied"
        )
    return crud_tx.get_account_transactions(db, account_id=account_id)

@router.post("/transactions/deposit", response_model=schema_tx.TransactionResponse)
def deposit(
    req: schema_tx.DepositWithdrawRequest,
    db: Session = Depends(deps.get_db),
    current_user: User = Depends(customer_checker)
):
    """Deposit funds into an account owned by the current customer."""
    account = crud_account.get_account(db, req.account_id)
    if not account or account.user_id != current_user.id:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Account not found or access denied"
        )
    
    tx = crud_tx.make_deposit(db, account_id=req.account_id, amount=req.amount, description=req.description)
    crud_notif.create_notification(
        db,
        user_id=current_user.id,
        title="Deposit Completed",
        message=f"Deposited ${req.amount:.2f} into account ...{account.account_number[-4:]}."
    )
    return tx

@router.post("/transactions/withdraw", response_model=schema_tx.TransactionResponse)
def withdraw(
    req: schema_tx.DepositWithdrawRequest,
    db: Session = Depends(deps.get_db),
    current_user: User = Depends(customer_checker)
):
    """Withdraw funds from an account owned by the current customer, checking balance limit."""
    account = crud_account.get_account(db, req.account_id)
    if not account or account.user_id != current_user.id:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Account not found or access denied"
        )
    
    tx = crud_tx.make_withdrawal(db, account_id=req.account_id, amount=req.amount, description=req.description)
    crud_notif.create_notification(
        db,
        user_id=current_user.id,
        title="Withdrawal Completed",
        message=f"Withdrew ${req.amount:.2f} from account ...{account.account_number[-4:]}."
    )
    return tx

@router.post("/transactions/transfer", response_model=schema_tx.TransactionResponse)
def transfer(
    req: schema_tx.TransferRequest,
    db: Session = Depends(deps.get_db),
    current_user: User = Depends(customer_checker)
):
    """Transfer funds from customer's account to any destination account ending in unique account number."""
    sender_account = crud_account.get_account(db, req.sender_account_id)
    if not sender_account or sender_account.user_id != current_user.id:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Sender account not found or access denied"
        )
    
    receiver_account = crud_account.get_account_by_number(db, req.receiver_account_number)
    if not receiver_account:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Receiver account not found"
        )
        
    tx = crud_tx.make_transfer(
        db,
        sender_id=req.sender_account_id,
        receiver_number=req.receiver_account_number,
        amount=req.amount,
        description=req.description
    )
    
    # Notify sender
    crud_notif.create_notification(
        db,
        user_id=current_user.id,
        title="Transfer Dispatched",
        message=f"Sent ${req.amount:.2f} to account ...{req.receiver_account_number[-4:]}."
    )
    # Notify receiver
    crud_notif.create_notification(
        db,
        user_id=receiver_account.user_id,
        title="Transfer Received",
        message=f"Received ${req.amount:.2f} from {current_user.name} into account ...{receiver_account.account_number[-4:]}."
    )
    return tx

@router.post("/loans/apply", response_model=schema_loan.LoanResponse)
def apply_for_loan(
    loan_in: schema_loan.LoanCreate,
    db: Session = Depends(deps.get_db),
    current_user: User = Depends(customer_checker)
):
    """Apply for a banking loan. Customers can only have one pending loan application at a time."""
    loans = crud_loan.get_user_loans(db, customer_id=current_user.id)
    if any(l.status == "pending" for l in loans):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="You already have a pending loan application under review"
        )
        
    loan = crud_loan.create_loan(db, customer_id=current_user.id, loan=loan_in)
    crud_notif.create_notification(
        db,
        user_id=current_user.id,
        title="Loan Application Submitted",
        message=f"Your loan request of ${loan_in.amount:.2f} has been submitted for review."
    )
    return loan

@router.get("/loans", response_model=List[schema_loan.LoanResponse])
def get_my_loans(
    db: Session = Depends(deps.get_db),
    current_user: User = Depends(customer_checker)
):
    """Retrieve all loan applications and statuses filed by the customer."""
    return crud_loan.get_user_loans(db, customer_id=current_user.id)

@router.get("/notifications", response_model=List[schema_notif.NotificationResponse])
def get_my_notifications(
    db: Session = Depends(deps.get_db),
    current_user: User = Depends(customer_checker)
):
    """Retrieve all notifications received by the customer."""
    return crud_notif.get_user_notifications(db, user_id=current_user.id)

@router.put("/notifications/{notification_id}/read", response_model=schema_notif.NotificationResponse)
def read_notification(
    notification_id: int,
    db: Session = Depends(deps.get_db),
    current_user: User = Depends(customer_checker)
):
    """Mark a user notification as read."""
    db_notif = db.query(Notification).filter(Notification.id == notification_id).first()
    if not db_notif or db_notif.user_id != current_user.id:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Notification not found"
        )
    return crud_notif.mark_notification_as_read(db, notification_id)
