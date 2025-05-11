# Simple gRPC API

Simple gRPC API in Go, as a learning project for gRPC, protocol buffers (protobufs) and Go.

## Shared Protocol Buffers

This project will import the shared protocol buffer definitions [this repository](https://github.com/dgarciacampelo/simple-grpc-api-proto).

## Using SQLite database (for simplicity)

### WAL Mode (Write-Ahead Logging)

WAL mode significantly improves SQLite's concurrency and write performance compared to the default rollback journal mode. In WAL mode, changes are written to a separate WAL file first, and then periodically checkpointed back to the main database file. This allows readers to continue accessing the database while writes are in progress, leading to better responsiveness.

```go
// Enable WAL mode
_, err := db.Exec("PRAGMA journal_mode=WAL;")
if err != nil {
    log.Fatalf("Failed to enable WAL mode: %v", err)
}
```

### Foreign Key Support

Insight: Enforcing foreign key constraints is crucial for maintaining data integrity and consistency, especially when dealing with related entities. By declaring foreign key relationships in your database schema, SQLite will prevent actions that would violate these relationships (e.g., deleting a user if there are still other entities associated with them).

```go
// Enable foreign key support
_, err := db.Exec("PRAGMA foreign_keys=ON;")
if err != nil {
    log.Fatalf("Failed to enable foreign key support: %v", err)
}
```
