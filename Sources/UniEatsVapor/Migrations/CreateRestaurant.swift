import Fluent

struct CreateRestaurant: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("restaurants")
            .id()
            .field("vendor_id", .uuid, .required, .references("vendors", "id"))
            .field("name", .string, .required)
            .field("street", .string, .required)
            .field("city", .string, .required)
            .field("state", .string, .required)
            .field("postal_code", .string, .required)
            .field("rating", .double, .required)
            .field("is_pure_veg", .bool, .required)
            .field("cuisine", .string, .required)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .field("deleted_at", .datetime)
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema("restaurants").delete()
    }
}
