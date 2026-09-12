from typing import Dict, Any
from fastapi import APIRouter, Depends, HTTPException, status
from app.core.security import get_current_user
from app.models.schemas import UserProfileResponse
from app.services.profile_service import profile_service

router = APIRouter()


@router.get("/profile/{user_id}", response_model=UserProfileResponse)
async def get_user_profile(
    user_id: str,
    current_user: Dict[str, Any] = Depends(get_current_user),
):
    """
    Retrieve user profile for the given Firebase user_id.
    Protected endpoint requiring valid Firebase ID token.
    """
    token_uid = current_user.get("uid")

    # Ensure user is accessing their own profile (or dev mode match)
    if token_uid != user_id and token_uid != "dev_user_001":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Access forbidden: cannot view profile of another user",
        )

    profile = await profile_service.get_user_profile(
        user_id=user_id,
        email_hint=current_user.get("email"),
    )
    return profile
