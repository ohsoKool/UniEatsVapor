import Fluent
import Vapor

enum UserStatus: String, Codable {
    case pending
    case verified
}

// Model tells Fluent that the class User conforms to a database table
// Content lets Vapor convert this data to/from JSON automatically
// @unchecked Sendable allows concurrency usage without explicit safety checks
final class User: Model, Content, @unchecked Sendable {
    // 1. Table name in the database
    static let schema: String = "users"

    // 2. Primary Key
    @ID(key: .id)
    var id: UUID?

    // 3. Fields
    @OptionalField(key: "full_name")
    var fullName: String?

    @OptionalField(key: "email")
    var email: String?

    @Field(key: "mobile")
    var mobile: String?

    @Enum(key: "status")
    var status: UserStatus

    @OptionalField(key: "dob")
    var dob: Date?

    @OptionalField(key: "gender")
    var gender: String?

    // This tells Fluent: User has many Address rows
    @Children(for: \.$user)
    var addresses: [Address]

    // Tracks when this row was created
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    // Tracks when this row was last updated
    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    // Tracks when this row was last updated
    @Timestamp(key: "deleted_at", on: .delete)
    var deletedAt: Date?

    // Empty init for Fluent
    init() {}

    // Init for app use
    init(
        id: UUID? = nil,
        fullName: String? = nil,
        email: String? = nil,
        mobile: String,
        status: UserStatus = .pending,
        dob: Date? = nil,
        gender: String? = nil
    ) {
        self.id = id
        self.fullName = fullName
        self.email = email
        self.mobile = mobile
        self.status = status
        self.dob = dob
        self.gender = gender
    }
}

// Purpose: Converts a User model instance into a simplified response object (ResponseDTO) that’s safe and consistent for API responses.
extension User {
    func asResponseDTO() throws -> ResponseDTO {
        try .init(id: requireID(), mobile: mobile ?? "", status: status.rawValue)
    }

    struct ResponseDTO: Content {
        let id: UUID
        let mobile: String
        let status: String
    }
}
