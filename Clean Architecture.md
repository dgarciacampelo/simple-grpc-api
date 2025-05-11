## Clean Architecture and Your Go gRPC API

This document describes how to structure this Go gRPC API project following Clean Architecture:

**1. Layers/Boundaries**

Clean Architecture organizes code into layers, with dependencies pointing inwards. The core idea is to separate business logic from infrastructure details.

- **Entities:** The innermost layer. It contains the core business objects and logic, such as `User`, `Item`, and `Purchase`. These should be pure Go structs and functions, independent of any framework or database.

- **Use Cases (Interactors):** This layer contains the business logic specific to your application's operations. For example, `CreateUser`, `GetItem`, `ProcessPurchase`. Use cases orchestrate the flow of data between entities and the outer layers.

- **Interface Adapters:** This layer adapts data between the format most convenient for the use cases and the format used by external agents, such as the database or the gRPC framework.

  - **gRPC Presenters/Handlers:** Handle gRPC requests, validate input, call use cases, format use case results into gRPC responses.

  - **Database Adapters (Repositories):** Implement interfaces defined in the use case layer to interact with the database (SQLite in your case). They convert data between your database tables and entity structs.

- **Frameworks and Drivers:** The outermost layer. It contains the frameworks and tools that are used by the application, such as the gRPC server, the SQLite database driver, and any other external libraries.

**2. Project Structure**

Here's a suggested directory structure for your Go project:

    simple_grpc_api/
    ├── cmd/
    │   └── server/       # Main application entry point (gRPC server)
    ├── internal/
    │   ├── domain/        # Entities
    │   │   ├── user.go
    │   │   ├── item.go
    │   │   ├── purchase.go
    │   ├── usecase/       # Use cases (Interactors)
    │   │   ├── user/
    │   │   │   ├── user_usecase.go
    │   │   │   ├── user_repository.go # Interface for user persistence
    │   │   ├── item/
    │   │   ├── purchase/
    │   ├── adapter/       # Interface Adapters
    │   │   ├── grpc/       # gRPC handlers/presenters
    │   │   │   ├── user_grpc.go
    │   │   │   ├── item_grpc.go
    │   │   │   ├── purchase_grpc.go
    │   │   ├── repository/  # Database adapters (Repositories)
    │   │   │   ├── sqlite/
    │   │   │   │   ├── user_repository_sqlite.go
    │   │   │   │   ├── item_repository_sqlite.go
    │   │   │   │   ├── purchase_repository_sqlite.go
    ├── pkg/           # Reusable helper functions
    ├── proto/         # Protocol Buffer definitions (.proto files)
    ├── go.mod
    ├── go.sum

**3. How Your Database Schema Fits In**

Your database schema (from the `create_database_tables_sql` immersive) will primarily be used within the **Interface Adapters** layer, specifically in the `repository/sqlite` directory.

- The repository implementations will be responsible for:

  - Mapping data from your `user`, `customer_detail`, `item`, `purchase`, and `purchase_item` tables to your Go entity structs (defined in the `domain` layer).

  - Saving data from your Go entity structs into these database tables.

  - Executing SQL queries (using the `go-sqlite3` driver) to retrieve and persist data.

**4. Example: User Registration**

Let's illustrate how a user registration would flow through the layers:

1.  **gRPC Handler:** The `CreateUser` gRPC handler in `adapter/grpc/user_grpc.go` receives the gRPC request. It validates the input (e.g., email format, password strength).

2.  **Use Case:** The handler calls the `CreateUser` use case in `usecase/user/user_usecase.go`, passing the necessary data.

3.  **Entity:** The `CreateUser` use case creates a new `User` entity (defined in `domain/user.go`).

4.  **Repository:** The use case calls the `UserRepository` interface's `Save` method (defined in `usecase/user/user_repository.go`).

5.  **SQLite Repository:** The `UserRepositorySQLite` implementation in `adapter/repository/sqlite/user_repository_sqlite.go` receives the `User` entity data. It then:

    - Generates a UUID for the new user.

    - Hashes the password (using a secure hashing library like `bcrypt`).

    - Executes an `INSERT` statement to store the user data in the `user` table.

    - If necessary, also inserts data into the `customer_detail` table.

6.  **Response:** The `UserRepositorySQLite` returns success/failure to the use case. The use case formats a response. The gRPC handler sends the gRPC response back to the client.

**5. Key Advantages of Clean Architecture**

- **Separation of Concerns:** Each layer has a specific responsibility, making the code easier to understand, test, and maintain.

- **Testability:** Business logic (in the `usecase` layer) can be tested independently of the database or gRPC framework. You can use mock repositories in your tests.

- **Maintainability:** Changes in one layer (e.g., switching from SQLite to PostgreSQL) have minimal impact on other layers.

- **Flexibility:** Easier to adapt to new requirements or technologies. For example, you could add a REST API alongside your gRPC API by creating a new set of handlers in the `adapter` layer that call the same use cases.

- **Scalability:** The layered structure makes it easier to scale your application as it grows.
