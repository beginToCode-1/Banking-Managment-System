from sqlalchemy.orm import Session
from app.models.notification import Notification

def get_user_notifications(db: Session, user_id: int):
    """Retrieve all notifications for a specific user, sorted by date."""
    return db.query(Notification).filter(Notification.user_id == user_id).order_by(Notification.created_at.desc()).all()

def create_notification(db: Session, user_id: int, title: str, message: str) -> Notification:
    """Create a new notification entry for a user."""
    db_notif = Notification(
        user_id=user_id,
        title=title,
        message=message,
        is_read=False
    )
    db.add(db_notif)
    db.commit()
    db.refresh(db_notif)
    return db_notif

def mark_notification_as_read(db: Session, notification_id: int) -> Notification:
    """Mark a specific notification as read."""
    db_notif = db.query(Notification).filter(Notification.id == notification_id).first()
    if db_notif:
        db_notif.is_read = True
        db.commit()
        db.refresh(db_notif)
    return db_notif
