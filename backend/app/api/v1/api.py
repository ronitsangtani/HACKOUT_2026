from fastapi import APIRouter
from app.api.v1.endpoints import profile, activities, carbon, recommendations, leaderboard, recycling

api_router = APIRouter()

api_router.include_router(profile.router, tags=["Profile"])
api_router.include_router(activities.router, tags=["Activities"])
api_router.include_router(carbon.router, tags=["Carbon"])
api_router.include_router(recommendations.router, tags=["Recommendations"])
api_router.include_router(leaderboard.router, tags=["Leaderboard"])
api_router.include_router(recycling.router, tags=["Recycling"])
