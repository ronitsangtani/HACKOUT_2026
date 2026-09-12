import logging
import os
import firebase_admin
from firebase_admin import credentials, firestore
from app.core.config import settings

logger = logging.getLogger("ecoloop.firebase")

_firebase_app = None
_firestore_client = None


def initialize_firebase():
    """Initialize Firebase Admin SDK with credentials or application default."""
    global _firebase_app, _firestore_client
    if _firebase_app is not None:
        return _firebase_app

    cred_path = settings.FIREBASE_CREDENTIALS_PATH
    try:
        if cred_path and os.path.exists(cred_path):
            cred = credentials.Certificate(cred_path)
            _firebase_app = firebase_admin.initialize_app(
                cred, {"projectId": settings.FIREBASE_PROJECT_ID}
            )
            logger.info("Firebase Admin initialized with service account certificate.")
        else:
            # Initialize with default options for development/testing
            _firebase_app = firebase_admin.initialize_app(
                options={"projectId": settings.FIREBASE_PROJECT_ID}
            )
            logger.info(
                f"Firebase Admin initialized with project ID: {settings.FIREBASE_PROJECT_ID}"
            )

        _firestore_client = firestore.client()
    except Exception as e:
        logger.warning(f"Firebase Admin initialization note: {e}")

    return _firebase_app


def get_firestore_client():
    """Retrieve the Firestore client instance."""
    global _firestore_client
    if _firestore_client is None:
        initialize_firebase()
    return _firestore_client
