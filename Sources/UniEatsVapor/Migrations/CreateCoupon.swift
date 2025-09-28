import Fluent

struct CreateCoupon: AsyncMigration {
    func prepare(on database: any Database) async throws {
        // 1. Create enum for discount_type
        let discountType = try await database.enum("discount_type")
            .case("percentage")
            .case("amount")
            .create()

        // 2. Create schema
        try await database.schema("coupons")
            .id()
            .field("vendor_id", .uuid, .required, .references("vendors", "id"))
            .field("code", .string, .required)
            .field("description", .string, .required)
            .field("discount_type", discountType, .required)
            .field("discount_value", .int, .required)
            .field("is_active", .bool, .required)
            .field("max_uses", .int, .required)
            .field("min_cart_value", .double, .required)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .field("deleted_at", .datetime)
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema("coupons").delete()
        try await database.enum("discount_type").delete()
    }
}
