# 🌿 EcoLoop — Gamified Carbon Footprint & Circular Action App

> **Duolingo-styled climate action & sustainability mobile app powered by Flutter, FastAPI, and Firebase.**  
> Built for **HACKOUT 2026**.

---

## 📖 Overview

**EcoLoop** transforms carbon footprint tracking and sustainability education into an addictive, playful, gamified experience inspired by the Duolingo design system. Instead of generic charts and dry spreadsheets, EcoLoop guides users through interactive climate lessons, daily circular challenges, and carbon mitigation stages with an original **Polar Bear Mascot** serving as the emotional and visual center of the application.

---

## 🐻 Polar Bear Mascot & Dynamic Health Condition

The **Polar Bear** reflects the user's real-time climate impact and emotional response:
- ❄️ **Thriving & Happy**: Low emissions / circular lifestyle.
- 😊 **Content**: Moderate emissions.
- 😟 **Concerned & Melty Ice**: Excessive emissions trigger visible distress and melting ice platform.
- 🌟 **Dynamic Mascot System**:
  - Main Journey Mascot on Home / Dashboard.
  - Interactive Floating Mascot Reactions on activity logging.
  - Profile status badge showing live mascot health & mood.

---

## 🚀 Key Features

### 1. 🗺️ Gamified Journey Progression
- **4 Interactive Thematic Stages**:
  - ⚡ **Clean Energy & Efficiency**
  - 🚲 **Low-Carbon Transport**
  - ♻️ **Circular Waste Reduction**
  - 🥗 **Sustainable Food Systems**
- **Concurrent Stage Access**: All 4 stages are unlocked and playable simultaneously.
- **Duolingo Zig-Zag Path**: 3D tactile nodes with completion crowns, stars, and animated progress connectors.

### 2. ⚡ Dynamic Eco Scoring Engine
- **Conditional Points Engine**: Points are awarded strictly based on real climate impact.
- **Negative Penalties**: Excessive carbon choices (e.g., solo petrol car commuting) deduct points and display an urgent warning banner.
- **Positive Rewards**: Eco-friendly actions (cycling, public transit, plant-based diets, composting) reward substantial gems & XP.
- **Multiple Selection**: Energy, Food, and Waste modules support multi-action logging.

### 3. 🤖 Live AI Climate Recommendations
- Built into the lesson completion flow.
- Recommends actionable circular alternatives based on the selected activity.
- Users can instantly commit to suggestions with a single tap `[ TRY THIS ]` to earn bonus eco points.

### 4. 🔮 What-If Carbon Simulator
- Interactive sliders modeling energy reduction, transport mode shift, and dietary changes.
- Live real-time projection of monthly kg $CO_2e$ avoided and forest tree equivalents saved.

### 5. 🏆 Duolingo-Styled Achievement Modals
- Clean, glitch-free popups with zero render overflow across narrow and wide devices.
- **Points Breakdown Card**:
  - 💎 **YOUR POINTS**: User's current points
  - 🎯 **POINTS NEEDED**: Points threshold to unlock
  - 📊 Rounded progress bar with percentage indicator
  - 🏷️ Dynamic status badge: `Unlocked ✓` or `In Progress ⏳ (X pts needed)`
- Accessible from both **Profile** (`Achievements`) and **Rewards** (`Milestone Badges`).

### 6. 🎁 Circular Rewards & Perks
- Milestone badges with tiered rewards.
- Circular economy discount coupons and eco-partner vouchers.

---

## 🛠️ Tech Stack & Architecture

### **Mobile App (Flutter)**
- **Framework**: Flutter 3.38+ / Dart 3.10+
- **State Management**: Flutter Riverpod (`StateNotifierProvider`, `StreamProvider`)
- **Design System**: Custom Duolingo-inspired 3D UI, tactile bouncy buttons, pill badges, and custom painter Polar Bear.
- **Database & Auth**: Firebase Auth + Cloud Firestore.

