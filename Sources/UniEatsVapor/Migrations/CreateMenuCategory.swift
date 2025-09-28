import Fluent

struct CreateMenuCategory: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("menu_categories")
            .id()
            .field("category_name", .string, .required)
            .field("restaurant_id", .uuid, .required, .references("restaurants", "id"))
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .unique(on: "restaurant_id", "category_name")
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema("menu_categories").delete()
    }
}
