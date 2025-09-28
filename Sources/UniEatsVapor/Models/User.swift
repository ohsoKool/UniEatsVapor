import Fluent
import Vapor

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
    @Field(key: "full_name")
    var fullName: String

    @Field(key: "email")
    var email: String

    @Field(key: "mobile")
    var mobile: String

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
    @Timestamp(key: "deleted_at", on: .update)
    var deletedAt: Date?

    // Empty init for Fluent
    init() {}

    // Init for app use
    init(id: UUID? = nil, fullName: String, email: String, mobile: String, dob: Date? = nil, gender: String? = nil) {
        self.id = id
        self.fullName = fullName
        self.email = email
        self.mobile = mobile
        self.dob = dob
        self.gender = gender
    }
}
