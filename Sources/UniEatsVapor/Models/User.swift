import Fluent
import Vapor

// Model tell fluent that the class User conforms to a database table
// Content lets vapor convert this data to/from JSON automatically
// @unchecked Sendable
final class User: Model, Content, @unchecked Sendable {
    // 1. Table name in the database
    static let schema: String = "users"

    // 2.Primary Key
    @ID(key: .id)
    var id: UUID?

    // 3.Fields
    @Field(key: "fullName")
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

    // empty init for fluent
    init() {}

    // init for app use
    init(id: UUID? = nil, fullName: String, email: String, mobile: String, dob: Date? = nil, gender: String? = nil) {
        self.id = id
        self.fullName = fullName
        self.email = email
        self.mobile = mobile
        self.dob = dob
        self.gender = gender
    }
}
