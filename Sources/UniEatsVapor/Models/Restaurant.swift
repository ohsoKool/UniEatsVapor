import Fluent
import Vapor

final class Restaurant: Model, Content, @unchecked Sendable {
    static let schema = "restaurants"

    @ID(key: .id) var id: UUID?
    @Parent(key: "vendor_id") var vendor: Vendor

    @Field(key: "name") var name: String
    @Field(key: "street") var street: String
    @Field(key: "city") var city: String
    @Field(key: "state") var state: String
    @Field(key: "postal_code") var postalCode: String
    @Field(key: "rating") var rating: Double
    @Field(key: "is_pure_veg") var isPureVeg: Bool
    @Field(key: "cuisine") var cuisine: String

    @Timestamp(key: "created_at", on: .create) var createdAt: Date?
    @Timestamp(key: "updated_at", on: .update) var updatedAt: Date?
    @Timestamp(key: "deleted_at", on: .delete) var deletedAt: Date?

    @Children(for: \.$restaurant)
    var menuCategories: [MenuCategory]

    init() {}

    init(id: UUID? = nil, vendorId: UUID, name: String, street: String, city: String, state: String, postalCode: String, rating: Double, isPureVeg: Bool, cuisine: String) {
        self.id = id
        self.$vendor.id = vendorId
        self.name = name
        self.street = street
        self.city = city
        self.state = state
        self.postalCode = postalCode
        self.rating = rating
        self.isPureVeg = isPureVeg
        self.cuisine = cuisine
    }
}
