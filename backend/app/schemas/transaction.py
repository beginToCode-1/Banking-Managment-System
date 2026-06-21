from datetime import datetime
from pydantic import BaseModel, Field
from typing import Optional

class TransactionBase(BaseModel):
    amount: float = Field(..., gt=0, description="Amount must be greater than zero")
    description: Optional[str] = None

class DepositWithdrawRequest(TransactionBase):
    account_id: int

class TransferRequest(TransactionBase):
    sender_account_id: int
    receiver_account_number: str

class TransactionResponse(BaseModel):
    id: int
    sender_account_id: Optional[int] = None
    receiver_account_id: Optional[int] = None
    amount: float
    type: str
    status: str
    description: Optional[str] = None
    created_at: datetime

    class Config:
        from_attributes = True
