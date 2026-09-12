from typing import Dict, Any
from fastapi import APIRouter, Depends
from app.core.security import get_current_user
from app.models.schemas import (
    RecommendationRequest,
    RecommendationResponse,
    RecommendationItemSchema,
)

router = APIRouter()


@router.post("/recommendations", response_model=RecommendationResponse)
async def get_recommendations(
    request: RecommendationRequest,
    current_user: Dict[str, Any] = Depends(get_current_user),
):
    """
    Generate tailored circular recommendations (repair, reuse, recycle, alternative).
    Protected endpoint requiring Firebase ID token authentication.
    """
    # Baseline recommendations catalog
    catalog = [
        RecommendationItemSchema(
            recommendationId="rec_001",
            category="transport",
            title="Shift 2 Weekly Commutes to Metro / Bus",
            description="Rapid transit reduces per-passenger emissions by 75% compared to solo driving.",
            estimatedCo2Saving="-28 kg CO2/mo",
            estimatedCostImpact="Save ~₹1,400 fuel/mo",
        ),
        RecommendationItemSchema(
            recommendationId="rec_002",
            category="energy",
            title="Cold Water Wash Cycles for Laundry",
            description="Heating water accounts for 90% of washing machine energy consumption.",
            estimatedCo2Saving="-18 kg CO2/mo",
            estimatedCostImpact="Save ~₹320 electricity/mo",
        ),
        RecommendationItemSchema(
            recommendationId="rec_003",
            category="waste",
            title="Segregate E-Waste for Verified Drop-Off",
            description="Drop off old chargers, batteries and cables at local circular recycling points.",
            estimatedCo2Saving="-24 kg CO2/drop-off",
            estimatedCostImpact="Earn +50 Eco Points",
        ),
        RecommendationItemSchema(
            recommendationId="rec_004",
            category="shopping",
            title="Repair & Restore Consumer Electronics",
            description="Extends gadget lifecycle by 2+ years avoiding raw silicon manufacturing emissions.",
            estimatedCo2Saving="-65 kg CO2/repair",
            estimatedCostImpact="Save ~₹15,000 vs new replacement",
        ),
    ]

    # Filter by category if requested
    if request.focusCategory:
        cat = request.focusCategory.lower().strip()
        filtered = [r for r in catalog if r.category == cat]
        results = filtered if filtered else catalog
    else:
        results = catalog

    return RecommendationResponse(
        recommendations=results,
        totalPotentialCo2Saving="-135 kg CO2e / month across circular actions",
    )
