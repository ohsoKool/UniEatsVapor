import Fluent

struct CreateAddress: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("addresses")
            .id()
//            .unique(on: "userId")
            // This creates a one-to-many relationship
            .field("userId", .uuid, .required, .references("users", "id"))
            .field("street", .string, .required)
            .field("city", .string, .required)
            .field("postalCode", .string, .required)
            .field("state", .string, .required)
            .field("isDefault", .bool, .required)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .field("deleted_at", .datetime)
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema("addresses")
            .delete()
    }
}

struct UpdateAddressSchema: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("addresses")
            // Delete old camelCase fields
            .deleteField("postalCode")
            .deleteField("isDefault")
            // Add new snake_case fields
            .field("postal_code", .string, .required)
            .field("is_default", .bool, .required)
            // Add new fields safely
            .field("name", .string) // Name for someone else
            .field("phone_number", .string) // Phone number
            .field("instructions", .string) // Delivery instructions
            .field("address_type", .string, .required, .sql(.default("Home"))) // Home / Work / Other
            .update()
    }

    func revert(on database: any Database) async throws {
        try await database.schema("addresses")
            // Delete new snake_case fields
            .deleteField("postal_code")
            .deleteField("is_default")
            // Delete newly added fields
            .deleteField("name")
            .deleteField("phone_number")
            .deleteField("instructions")
            .deleteField("address_type")
            // Re-add old camelCase fields
            .field("postalCode", .string, .required)
            .field("isDefault", .bool, .required)
            .update()
    }
}

struct UpdateUserIdField: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("addresses")
            .deleteField("userId")
            .field("user_id", .uuid, .required, .references("users", "id"))
            .update()
    }

    func revert(on database: any Database) async throws {
        try await database.schema("addresses")
            .deleteField("user_id")
            .field("userId", .uuid, .required, .references("users", "id"))
            .update()
    }
}

struct AddTimestampsToAddress: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("addresses")
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .field("deleted_at", .datetime)
            .update()
    }

    func revert(on database: any Database) async throws {
        try await database.schema("addresses")
            .deleteField("created_at")
            .deleteField("updated_at")
            .deleteField("deleted_at")
            .update()
    }
}
