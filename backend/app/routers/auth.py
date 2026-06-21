from fastapi import APIRouter, Depends, HTTPException, status, Request
from sqlalchemy.orm import Session
from app.core import security, deps
from app.crud import user as crud_user
from app.crud import account as crud_account
from app.crud import notification as crud_notif
from app.schemas import user as schema_user
from app.schemas import auth as schema_auth
from app.schemas import account as schema_acc

router = APIRouter()

@router.post("/register", response_model=schema_user.UserResponse, status_code=status.HTTP_201_CREATED)
def register(user_in: schema_user.UserCreate, db: Session = Depends(deps.get_db)):
    """Register a new customer and auto-create a default savings account."""
    db_user = crud_user.get_user_by_email(db, email=user_in.email)
    if db_user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="A user with this email already exists"
        )
    new_user = crud_user.create_user(db, user_in)
    
    # Auto-create standard Savings account
    crud_account.create_account(
        db, 
        user_id=new_user.id, 
        account=schema_acc.AccountCreate(account_type="savings")
    )
    
    # Send registration notification
    crud_notif.create_notification(
        db,
        user_id=new_user.id,
        title="Welcome to SmartBank!",
        message=f"Hi {new_user.name}, your account is active. We have created a default Savings account for you."
    )
    return new_user

@router.post("/login", response_model=schema_auth.Token)
async def login(request: Request, db: Session = Depends(deps.get_db)):
    """Login endpoint supporting both application/json and application/x-www-form-urlencoded inputs."""
    content_type = request.headers.get("content-type", "")
    email = None
    password = None

    if "application/json" in content_type:
        try:
            body = await request.json()
            email = body.get("email") or body.get("username")
            password = body.get("password")
        except Exception:
            raise HTTPException(status_code=400, detail="Invalid JSON body")
    else:
        try:
            form = await request.form()
            email = form.get("username") or form.get("email")
            password = form.get("password")
        except Exception:
            raise HTTPException(status_code=400, detail="Invalid form body")

    if not email or not password:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Email/username and password are required"
        )

    user = crud_user.get_user_by_email(db, email=email)
    if not user or not security.verify_password(password, user.password_hash):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Incorrect email or password"
        )
    
    if user.status != "active":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Your account is currently inactive or suspended"
        )

    access_token = security.create_access_token(subject=user.id)
    return {"access_token": access_token, "token_type": "bearer"}

@router.get("/me", response_model=schema_user.UserResponse)
def read_current_user(current_user: deps.User = Depends(deps.get_current_user)):
    """Fetch profile details of the currently authenticated user."""
    return current_user
