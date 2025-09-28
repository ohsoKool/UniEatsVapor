import Fluent

// Fluent doesn't require a class for migration and struct is simpler(lightweight), safer and also migrations doesn't require subclasses because you don't inherit it for anything
// Structs are copied(Valued type) so when they are passed around, new instances are not created accidentally
struct CreateUser: AsyncMigration {
    // AsyncMigration is a protocol which expects two functions prepare and revert

    func prepare(on database: any Database) async throws {
        try await database.schema("users")
            .id()
            .field("fullName", .string, .required)
            .field("email", .string, .required)
            .unique(on: "email")
            .field("mobile", .string, .required)
            .unique(on: "mobile")
            .field("gender", .string)
            .field("dob", .date)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .field("deleted_at", .datetime)
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema("users").delete()
    }
}

// Everytime you add a new migration --> Run the command : swift run UniEatsVapor migration
