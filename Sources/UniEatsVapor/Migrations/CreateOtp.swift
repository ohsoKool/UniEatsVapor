import Fluent
import Vapor

struct CreateOtp: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("otps")
            .id()
            .field("mobile", .string, .required)
            .field("code", .string, .required)
            .field("expires_at", .datetime, .required)
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema("otps")
            .delete()
    }
}
