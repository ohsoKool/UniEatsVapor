import Fluent
import Vapor

final class Address: Model, Content, @unchecked Sendable {
    static let schema = "addresses"

    @ID(key: .id)
    var id: UUID?

    // This tells Fluent: addresses table has a column userId which is a foreignkey pointing to users.id in the User mdoel
    // Doing this creates a backing proprety called _$user (used in the init)
    @Parent(key: "userId")
    var user: User

    @Field(key: "street")
    var street: String

    @Field(key: "city")
    var city: String

    @Field(key: "state")
    var state: String

    @Field(key: "postalCode")
    var postalCode: String

    @Field(key: "isDefault")
    var isDefault: Bool

    init() {}

    init(id: UUID? = nil, userId: UUID, street: String, city: String, state: String, postalCode: String, isDefault: Bool = false) {
        self.id = id
        // linked to the id in the users table
        self.$user.id = userId
        self.street = street
        self.city = city
        self.state = state
        self.postalCode = postalCode
        self.isDefault = isDefault
    }
}
