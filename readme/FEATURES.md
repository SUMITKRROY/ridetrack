# Features & Functionalities

Overview of the core features implemented in **KSKT Rider**.

---

## 1. Splash Screen & Brand Identity
- **Branded Presentation**: Displays the official KSKT (Kisaan Se Kitchen Tak) emblem with smooth fade-in and scale animations.
- **Permission Pre-Check**: Automatically checks location permission status and routes riders directly to the main map or the permissions onboarding screen.

## 2. Location & Permissions Onboarding
- Explains why location access is critical for accurate ride and delivery tracking.
- Seamless permission request handling with fallback instructions for application settings.

## 3. Real-Time Trip Tracking
- **Live GPS Tracking**: Streams accurate rider coordinates with optimized battery and distance thresholds using `geolocator`.
- **Trip Lifecycle**:
  - Start trip
  - Live metric updates (distance traveled, current speed, elapsed time)
  - Pause / Resume ride
  - Complete trip with summary metrics
- **Offline Persistence**: Trip routes and points stored locally via `sqflite` so data is preserved even during intermittent network drops.

## 4. Interactive Rider Map
- Interactive map widget displaying current rider position, breadcrumb path, and route markers.
- Auto-center camera toggle following rider position in real time.

## 5. Geocoding & Address Resolution
- Translates coordinates into human-readable street names and landmarks using reverse geocoding services.
- Displays pickup and drop destination details for farm-to-kitchen routes.
