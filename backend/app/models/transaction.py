from sqlalchemy import Column, Integer, String, Float, ForeignKey, DateTime
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship
from app.database import Base

class Transaction(Base):
    __tablename__ = "transactions"

    id = Column(Integer, primary_key=True, index=True)
    sender_account_id = Column(Integer, ForeignKey("accounts.id", ondelete="SET NULL"), nullable=True)
    receiver_account_id = Column(Integer, ForeignKey("accounts.id", ondelete="SET NULL"), nullable=True)
    amount = Column(Float, nullable=False)
    type = Column(String, nullable=False)  # "deposit", "withdraw", "transfer"
    status = Column(String, default="completed")  # "completed", "failed", "pending"
    description = Column(String, nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    sender_account = relationship("Account", foreign_keys=[sender_account_id], back_populates="debits")
    receiver_account = relationship("Account", foreign_keys=[receiver_account_id], back_populates="credits")
