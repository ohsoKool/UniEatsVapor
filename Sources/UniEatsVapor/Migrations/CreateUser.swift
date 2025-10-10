import Fluent
import FluentSQL

// Fluent doesn't require a class for migration and struct is simpler(lightweight), safer and also migrations doesn't require subclasses because you don't inherit it for anything
// Structs are copied(Valued type) so when they are passed around, new instances are not created accidentally
struct CreateUser: AsyncMigration {
    // AsyncMigration is a protocol which expects two functions prepare and revert

    func prepare(on database: any Database) async throws {
        try await database.schema("users")
            .id()
            .field("full_name", .string, .required)
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

// Everytime you add a new migration --> Run the command : swift run UniEatsVapor migrate

struct AddFullNameToUsers: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("users")
            .field("full_name", .string, .required, .sql(.default("default")))
            .update()
    }

    func revert(on database: any Database) async throws {
        try await database.schema("users")
            .deleteField("full_name")
            .update()
    }
}

struct RemoveOldFullNameAndAddTimestamps: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("users")
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .field("deleted_at", .datetime)
            .deleteField("fullName")
            .update()
    }

    func revert(on database: any Database) async throws {
        try await database.schema("users")
            .field("fullName", .string)
            .deleteField("created_at")
            .deleteField("updated_at")
            .deleteField("deleted_at")
            .update()
    }
}

struct addStatusToUsers: AsyncMigration {
    func prepare(on database: any Database) async throws {
        // 1. Create enum for status
        let status = try await database.enum("user_status")
            .case("pending")
            .case("verified")
            .create()

        try await database.schema("users")
            .updateField("email", .string)
            .field("status", status, .required, .sql(.default("pending")))
            .update()
    }

    func revert(on database: any Database) async throws {
        // Remove the field from the table
        try await database.schema("users")
            .deleteField("status")
            .field("email", .string, .required)
            .update()

        // Then delete the enum type itself
        try await database.enum("user_status").delete()
    }
}

struct AddUserStatusEnumAndField: AsyncMigration {
    func prepare(on database: any Database) async throws {
        let userStatusEnum = try await database.enum("user_status")
            .case("pending")
            .case("verified")
            .create()

        try await database.schema("users")
            .field("status", userStatusEnum, .required, .sql(.default(SQLLiteral.string("pending"))))
            .update()
    }

    func revert(on database: any Database) async throws {
        // Remove the field
        try await database.schema("users")
            .deleteField("status")
            .update()

        // Then remove the enum
        try await database.enum("user_status").delete()
    }
}

struct ReplaceEmailColumnInUsers: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("users")
            .deleteField("email")
            .field("email", .string, .required)
            .update()
    }

    func revert(on database: any Database) async throws {
        try await database.schema("users")
            .deleteField("email")
            .field("email", .string)
            .update()
    }
}

struct MakeFullNameOptionalInUsers: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("users")
            .deleteField("full_name") // Remove the existing NOT NULL column
            .field("full_name", .string) // Add it back as optional
            .update()
    }

    func revert(on database: any Database) async throws {
        try await database.schema("users")
            .deleteField("full_name")
            .field("full_name", .string, .required) // Revert to required
            .update()
    }
}

struct MakeEmailOptionalInUsers: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await (database as! any SQLDatabase).raw("""
            ALTER TABLE "users" ALTER COLUMN "email" DROP NOT NULL
        """).run()
    }

    func revert(on database: any Database) async throws {
        try await (database as! any SQLDatabase).raw("""
            ALTER TABLE "users" ALTER COLUMN "email" SET NOT NULL
        """).run()
    }
}
