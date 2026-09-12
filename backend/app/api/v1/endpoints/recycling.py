from typing import List, Dict, Any, Optional
from fastapi import APIRouter, Depends, Query
from app.core.security import get_current_user
from app.models.schemas import RecyclingCenterSchema
from app.core.firebase import get_firestore_client

router = APIRouter()

SEED_CENTERS = [
    RecyclingCenterSchema(
        id="rc_001",
        name="GreenEarth E-Waste & Battery Drop-Off",
        address="42 Ring Road, Indiranagar",
        distance="1.2 km away",
        latitude=12.9784,
        longitude=77.6408,
        acceptedMaterials=["E-Waste", "Batteries", "Cables", "Screens"],
        operatingHours="Mon - Sat: 9:00 AM - 6:30 PM",
        contact="+91 98765 43210",
    ),
    RecyclingCenterSchema(
        id="rc_002",
        name="EcoCycle Polymer Recovery Hub",
        address="Plot 18, Industrial Area Stage 2",
        distance="2.8 km away",
        latitude=13.0312,
        longitude=77.5186,
        acceptedMaterials=["Plastic", "PET Bottles", "Packaging", "Paper"],
        operatingHours="Mon - Fri: 8:00 AM - 5:00 PM",
        contact="+91 98765 11223",
    ),
    RecyclingCenterSchema(
        id="rc_003",
        name="Circular Textile & Clothing Thrift Drop",
        address="Corner 12th Main, Koramangala",
        distance="3.5 km away",
        latitude=12.9352,
        longitude=77.6245,
        acceptedMaterials=["Clothes", "Fabrics", "Footwear", "Linens"],
        operatingHours="Daily: 10:00 AM - 8:00 PM",
        contact="+91 98765 99887",
    ),
    RecyclingCenterSchema(
        id="rc_004",
        name="City Metals & Paper Reclamation Point",
        address="Civic Utility Center, Jayanagar",
        distance="4.1 km away",
        latitude=12.9299,
        longitude=77.5824,
        acceptedMaterials=["Metal Cans", "Paper", "Cardboard", "Glass"],
        operatingHours="Mon - Sat: 9:30 AM - 5:30 PM",
        contact="+91 98765 33445",
    ),
    RecyclingCenterSchema(
        id="rc_005",
        name="Whitefield Clean Loop Drop Hub",
        address="ITPB Main Road, Whitefield",
        distance="6.2 km away",
        latitude=12.9698,
        longitude=77.7499,
        acceptedMaterials=["E-Waste", "Plastic", "Glass"],
        operatingHours="Mon - Sat: 10:00 AM - 7:00 PM",
        contact="+91 98765 55667",
    ),
]


@router.get("/recycling-centers", response_model=List[RecyclingCenterSchema])
async def get_recycling_centers(
    material: Optional[str] = Query(None, description="Filter by accepted material"),
    current_user: Dict[str, Any] = Depends(get_current_user),
):
    """
    Retrieve verified circular drop-off and recycling centers with coordinates.
    Protected: requires valid Firebase ID token.
    """
    db = get_firestore_client()
    centers = []
    if db is not None:
        try:
            docs = db.collection("recycling_centers").stream()
            for doc in docs:
                data = doc.to_dict()
                centers.append(RecyclingCenterSchema(**data))
        except Exception:
            pass

    if not centers:
        centers = list(SEED_CENTERS)

    if material:
        mat_lower = material.lower().strip()
        centers = [c for c in centers if any(mat_lower in m.lower() for m in c.acceptedMaterials)]

    return centers
