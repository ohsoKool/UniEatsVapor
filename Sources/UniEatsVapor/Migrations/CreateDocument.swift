import Fluent

struct CreateDocument: AsyncMigration {
    func prepare(on database: any Database) async throws {
        // 1. Create enum for status
        let status = try await database.enum("document_status")
            .case("pending")
            .case("accepted")
            .case("rejected")
            .create()

        // 2. Create schema
        try await database.schema("documents")
            .id()
            .field("vendor_id", .uuid, .required, .references("vendors", "id"))
            .field("business_license", .string, .required)
            .field("gst", .string, .required)
            .field("pan", .string, .required)
            .field("bank_statement", .string, .required)
            .field("expiry_date", .date, .required)
            .field("verified_on", .date)
            .field("note", .string)
            .field("status", status, .required, .sql(.default("pending")))
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .field("deleted_at", .datetime)
            .unique(on: "vendor_id")
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema("documents").delete()
        try await database.enum("document_status").delete()
    }
}
