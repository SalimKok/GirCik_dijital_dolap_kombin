from typing import Optional, Dict, Any
from pydantic import BaseModel
from datetime import datetime

class TravelPlanCreate(BaseModel):
    destination: str
    start_date: str
    end_date: str
    purpose: str

class TravelPlan(BaseModel):
    id: str
    user_id: int
    destination: str
    start_date: str
    end_date: str
    purpose: str
    itinerary: Dict[str, Any]
    created_at: datetime

    class Config:
        from_attributes = True
