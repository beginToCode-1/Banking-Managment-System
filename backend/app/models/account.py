from sqlalchemy import Column, Integer, String, Float, ForeignKey, DateTime
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship
from app.database import Base

class Account(Base):
    __tablename__ = "accounts"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    account_number = Column(String, unique=True, index=True, nullable=False)
    balance = Column(Float, default=0.0, nullable=False)
    account_type = Column(String, default="savings")  # "savings", "checking"
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    owner = relationship("User", back_populates="accounts")
    
    # We reference the debit (sender) and credit (receiver) transactions.
    debits = relationship(
        "Transaction",
        foreign_keys="[Transaction.sender_account_id]",
        back_populates="sender_account",
        cascade="all, delete-orphan"
    )
    credits = relationship(
        "Transaction",
        foreign_keys="[Transaction.receiver_account_id]",
        back_populates="receiver_account",
        cascade="all, delete-orphan"
    )
