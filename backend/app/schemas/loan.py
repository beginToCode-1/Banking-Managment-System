from datetime import datetime
from pydantic import BaseModel, Field
from typing import Optional

class LoanBase(BaseModel):
    amount: float = Field(..., gt=0, description="Loan amount must be greater than zero")
    term_months: int = Field(..., gt=0, description="Term must be at least 1 month")

class LoanCreate(LoanBase):
    pass

class LoanReview(BaseModel):
    status: str  # "approved" or "rejected"

class LoanResponse(LoanBase):
    id: int
    customer_id: int
    interest_rate: float
    status: str
    approved_by_employee_id: Optional[int] = None
    created_at: datetime

    class Config:
        from_attributes = True
