from sqlalchemy.orm import Session
from app.models.user import User
from app.schemas.user import UserCreate, EmployeeCreate
from app.core.security import get_password_hash

def get_user(db: Session, user_id: int):
    """Retrieve user by database ID."""
    return db.query(User).filter(User.id == user_id).first()

def get_user_by_email(db: Session, email: str):
    """Retrieve user by email address."""
    return db.query(User).filter(User.email == email).first()

def create_user(db: Session, user: UserCreate) -> User:
    """Create a new customer user."""
    hashed_pwd = get_password_hash(user.password)
    db_user = User(
        name=user.name,
        email=user.email,
        password_hash=hashed_pwd,
        role="customer",
        status="active"
    )
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    return db_user

def create_employee(db: Session, employee: EmployeeCreate) -> User:
    """Create a new employee user."""
    hashed_pwd = get_password_hash(employee.password)
    db_employee = User(
        name=employee.name,
        email=employee.email,
        password_hash=hashed_pwd,
        role="employee",
        status="active"
    )
    db.add(db_employee)
    db.commit()
    db.refresh(db_employee)
    return db_employee

def get_users_by_role(db: Session, role: str):
    """List all users of a specific role."""
    return db.query(User).filter(User.role == role).all()

def update_user_status(db: Session, user: User, status: str) -> User:
    """Activate or suspend a user account."""
    user.status = status
    db.commit()
    db.refresh(user)
    return user
