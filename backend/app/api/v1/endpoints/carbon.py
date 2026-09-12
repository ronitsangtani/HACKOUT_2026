from typing import Dict, Any
from fastapi import APIRouter, Depends
from app.core.security import get_current_user
from app.models.schemas import CarbonCalcRequest, CarbonCalcResponse
from app.services.carbon_service import carbon_service

router = APIRouter()


@router.post("/calculate-carbon", response_model=CarbonCalcResponse)
async def calculate_carbon(
    request: CarbonCalcRequest,
    current_user: Dict[str, Any] = Depends(get_current_user),
):
    """
    Calculate or estimate carbon emissions for a given consumer activity.
    Protected endpoint requiring Firebase ID token authentication.
    """
    co2_kg, methodology = carbon_service.estimate_co2(
        category=request.category,
        activity_type=request.activityType,
        quantity=request.quantity,
        unit=request.unit,
    )

    return CarbonCalcResponse(
        category=request.category,
        activityType=request.activityType,
        quantity=request.quantity,
        unit=request.unit,
        estimatedCo2Kg=co2_kg,
        confidence="preliminary_model",
        methodology=methodology,
    )
