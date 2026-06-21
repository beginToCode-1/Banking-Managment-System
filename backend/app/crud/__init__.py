from app.crud.user import get_user, get_user_by_email, create_user, create_employee, get_users_by_role, update_user_status
from app.crud.account import get_account, get_account_by_number, get_user_accounts, create_account
from app.crud.transaction import get_account_transactions, get_all_transactions, make_deposit, make_withdrawal, make_transfer
from app.crud.loan import get_loan, get_user_loans, get_pending_loans, create_loan, update_loan_status
from app.crud.notification import get_user_notifications, create_notification, mark_notification_as_read
