import datetime
from sqlalchemy import String, DateTime, ForeignKey, JSON
from sqlalchemy.orm import Mapped, mapped_column, relationship
from sqlalchemy.sql import func
from app.database import Base

class TravelPlan(Base):
    __tablename__ = "travel_plans"

    id: Mapped[str] = mapped_column(String, primary_key=True, index=True)
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id"), index=True)
    destination: Mapped[str] = mapped_column(String(100), nullable=False)
    start_date: Mapped[str] = mapped_column(String(50), nullable=False)
    end_date: Mapped[str] = mapped_column(String(50), nullable=False)
    purpose: Mapped[str] = mapped_column(String(100), nullable=False)
    
    itinerary: Mapped[dict] = mapped_column(JSON, nullable=False)
    
    created_at: Mapped[datetime.datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())

    user = relationship("User", back_populates="travel_plans")
