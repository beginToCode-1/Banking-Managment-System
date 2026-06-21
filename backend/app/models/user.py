from sqlalchemy import Column, Integer, String, DateTime
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship
from app.database import Base

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=False)
    email = Column(String, unique=True, index=True, nullable=False)
    password_hash = Column(String, nullable=False)
    role = Column(String, default="customer")  # "admin", "employee", "customer"
    status = Column(String, default="active")  # "active", "pending", "suspended"
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    accounts = relationship("Account", back_populates="owner", cascade="all, delete-orphan")
    loans = relationship("Loan", foreign_keys="[Loan.customer_id]", back_populates="customer", cascade="all, delete-orphan")
