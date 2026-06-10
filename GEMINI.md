# 🚇 Tehran Metro Offline Router (GEMINI.md)

This project is a high-performance, offline-first Flutter application designed for routing within the Tehran Metro network. It utilizes Dijkstra's algorithm for shortest path calculation and ObjectBox for lightning-fast local data storage.

## 🏗️ Architecture & Design Patterns

The project follows **Clean Architecture** principles to ensure separation of concerns, testability, and maintainability:

### 1. Domain Layer (`lib/features/metro_routing/domain`)
- **Entities:** Pure Dart classes representing core concepts like `MetroGraph` and `MetroRoute`.
- **Use Cases:** Business logic for routing (`GetMetroRoute`), updating the graph (`UpdateMetroGraph`), and fetching stations (`GetAvailableStations`).
- **Repositories:** Interfaces defining data requirements.

### 2. Data Layer (`lib/features/metro_routing/data`)
- **Models:** Data Transfer Objects (DTOs) with JSON serialization and ObjectBox annotations (`MetroGraphModel`).
- **Data Sources:** 
  - `MetroRemoteDataSource`: Fetches data from external APIs using `dio`.
  - `MetroLocalDataSource`: Manages persistence using `objectbox`.
- **Repositories:** Implementation of domain repository interfaces, coordinating remote and local data.

### 3. Presentation Layer (`lib/features/metro_routing/presentation`)
- **State Management:** `flutter_bloc` (Cubit/Bloc) is used to manage UI states.
- **UI:** Widgets and Pages follow a "Dumb UI" pattern, delegating logic to Blocs. Supports RTL (Persian) natively.

## 🛠️ Core Tech Stack

| Technology | Purpose |
| :--- | :--- |
| **Flutter/Dart** | UI Framework & Language |
| **ObjectBox** | Fast C++ based NoSQL database for offline storage |
| **flutter_bloc** | State management (Business Logic Component) |
| **GetIt** | Dependency Injection |
| **Dartz** | Functional programming primitives (Either, Task) for error handling |
| **Dio** | HTTP client for network requests |
| **Dijkstra's Algorithm** | Shortest path calculation on the metro graph |

## 🚀 Key Commands

### Setup & Development
- **Get Dependencies:** `flutter pub get`
- **Generate Code (ObjectBox):** `dart run build_runner build`
- **Run Application:** `flutter run`

### Testing
- **Run Unit Tests:** `flutter test`
- **Run Integration Tests:** `flutter drive --target=integration_test/app_test.dart`

### Data Maintenance
- **Extract/Refresh Metro Data:** `dart extract_metro_data.dart`
  - This script fetches raw station data from a GitHub source, formats it, and saves it as `metro_graph.json`.

## 📝 Development Conventions

- **RTL Support:** The application is designed for Persian speakers; ensure all UI elements support Right-to-Left (RTL) layout.
- **Error Handling:** Use `Either<Failure, T>` from the `dartz` package for consistent error handling in UseCases and Repositories.
- **Dependency Injection:** Always use `GetIt` (`sl`) for providing dependencies to avoid tight coupling.
- **Testing:** New features should include unit tests for UseCases and Blocs.
