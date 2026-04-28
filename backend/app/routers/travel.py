from typing import Annotated
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
import uuid

from app.database import get_db
from app.models.user import User
from app.models.travel import TravelPlan
from app.models.clothing_item import ClothingItem
from app.schemas.travel import TravelPlan as TravelPlanSchema, TravelPlanCreate
from app.utils.deps import get_current_user
from app.services.vision_service import generate_travel_pack

router = APIRouter()

@router.post("/generate", response_model=TravelPlanSchema)
async def create_and_generate_travel_plan(
    request: TravelPlanCreate,
    is_hijab: bool = False,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    # Kullanıcının dolabını çek
    result = await db.execute(select(ClothingItem).where(ClothingItem.user_id == current_user.id))
    clothing_items = result.scalars().all()
    
    wardrobe = []
    for item in clothing_items:
        wardrobe.append({
            "id": item.id,
            "name": item.name,
            "category": item.category,
            "color": item.color
        })
        
    # AI ile Valiz Planı oluştur
    ai_result = generate_travel_pack(
        wardrobe_items=wardrobe,
        destination=request.destination,
        start_date=request.start_date,
        end_date=request.end_date,
        purpose=request.purpose,
        is_hijab=is_hijab
    )
    
    if "error" in ai_result:
        raise HTTPException(status_code=500, detail=ai_result["error"])
        
    # Veritabanına kaydet
    plan_id = str(uuid.uuid4())
    new_plan = TravelPlan(
        id=plan_id,
        user_id=current_user.id,
        destination=request.destination,
        start_date=request.start_date,
        end_date=request.end_date,
        purpose=request.purpose,
        itinerary=ai_result
    )
    
    db.add(new_plan)
    await db.commit()
    await db.refresh(new_plan)
    
    return new_plan

@router.get("/", response_model=list[TravelPlanSchema])
async def get_travel_plans(db: AsyncSession = Depends(get_db), current_user: User = Depends(get_current_user)):
    result = await db.execute(select(TravelPlan).where(TravelPlan.user_id == current_user.id).order_by(TravelPlan.created_at.desc()))
    plans = result.scalars().all()
    return plans

@router.delete("/{plan_id}")
async def delete_travel_plan(plan_id: str, db: AsyncSession = Depends(get_db), current_user: User = Depends(get_current_user)):
    result = await db.execute(select(TravelPlan).where(TravelPlan.id == plan_id, TravelPlan.user_id == current_user.id))
    plan = result.scalars().first()
    
    if not plan:
        raise HTTPException(status_code=404, detail="Travel plan not found")
        
    await db.delete(plan)
    await db.commit()
    return {"message": "Successfully deleted"}
