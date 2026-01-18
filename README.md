# Clean Architecture in Expense Manager

This document outlines the Clean Architecture implementation in the Expense Manager Flutter application. It explains the project structure, components, and how they interact with each other.

## Table of Contents
1. [Overview](#overview)
2. [Project Structure](#project-structure)
3. [Architecture Layers](#architecture-layers)
    - [Domain Layer](#domain-layer)
    - [Data Layer](#data-layer)
    - [Presentation Layer](#presentation-layer)
4. [Dependency Rule](#dependency-rule)
5. [Key Components](#key-components)
    - [Use Cases](#use-cases)
    - [Repositories](#repositories)
    - [Entities](#entities)
6. [Error Handling](#error-handling)
7. [Testing Strategy](#testing-strategy)
8. [Best Practices](#best-practices)

## Overview

Clean Architecture is a software design philosophy that emphasizes separation of concerns. The application is divided into layers with clear boundaries, making it:

- **Independent of Frameworks**: Not tied to any specific UI or database
- **Testable**: Business rules can be tested without UI, database, or external services
- **Independent of UI**: UI can change without changing the business logic
- **Independent of Database**: Business rules are not bound to the database
- **Independent of External Services**: External services can be swapped without affecting the core logic

## Project Structure

```
lib/
├── core/                    # Core functionality used across the app
│   ├── constants/          # App-wide constants
│   ├── errors/             # Custom exceptions and failures
│   ├── network/            # Network related code
│   ├── utils/              # Utility classes and extensions
│   └── widgets/            # Reusable widgets
│
├── features/               # Feature-based modules
│   └── expense/            # Expense feature
│       ├── data/           # Data layer
│       │   ├── datasources/ # Data sources (local, remote)
│       │   ├── models/     # Data models (DTOs)
│       │   └── repositories/ # Repository implementations
│       │
│       ├── domain/         # Business logic
│       │   ├── entities/   # Business objects
│       │   ├── repositories/ # Repository interfaces
│       │   └── usecases/   # Application-specific business rules
│       │
│       └── presentation/   # UI Layer
│           ├── bloc/       # Business Logic Components
│           ├── pages/      # Screen widgets
│           └── widgets/    # Reusable UI components
│
└── app/                    # App-wide configurations
    ├── app.dart           # Main app widget
    ├── routes/            # App routes
    └── theme/             # App theming
```

## Architecture Layers

### Domain Layer

The innermost layer containing enterprise business logic.

- **Entities**: Business objects (e.g., `ExpenseEntity`)
- **Repositories**: Abstract classes defining the contract for data operations
- **Use Cases**: Application-specific business rules

```dart
// Example: Expense Entity
class ExpenseEntity extends Equatable {
  final String? id;
  final String title;
  final double amount;
  // ... other properties
}
```

### Data Layer

Implements the interfaces defined in the domain layer.

- **Repositories**: Concrete implementations of repository interfaces
- **Data Sources**: Local (SQLite) and Remote (API) data sources
- **Models**: Data Transfer Objects (DTOs) for API/DB

```dart
// Example: Expense Repository Implementation
class ExpenseRepositoryImpl implements ExpenseRepository {
  final ExpenseLocalDataSource localDataSource;
  
  @override
  ResultFuture<ExpenseEntity> addExpense(ExpenseEntity expense) {
    // Implementation
  }
}
```

### Presentation Layer

Contains UI components that interact with the domain layer.

- **BLoCs**: Business Logic Components for state management
- **Pages**: Screen widgets
- **Widgets**: Reusable UI components

```dart
// Example: Expense BLoC
class ExpenseBloc extends Bloc<ExpenseEvent, ExpenseState> {
  final AddExpenseUseCase addExpenseUseCase;
  
  Future<void> _onAddExpense(
    AddExpenseEvent event,
    Emitter<ExpenseState> emit,
  ) async {
    // Implementation
  }
}
```

## Dependency Rule

The fundamental rule of Clean Architecture is the **Dependency Rule**:

> Source code dependencies can only point inwards. Nothing in an inner circle can know anything at all about something in an outer circle.

- Inner layers have no knowledge of outer layers
- Dependencies point inwards
- Outer layers implement interfaces defined by inner layers

## Key Components

### Use Cases

Use cases represent application-specific business rules. They orchestrate the flow of data between entities and repositories.

```dart
class AddExpenseUseCase extends UseCase<ExpenseEntity, AddExpenseParams> {
  final ExpenseRepository _repository;
  
  @override
  ResultFuture<ExpenseEntity> call(AddExpenseParams params) {
    return _repository.addExpense(params.expense);
  }
}
```

### Repositories

Repositories define the contract for data operations. The domain layer defines the interface, and the data layer provides the implementation.

```dart
// Domain Layer
abstract class ExpenseRepository {
  ResultFuture<ExpenseEntity> addExpense(ExpenseEntity expense);
  // ... other methods
}

// Data Layer
class ExpenseRepositoryImpl implements ExpenseRepository {
  @override
  ResultFuture<ExpenseEntity> addExpense(ExpenseEntity expense) {
    // Implementation
  }
}
```

### Entities

Entities are the business objects of the application. They are simple classes with properties and minimal behavior.

```dart
class ExpenseEntity extends Equatable {
  final String? id;
  final String title;
  final double amount;
  final DateTime date;
  final String category;
  
  // ...
}
```

## Error Handling

Error handling is implemented using the `Either` type and custom `Failure` classes.

```dart
// Using Either for error handling
typedef ResultFuture<T> = Future<Either<Failure, T>>;

// Custom failure classes
abstract class Failure {
  final String message;
  final StackTrace? stackTrace;
  
  const Failure(this.message, [this.stackTrace]);
}
```

## Testing Strategy

1. **Domain Layer**: Test use cases with mock repositories
2. **Data Layer**: Test repository implementations with mock data sources
3. **Presentation Layer**: Test BLoCs with mock use cases

```dart
group('AddExpenseUseCase', () {
  late AddExpenseUseCase useCase;
  late MockExpenseRepository mockRepository;
  
  setUp(() {
    mockRepository = MockExpenseRepository();
    useCase = AddExpenseUseCase(mockRepository);
  });
  
  test('should add expense through repository', () async {
    // Test implementation
  });
});
```

## Best Practices

1. **Single Responsibility**: Each class should have only one reason to change
2. **Dependency Injection**: Use constructor injection for dependencies
3. **Immutability**: Use immutable objects where possible
4. **Null Safety**: Leverage Dart's null safety features
5. **Testing**: Write unit tests for all use cases and business logic
6. **Separation of Concerns**: Keep UI, business logic, and data access separate
7. **Documentation**: Document public APIs and complex logic

## Getting Started

1. **Adding a New Feature**:
    - Create the domain entities
    - Define repository interfaces
    - Implement use cases
    - Create data layer implementations
    - Build UI components

2. **Running Tests**:
   ```bash
   flutter test
   ```

3. **Generating Code**:
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

## Conclusion

This Clean Architecture implementation provides a solid foundation for building maintainable, testable, and scalable Flutter applications. By following these principles and patterns, the codebase remains flexible and easy to modify as requirements change.
