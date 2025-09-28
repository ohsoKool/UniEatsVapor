import Fluent

struct CreateVendor: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("vendors")
            .id()
            .field("full_name", .string, .required)
            .field("email", .string, .required)
            .field("mobile", .string, .required)
            .field("street", .string, .required)
            .field("city", .string, .required)
            .field("state", .string, .required)
            .field("postal_code", .string, .required)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .field("deleted_at", .datetime)
            .unique(on: "email") // ensure email is unique
            .unique(on: "mobile") // ensure mobile is unique
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema("vendors").delete()
    }
}
