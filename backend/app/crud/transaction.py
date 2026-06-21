from sqlalchemy.orm import Session
from sqlalchemy import or_
from app.models.account import Account
from app.models.transaction import Transaction
from fastapi import HTTPException, status

def get_account_transactions(db: Session, account_id: int):
    """Retrieve all transactions involving a specific account."""
    return db.query(Transaction).filter(
        or_(
            Transaction.sender_account_id == account_id,
            Transaction.receiver_account_id == account_id
        )
    ).order_by(Transaction.created_at.desc()).all()

def get_all_transactions(db: Session):
    """Retrieve all transactions system-wide (for Admin oversight)."""
    return db.query(Transaction).order_by(Transaction.created_at.desc()).all()

def make_deposit(db: Session, account_id: int, amount: float, description: str = None) -> Transaction:
    """Safely deposit money into an account."""
    account = db.query(Account).filter(Account.id == account_id).first()
    if not account:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Account not found")
    
    account.balance += amount
    db_tx = Transaction(
        sender_account_id=None,
        receiver_account_id=account.id,
        amount=amount,
        type="deposit",
        status="completed",
        description=description or "Cash Deposit"
    )
    db.add(db_tx)
    db.commit()
    db.refresh(db_tx)
    return db_tx

def make_withdrawal(db: Session, account_id: int, amount: float, description: str = None) -> Transaction:
    """Safely withdraw money from an account, validating balance."""
    account = db.query(Account).filter(Account.id == account_id).first()
    if not account:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Account not found")
    
    if account.balance < amount:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Insufficient funds"
        )
    
    account.balance -= amount
    db_tx = Transaction(
        sender_account_id=account.id,
        receiver_account_id=None,
        amount=amount,
        type="withdraw",
        status="completed",
        description=description or "Cash Withdrawal"
    )
    db.add(db_tx)
    db.commit()
    db.refresh(db_tx)
    return db_tx

def make_transfer(db: Session, sender_id: int, receiver_number: str, amount: float, description: str = None) -> Transaction:
    """Safely transfer money between accounts, validating balance and enforcing transaction safety."""
    sender = db.query(Account).filter(Account.id == sender_id).first()
    if not sender:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Sender account not found")
    
    receiver = db.query(Account).filter(Account.account_number == receiver_number).first()
    if not receiver:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Receiver account not found")
    
    if sender.id == receiver.id:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Cannot transfer to the same account")

    if sender.balance < amount:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Insufficient funds")
    
    # Transfer balances
    sender.balance -= amount
    receiver.balance += amount

    db_tx = Transaction(
        sender_account_id=sender.id,
        receiver_account_id=receiver.id,
        amount=amount,
        type="transfer",
        status="completed",
        description=description or f"Transfer to {receiver_number}"
    )
    db.add(db_tx)
    db.commit()
    db.refresh(db_tx)
    return db_tx
