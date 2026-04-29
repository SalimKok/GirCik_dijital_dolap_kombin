from datetime import timedelta
from typing import Annotated
from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordRequestForm
from sqlalchemy.ext.asyncio import AsyncSession

from app.database import get_db
from app.schemas.user import User, UserCreate, UserUpdate, UserFCMUpdate
from app.schemas.token import Token
from app.services import auth_service, notification_service
from app.utils.security import verify_password, create_access_token
from app.utils.deps import get_current_user

router = APIRouter()

@router.post("/register", response_model=User)
async def register(
    user_in: UserCreate, 
    db: Annotated[AsyncSession, Depends(get_db)]
):
    user = await auth_service.get_user_by_email(db, email=user_in.email)
    if user:
        raise HTTPException(
            status_code=400,
            detail="The user with this user name already exists in the system.",
        )
    user = await auth_service.create_user(db, user_in=user_in)
    return user

@router.post("/login", response_model=Token)
async def login_access_token(
    db: Annotated[AsyncSession, Depends(get_db)],
    form_data: Annotated[OAuth2PasswordRequestForm, Depends()]
) -> Token:
    """OAuth2 compatible token login, get an access token for future requests"""
    user = await auth_service.get_user_by_email(db, email=form_data.username)
    if not user or not verify_password(form_data.password, user.hashed_password):
        raise HTTPException(status_code=400, detail="Incorrect email or password")
    
    access_token = create_access_token(subject=user.id)
    return Token(access_token=access_token, token_type="bearer")

@router.get("/me", response_model=User)
async def read_users_me(
    current_user: Annotated[User, Depends(get_current_user)]
) -> User:
    return current_user

@router.put("/me", response_model=User)
async def update_user_me(
    user_in: UserUpdate,
    db: Annotated[AsyncSession, Depends(get_db)],
    current_user: Annotated[User, Depends(get_current_user)]
) -> User:
    return await auth_service.update_user(db, db_user=current_user, user_in=user_in)

@router.put("/me/fcm-token", response_model=dict)
async def update_fcm_token(
    fcm_in: UserFCMUpdate,
    db: Annotated[AsyncSession, Depends(get_db)],
    current_user: Annotated[User, Depends(get_current_user)]
):
    await auth_service.update_fcm_token(db, db_user=current_user, token=fcm_in.fcm_token)
    return {"status": "success"}

@router.post("/test-notification")
async def test_notification(
    current_user: Annotated[User, Depends(get_current_user)]
):
    if not current_user.fcm_token:
        raise HTTPException(status_code=400, detail="Kullanıcının FCM token'ı bulunamadı.")
    
    notification_service.send_push_notification(
        token=current_user.fcm_token,
        title="GiyÇık Test 🚀",
        body="Harika! Bildirim sistemin kusursuz çalışıyor.",
        data={"type": "test_message"}
    )
    return {"status": "success", "message": "Test bildirimi gönderildi."}

@router.delete("/me")
async def delete_user_me(
    db: Annotated[AsyncSession, Depends(get_db)],
    current_user: Annotated[User, Depends(get_current_user)]
) -> dict:
    await auth_service.delete_user(db, db_user=current_user)
    return {"status": "success"}
