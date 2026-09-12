import unittest
from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)
TEST_TOKEN = "dev-token-user123"
AUTH_HEADERS = {"Authorization": f"Bearer {TEST_TOKEN}"}


class TestApiV1(unittest.TestCase):
    def test_health_endpoint(self):
        """Verify GET /health returns expected status."""
        res = client.get("/health")
        self.assertEqual(res.status_code, 200)
        self.assertEqual(res.json(), {"status": "ok", "service": "EcoLoop API"})

    def test_unauthenticated_requests_are_rejected(self):
        """Verify that protected API endpoints reject requests without authorization token."""
        res = client.get("/api/v1/profile/user123")
        self.assertIn(res.status_code, [401, 403])

    def test_get_user_profile(self):
        """Verify GET /api/v1/profile/{user_id} with authenticated token."""
        res = client.get("/api/v1/profile/user123", headers=AUTH_HEADERS)
        self.assertEqual(res.status_code, 200)
        data = res.json()
        self.assertEqual(data["uid"], "user123")
        self.assertIn("email", data)
        self.assertIn("carbonGoal", data)
        self.assertIn("ecoPoints", data)

    def test_post_and_get_activities(self):
        """Verify POST /api/v1/activities and GET /api/v1/activities/{user_id}."""
        activity_payload = {
            "category": "transport",
            "activityType": "Car Commute",
            "quantity": 25.0,
            "unit": "km",
        }
        post_res = client.post("/api/v1/activities", json=activity_payload, headers=AUTH_HEADERS)
        self.assertEqual(post_res.status_code, 201)
        created = post_res.json()
        self.assertEqual(created["userId"], "user123")
        self.assertEqual(created["category"], "transport")
        self.assertEqual(created["quantity"], 25.0)
        self.assertGreater(created["co2Kg"], 0)
        self.assertIn("alternatives", created)
        self.assertGreaterEqual(len(created["alternatives"]), 1)
        # Check that top alternative has positive reduction
        top_alt = created["alternatives"][0]
        self.assertGreater(top_alt["co2ReductionKg"], 0)
        self.assertIn("explanation", top_alt)
        # Car commute is excessive carbon: must yield negative points
        self.assertLess(created["ecoPointsDelta"], 0)
        self.assertFalse(created["isPositive"])

        # Test positive sustainable activity (Bicycle / Walking)
        green_res = client.post("/api/v1/activities", json={
            "category": "transport",
            "activityType": "Bicycle",
            "quantity": 10.0,
            "unit": "km",
        }, headers=AUTH_HEADERS)
        self.assertEqual(green_res.status_code, 201)
        green_data = green_res.json()
        self.assertGreater(green_data["ecoPointsDelta"], 0)
        self.assertTrue(green_data["isPositive"])

        get_res = client.get("/api/v1/activities/user123", headers=AUTH_HEADERS)
        self.assertEqual(get_res.status_code, 200)
        activities = get_res.json()
        self.assertIsInstance(activities, list)
        self.assertGreaterEqual(len(activities), 1)

    def test_calculate_carbon(self):
        """Verify POST /api/v1/calculate-carbon."""
        calc_payload = {
            "category": "energy",
            "activityType": "Grid Electricity",
            "quantity": 10.0,
            "unit": "kWh",
        }
        res = client.post("/api/v1/calculate-carbon", json=calc_payload, headers=AUTH_HEADERS)
        self.assertEqual(res.status_code, 200)
        data = res.json()
        self.assertEqual(data["category"], "energy")
        self.assertEqual(data["estimatedCo2Kg"], 7.2)

    def test_get_recommendations(self):
        """Verify POST /api/v1/recommendations."""
        rec_payload = {"focusCategory": "waste"}
        res = client.post("/api/v1/recommendations", json=rec_payload, headers=AUTH_HEADERS)
        self.assertEqual(res.status_code, 200)
        data = res.json()
        self.assertIn("recommendations", data)
        self.assertGreaterEqual(len(data["recommendations"]), 1)

    def test_leaderboard_endpoint(self):
        """Verify GET /api/v1/leaderboard handles ranks and current user."""
        res = client.get("/api/v1/leaderboard", headers=AUTH_HEADERS)
        self.assertEqual(res.status_code, 200)
        data = res.json()
        self.assertIn("leaderboard", data)
        self.assertGreater(data["totalParticipants"], 0)
        # Verify user123 is marked as current user
        current_user_entries = [e for e in data["leaderboard"] if e["isCurrentUser"]]
        self.assertEqual(len(current_user_entries), 1)
        self.assertEqual(current_user_entries[0]["uid"], "user123")

    def test_recycling_centers_endpoint(self):
        """Verify GET /api/v1/recycling-centers returns centers with valid coordinates."""
        res = client.get("/api/v1/recycling-centers", headers=AUTH_HEADERS)
        self.assertEqual(res.status_code, 200)
        centers = res.json()
        self.assertIsInstance(centers, list)
        self.assertGreaterEqual(len(centers), 4)
        for c in centers:
            self.assertIn("latitude", c)
            self.assertIn("longitude", c)
            self.assertNotEqual(c["latitude"], 0.0)


if __name__ == "__main__":
    unittest.main()
