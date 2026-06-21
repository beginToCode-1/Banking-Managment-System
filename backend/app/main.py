from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.database import engine, Base, SessionLocal
from app.models.user import User
from app.core import security
from app.routers import auth, customer, employee, admin

# Auto-create SQLite database tables if they do not exist
Base.metadata.create_all(bind=engine)

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup actions: Seed default system administrator account
    db = SessionLocal()
    try:
        admin_email = "admin@smartbank.com"
        admin_user = db.query(User).filter(User.email == admin_email).first()
        if not admin_user:
            hashed_pwd = security.get_password_hash("adminpassword123")
            new_admin = User(
                name="System Administrator",
                email=admin_email,
                password_hash=hashed_pwd,
                role="admin",
                status="active"
            )
            db.add(new_admin)
            db.commit()
            print("SmartBank Startup: Default admin user seeded successfully (admin@smartbank.com / adminpassword123)")
    except Exception as err:
        print(f"SmartBank Startup: Admin seeding failed: {err}")
    finally:
        db.close()
    yield
    # Shutdown actions (if any)

app = FastAPI(
    title="SmartBank API",
    description="Robust backend for the SmartBank Digital Banking Management System",
    version="1.0.0",
    lifespan=lifespan
)

# Configure CORS for Flutter client communication (mobile, web, desktop)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
def read_root():
    return {
        "status": "online",
        "message": "SmartBank API is running. View API specs at /docs"
    }

# Include routing divisions
app.include_router(auth.router, prefix="/api/auth", tags=["Authentication"])
app.include_router(customer.router, prefix="/api/customer", tags=["Customer Operations"])
app.include_router(employee.router, prefix="/api/employee", tags=["Employee Operations"])
app.include_router(admin.router, prefix="/api/admin", tags=["Admin Operations"])
