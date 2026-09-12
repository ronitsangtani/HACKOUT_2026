from typing import List, Optional, Dict, Any
from pydantic import BaseModel, Field


# -------------------------------------------------------------
# User Profile Schemas
# -------------------------------------------------------------
class UserProfileResponse(BaseModel):
    uid: str
    name: str
    email: str
    city: str = "Bengaluru, India"
    carbonGoal: str = "Reduce footprint by 25% by Dec 2026"
    ecoPoints: int = 50
    streak: int = 1
    createdAt: Optional[str] = None


# -------------------------------------------------------------
# Activity Schemas
# -------------------------------------------------------------
class ActivityCreateRequest(BaseModel):
    category: str = Field(..., description="transport, energy, shopping, waste")
    activityType: str = Field(..., description="Specific activity, e.g. Car, Metro, Electricity, Plastic")
    quantity: float = Field(..., gt=0, description="Amount or distance")
    unit: str = Field(..., description="km, kWh, kg, INR, etc.")


class ActivityResponse(BaseModel):
    activityId: str
    userId: str
    category: str
    activityType: str
    quantity: float
    unit: str
    co2Kg: float
    createdAt: str


# -------------------------------------------------------------
# Carbon Calculation Schemas
# -------------------------------------------------------------
class CarbonCalcRequest(BaseModel):
    category: str
    activityType: str
    quantity: float
    unit: str
    additionalParams: Optional[Dict[str, Any]] = None


class CarbonCalcResponse(BaseModel):
    category: str
    activityType: str
    quantity: float
    unit: str
    estimatedCo2Kg: float
    confidence: str = "preliminary_model"
    methodology: str = "EcoLoop baseline emission factors (IPCC / CEA India standards)"


# -------------------------------------------------------------
# Circular Recommendations Schemas
# -------------------------------------------------------------
class RecommendationRequest(BaseModel):
    focusCategory: Optional[str] = None
    targetReductionPercent: Optional[float] = None


class RecommendationItemSchema(BaseModel):
    recommendationId: str
    category: str
    title: str
    description: str
    estimatedCo2Saving: str
    estimatedCostImpact: str


class RecommendationResponse(BaseModel):
    recommendations: List[RecommendationItemSchema]
    totalPotentialCo2Saving: str


# -------------------------------------------------------------
# Activity Analysis & Circular Alternatives Schemas
# -------------------------------------------------------------
class AlternativeSuggestion(BaseModel):
    title: str
    category: str
    alternativeType: str
    estimatedCo2Kg: float
    co2ReductionKg: float
    percentageReduction: float
    explanation: str


class ActivityAnalysisResponse(BaseModel):
    activityId: str
    userId: str
    category: str
    activityType: str
    quantity: float
    unit: str
    co2Kg: float
    createdAt: str
    formulaUsed: str
    ecoPointsDelta: int = 0
    isPositive: bool = True
    alternatives: List[AlternativeSuggestion] = []


# -------------------------------------------------------------
# Leaderboard / Ranking Schemas
# -------------------------------------------------------------
class LeaderboardEntrySchema(BaseModel):
    rank: int
    uid: str
    name: str
    city: str
    ecoPoints: int
    co2SavedKg: float
    streak: int
    isCurrentUser: bool = False


class LeaderboardResponse(BaseModel):
    leaderboard: List[LeaderboardEntrySchema]
    totalParticipants: int


# -------------------------------------------------------------
# Recycling & Circular Hub Schemas
# -------------------------------------------------------------
class RecyclingCenterSchema(BaseModel):
    id: str
    name: str
    address: str
    distance: str
    latitude: float
    longitude: float
    acceptedMaterials: List[str]
    operatingHours: str
    contact: str
