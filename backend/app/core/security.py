import logging
from typing import Dict, Any
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
import jwt
from firebase_admin import auth as firebase_auth
from app.core.config import settings

logger = logging.getLogger("ecoloop.security")
security_scheme = HTTPBearer(auto_error=True)


async def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(security_scheme),
) -> Dict[str, Any]:
    """
    FastAPI dependency to authenticate requests using Firebase ID tokens.
    Extracts and verifies Bearer token from the Authorization header.
    Never accepts raw email/password.
    """
    token = credentials.credentials
    if not token:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Authorization token is missing",
            headers={"WWW-Authenticate": "Bearer"},
        )

    # 1. Check for development / mock token in local dev environment
    if settings.ALLOW_DEV_AUTH_TOKEN and (
        token.startswith("dev-token-") or token.startswith("test-token-")
    ):
        user_id = token.split("-", 2)[-1]
        return {
            "uid": user_id if user_id else "dev_user_001",
            "email": f"{user_id}@ecoloop.org",
            "name": "EcoLoop Developer",
            "auth_time": 1700000000,
        }

    # 2. Verify with Firebase Admin SDK
    try:
        decoded_token = firebase_auth.verify_id_token(token)
        return {
            "uid": decoded_token.get("uid"),
            "email": decoded_token.get("email"),
            "name": decoded_token.get("name", "Eco Member"),
            "firebase_claims": decoded_token,
        }
    except Exception as e:
        logger.debug(f"Firebase Admin token verification failed: {e}")

    # 3. Fallback: decode unverified payload if running in local development mode
    if settings.ALLOW_DEV_AUTH_TOKEN:
        try:
            # Decode JWT claims without signature verification in dev mode
            payload = jwt.decode(token, options={"verify_signature": False})
            uid = payload.get("user_id") or payload.get("sub") or payload.get("uid")
            if uid:
                return {
                    "uid": uid,
                    "email": payload.get("email", f"{uid}@ecoloop.org"),
                    "name": payload.get("name", "Eco Member"),
                }
        except Exception:
            pass

    raise HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Invalid or expired Firebase ID token",
        headers={"WWW-Authenticate": "Bearer"},
    )