### **Backend Server (Python FastAPI)**
- **Framework**: FastAPI (Asynchronous Python 3.11+)
- **Server**: Uvicorn ASGI
- **Data Models**: Pydantic v2 schemas
- **APIs**:
  - `/api/v1/carbon/calculate`: Carbon emission and eco point calculation
  - `/api/v1/recommendations`: AI circular action suggestions
  - `/api/v1/activities`: Historical action tracking
  - `/api/v1/profile`: User progress & gamification metrics

---

## 📂 Project Structure

```
HACKOUT_2026/
├── android/                   # Native Android host configuration
│   ├── app/
│   │   ├── google-services.json # Firebase Android configuration
│   │   └── build.gradle.kts
│   ├── gradle/wrapper/        # Gradle wrapper binaries & properties
│   ├── gradlew                # Unix Gradle wrapper executable
│   └── gradlew.bat            # Windows Gradle wrapper batch script
├── backend/                   # FastAPI Backend Server
│   ├── app/
│   │   ├── api/v1/endpoints/  # Carbon, recommendations, activities APIs
│   │   ├── core/              # Config, Firebase admin, security
│   │   ├── models/schemas.py  # Pydantic data schemas
│   │   ├── services/          # Business & carbon scoring logic
│   │   └── main.py            # FastAPI entrypoint
│   ├── tests/                 # Pytest backend test suite
│   ├── .env.example           # Example backend configuration
│   └── requirements.txt       # Python dependencies
├── lib/                       # Flutter Application Code
│   ├── app/                   # App root, routes, theme & navigation scaffold
│   ├── core/
│   │   ├── constants/         # App constants
│   │   ├── providers/         # Riverpod global state providers
│   │   ├── services/          # API client & HTTP network service
│   │   └── widgets/           # PolarBearWidget, GamifiedHeader, Badges, 3D Buttons
│   ├── features/
│   │   ├── activities/        # Add Activity wizard, history & impact screens
│   │   ├── auth/              # Login, register, forgot password, Riverpod auth
│   │   ├── dashboard/         # Duolingo journey path, stage cards & daily goals
│   │   ├── profile/           # Achievements, user stats & settings
│   │   ├── recommendations/   # AI recommendations & What-If simulator
│   │   ├── recycling/         # Circular recycling locator
│   │   └── rewards/           # Milestone badges & eco perks
│   ├── firebase_options.dart  # Firebase initialization configuration
│   └── main.dart              # Flutter application entrypoint
├── test/                      # Comprehensive Flutter widget & unit tests
│   ├── api_service_test.dart
│   ├── auth_model_test.dart
│   ├── phase3_screens_test.dart
│   └── widget_test.dart
├── firestore.rules            # Firestore security rules
├── pubspec.yaml               # Flutter package manifest & dependencies
└── README.md                  # Project documentation
```

---

## 🚦 Getting Started

### 1. Prerequisites
- **Flutter SDK**: `>= 3.24.0`
- **Dart SDK**: `>= 3.5.0`
- **Python**: `>= 3.10`
- **Android Device / Emulator** or physical phone connected via USB.

### 2. Backend Setup
```bash
cd backend
python -m venv venv

# Windows:
.\venv\Scripts\activate
# Linux / macOS:
source venv/bin/activate

pip install -r requirements.txt
python -m uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```
The FastAPI documentation will be live at `http://localhost:8000/docs`.

### 3. Frontend Setup
```bash
# In the root project directory:
flutter pub get

# Connect Android phone or emulator via ADB:
adb reverse tcp:8000 tcp:8000

# Run on connected device:
flutter run
```

### 4. Running Tests
```bash
# Run all Flutter widget & unit tests:
flutter test

# Run backend Pytest suite:
pytest backend/tests
```

---

## 🛡️ License & Acknowledgments
Built with ❤️ for **HACKOUT 2026**.
All mascot animations and Duolingo-styled UI elements are original custom components.
