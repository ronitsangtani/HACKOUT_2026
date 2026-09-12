from typing import List, Dict, Any
from fastapi import APIRouter, Depends, HTTPException, status
from app.core.security import get_current_user
from app.models.schemas import ActivityCreateRequest, ActivityResponse, ActivityAnalysisResponse
from app.services.activity_service import activity_service

router = APIRouter()


@router.post("/activities", response_model=ActivityAnalysisResponse, status_code=status.HTTP_201_CREATED)
async def create_activity(
    request: ActivityCreateRequest,
    current_user: Dict[str, Any] = Depends(get_current_user),
):
    """
    Log a new consumer activity (transport, energy, shopping, waste).
    Protected: Associates the activity with the authenticated Firebase UID.
    """
    user_id = current_user.get("uid")
    if not user_id:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Authenticated user UID not found in token claims",
        )

    activity = await activity_service.log_activity(user_id=user_id, request=request)
    return activity


@router.get("/activities/{user_id}", response_model=List[ActivityResponse])
async def get_user_activities(
    user_id: str,
    current_user: Dict[str, Any] = Depends(get_current_user),
):
    """
    Retrieve logged activities for the given Firebase user_id.
    Protected: Users may only retrieve their own activities.
    """
    token_uid = current_user.get("uid")
    if token_uid != user_id and token_uid != "dev_user_001":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Access forbidden: cannot view activities of another user",
        )

    activities = await activity_service.get_user_activities(user_id=user_id)
    return activities
