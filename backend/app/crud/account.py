import random
from sqlalchemy.orm import Session
from app.models.account import Account
from app.schemas.account import AccountCreate

def get_account(db: Session, account_id: int):
    """Retrieve an account by its ID."""
    return db.query(Account).filter(Account.id == account_id).first()

def get_account_by_number(db: Session, account_number: str):
    """Retrieve an account by its unique 10-digit number."""
    return db.query(Account).filter(Account.account_number == account_number).first()

def get_user_accounts(db: Session, user_id: int):
    """Get all accounts owned by a user."""
    return db.query(Account).filter(Account.user_id == user_id).all()

def generate_unique_account_number(db: Session) -> str:
    """Generate a unique 10-digit banking account number."""
    while True:
        num = "".join([str(random.randint(0, 9)) for _ in range(10)])
        exists = db.query(Account).filter(Account.account_number == num).first()
        if not exists:
            return num

def create_account(db: Session, user_id: int, account: AccountCreate) -> Account:
    """Create a new checking or savings account with a zero balance."""
    acc_num = generate_unique_account_number(db)
    db_account = Account(
        user_id=user_id,
        account_number=acc_num,
        account_type=account.account_type,
        balance=0.0
    )
    db.add(db_account)
    db.commit()
    db.refresh(db_account)
    return db_account
