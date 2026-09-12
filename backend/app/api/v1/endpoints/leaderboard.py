from typing import Dict, Any
from fastapi import APIRouter, Depends
from app.core.security import get_current_user
from app.models.schemas import LeaderboardResponse
from app.services.profile_service import profile_service

router = APIRouter()


@router.get("/leaderboard", response_model=LeaderboardResponse)
async def get_leaderboard(
    limit: int = 50,
    current_user: Dict[str, Any] = Depends(get_current_user),
):
    """
    Retrieve community leaderboard ranked by eco points and carbon reduction.
    Protected: requires valid Firebase ID token.
    Identifies the requesting user with isCurrentUser=True.
    """
    user_id = current_user.get("uid")
    return await profile_service.get_leaderboard(current_uid=user_id, limit=limit)
