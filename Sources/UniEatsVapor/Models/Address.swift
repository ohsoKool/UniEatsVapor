import Fluent
import Vapor

final class Address: Model, Content, @unchecked Sendable {
    static let schema = "addresses"

    @ID(key: .id) var id: UUID?
    // This tells Fluent: addresses table has a column user_id which is a foreign key pointing to users.id in the User model
    // Doing this creates a backing property called _$user (used in the init)
    @Field(key: "street") var street: String
    @Field(key: "city") var city: String
    @Field(key: "state") var state: String
    @Field(key: "postal_code") var postalCode: String
    @Field(key: "is_default") var isDefault: Bool

    @Parent(key: "user_id") var user: User

    // Tracks when this row was created
    @Timestamp(key: "created_at", on: .create) var createdAt: Date?
    // Tracks when this row was last updated
    @Timestamp(key: "updated_at", on: .update) var updatedAt: Date?
    // Tracks when this row was last deleted
    @Timestamp(key: "deleted_at", on: .update) var deletedAt: Date?

    // Empty init for Fluent
    init() {}

    // Init for app use
    init(id: UUID? = nil, userId: UUID, street: String, city: String, state: String, postalCode: String, isDefault: Bool = false) {
        self.id = id
        // Linked to the id in the users table
        $user.id = userId
        self.street = street
        self.city = city
        self.state = state
        self.postalCode = postalCode
        self.isDefault = isDefault
    }
}
