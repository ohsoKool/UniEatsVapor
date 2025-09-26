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
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema("addresses")
            .delete()
    }
}
