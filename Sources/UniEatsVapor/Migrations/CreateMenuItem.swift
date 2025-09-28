import Fluent

struct CreateMenuItem: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("menu_items")
            .id()
            .field("item_name", .string, .required)
            .field("price", .double, .required)
            .field("description", .string, .required)
            .field("is_available", .bool, .required)
            .field("item_image", .string, .required)
            .field("tags", .array(of: .string), .required) // store string array
            .field("menu_category_id", .uuid, .required, .references("menu_categories", "id"))
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .unique(on: "menu_category_id", "item_name")
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema("menu_items").delete()
    }
}
