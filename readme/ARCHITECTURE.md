# Architecture & Code Structure

The **KSKT Rider** application is built following **Clean Architecture** principles and the **BLoC (Business Logic Component)** pattern for predictable and testable state management.

---

## High-Level Architecture

```
lib/
├── core/                        # Shared infrastructure & foundational services
│   ├── di/                      # Dependency Injection (GetIt service locator)
│   ├── routes/                  # Navigation route definitions & route table
│   ├── services/                # Geolocation, geocoding, and network services
│   └── theme/                   # Colors, typography, spacing, and app themes
│
└── features/                    # Feature-driven modular structure
    ├── splash/                  # App launch, branding animation, permission pre-check
    ├── permission/              # Location & system permission acquisition flow
    ├── settings/                # Rider preferences and profile configuration
    └── trip/                    # Core trip tracking, maps, and route recording
        ├── data/                # Data sources, models, and repository implementations
        ├── domain/              # Entities, repository interfaces, and use cases
        └── presentation/        # BLoC state management, pages, and UI widgets
```

---

## Layer Breakdown

### 1. Domain Layer (Innermost)
- **Entities**: Business models (`Trip`, `LocationPoint`).
- **Repositories**: Abstract contracts defining data operations without dependency on frameworks.
- **Use Cases**: Encapsulate specific business actions (e.g., `StartTripUseCase`, `StopTripUseCase`, `GetTripHistoryUseCase`).

### 2. Data Layer
- **Models**: Serializable data transfer objects with JSON/SQLite mappings extending domain entities.
- **Data Sources**:
  - *Local*: SQLite database (`sqflite`) for offline trip persistence.
  - *Remote*: HTTP client for API sync and geocoding services.
- **Repositories**: Concrete implementations of domain repository interfaces coordinating local and remote sources.

### 3. Presentation Layer
- **BLoC**:
  - `TripBloc`: Manages trip lifecycle states (idle, in-progress, paused, completed).
  - `LocationBloc`: Manages continuous GPS location streams and map coordinate updates.
- **Pages**: Top-level screen widgets (`SplashPage`, `HomePage`, `TripDetailsPage`).
- **Widgets**: Reusable, modular UI components (e.g., `RiderMap`, `TripControls`, `StatCard`).

---

## Dependency Injection

All dependencies (use cases, repositories, data sources, and BLoCs) are registered in:
`lib/core/di/injection_container.dart`

Example resolution:
```dart
final tripBloc = di.sl<TripBloc>();
```
