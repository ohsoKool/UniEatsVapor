import Fluent
import Vapor

final class Address: Model, Content, @unchecked Sendable {
    static let schema = "addresses"

    @ID(key: .id) var id: UUID?

    @Field(key: "name") var name: String? // Name for someone else
    @Field(key: "phone_number") var phoneNumber: String? // Phone number
    @Field(key: "instructions") var instructions: String? // Delivery instructions
    @Field(key: "address_type") var addressType: String // Home / Work / Other
    @Field(key: "street") var street: String
    @Field(key: "city") var city: String
    @Field(key: "state") var state: String
    @Field(key: "postal_code") var postalCode: String
    @Field(key: "is_default") var isDefault: Bool

    // This tells Fluent: addresses table has a column user_id (snake_case) which is a foreign key pointing to users.id in the User model
    @Parent(key: "user_id") var user: User

    @Timestamp(key: "created_at", on: .create) var createdAt: Date?
    @Timestamp(key: "updated_at", on: .update) var updatedAt: Date?
    @Timestamp(key: "deleted_at", on: .delete) var deletedAt: Date?

    init() {}

    init(
        id: UUID? = nil,
        userId: UUID,
        name: String? = nil,
        phoneNumber: String? = nil,
        instructions: String? = nil,
        addressType: String = "Home",
        street: String,
        city: String,
        state: String,
        postalCode: String,
        isDefault: Bool = false
    ) {
        self.id = id
        self.$user.id = userId
        self.name = name
        self.phoneNumber = phoneNumber
        self.instructions = instructions
        self.addressType = addressType
        self.street = street
        self.city = city
        self.state = state
        self.postalCode = postalCode
        self.isDefault = isDefault
    }
}
