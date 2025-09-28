import Fluent
import Vapor

final class Vendor: Model, Content, @unchecked Sendable {
    static let schema = "vendors"

    @ID(key: .id) var id: UUID?

    @Field(key: "full_name") var fullName: String
    @Field(key: "email") var email: String
    @Field(key: "mobile") var mobile: String
    @Field(key: "street") var street: String
    @Field(key: "city") var city: String
    @Field(key: "state") var state: String
    @Field(key: "postal_code") var postalCode: String

    @Timestamp(key: "created_at", on: .create) var createdAt: Date?
    @Timestamp(key: "updated_at", on: .update) var updatedAt: Date?
    @Timestamp(key: "deleted_at", on: .delete) var deletedAt: Date?

    @Children(for: \.$vendor) var documents: [Document]
    @Children(for: \.$vendor) var restaurants: [Restaurant]
    @Children(for: \.$vendor) var coupons: [Coupon]

    init() {}

    init(id: UUID? = nil, fullName: String, email: String, mobile: String, street: String, city: String, state: String, postalCode: String) {
        self.id = id
        self.fullName = fullName
        self.email = email
        self.mobile = mobile
        self.street = street
        self.city = city
        self.state = state
        self.postalCode = postalCode
    }
}
