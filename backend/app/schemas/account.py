from datetime import datetime
from pydantic import BaseModel

class AccountBase(BaseModel):
    account_type: str = "savings"  # "savings", "checking"

class AccountCreate(AccountBase):
    pass

class AccountResponse(AccountBase):
    id: int
    user_id: int
    account_number: str
    balance: float
    created_at: datetime

    class Config:
        from_attributes = True
