import uuid
from datetime import datetime, timezone
from typing import List, Dict, Any
from app.core.firebase import get_firestore_client
from app.models.schemas import ActivityCreateRequest, ActivityResponse, ActivityAnalysisResponse
from app.services.carbon_service import carbon_service

# In-memory store fallback for development / test isolation
_local_activity_store: Dict[str, List[Dict[str, Any]]] = {}


class ActivityService:
    @staticmethod
    async def log_activity(user_id: str, request: ActivityCreateRequest) -> ActivityAnalysisResponse:
        co2_kg, method = carbon_service.estimate_co2(
            category=request.category,
            activity_type=request.activityType,
            quantity=request.quantity,
            unit=request.unit,
        )

        activity_id = f"act_{uuid.uuid4().hex[:12]}"
        created_at_iso = datetime.now(timezone.utc).isoformat()

        record = {
            "activityId": activity_id,
            "userId": user_id,
            "category": request.category,
            "activityType": request.activityType,
            "quantity": request.quantity,
            "unit": request.unit,
            "co2Kg": co2_kg,
            "createdAt": created_at_iso,
        }

        # Try to persist to Cloud Firestore
        db = get_firestore_client()
        if db is not None:
            try:
                db.collection("activities").document(activity_id).set(record)
            except Exception:
                pass

        # Also keep in local session store
        if user_id not in _local_activity_store:
            _local_activity_store[user_id] = []
        _local_activity_store[user_id].insert(0, record)

        # Generate lower-carbon alternatives
        alternatives = carbon_service.find_alternatives(
            category=request.category,
            activity_type=request.activityType,
            quantity=request.quantity,
            unit=request.unit,
            original_co2=co2_kg,
        )

        return ActivityAnalysisResponse(
            **record,
            formulaUsed=method,
            alternatives=alternatives,
        )

    @staticmethod
    async def get_user_activities(user_id: str) -> List[ActivityResponse]:
        db = get_firestore_client()
        if db is not None:
            try:
                docs = (
                    db.collection("activities")
                    .where("userId", "==", user_id)
                    .order_by("createdAt", direction="DESCENDING")
                    .limit(50)
                    .stream()
                )
                activities = [ActivityResponse(**doc.to_dict()) for doc in docs]
                if activities:
                    return activities
            except Exception:
                pass

        # Fallback to local session store
        local_items = _local_activity_store.get(user_id, [])
        return [ActivityResponse(**item) for item in local_items]


activity_service = ActivityService()
