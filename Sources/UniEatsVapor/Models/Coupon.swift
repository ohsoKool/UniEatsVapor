import Fluent
import Vapor

enum DiscountType: String, Codable {
    case percentage, amount
}

final class Coupon: Model, Content, @unchecked Sendable {
    static let schema = "coupons"

    @ID(key: .id) var id: UUID?
    @Parent(key: "vendor_id") var vendor: Vendor

    @Field(key: "code") var code: String
    @Field(key: "description") var couponDescription: String
    @Field(key: "discount_type") var discountType: DiscountType
    @Field(key: "discount_value") var discountValue: Int
    @Field(key: "is_active") var isActive: Bool
    @Field(key: "max_uses") var maxUses: Int
    @Field(key: "min_cart_value") var minCartValue: Double

    @Timestamp(key: "created_at", on: .create) var createdAt: Date?
    @Timestamp(key: "updated_at", on: .update) var updatedAt: Date?
    @Timestamp(key: "deleted_at", on: .delete) var deletedAt: Date?

    init() {}

    init(id: UUID? = nil, vendorId: UUID, code: String, couponDescription: String, discountType: DiscountType, discountValue: Int, isActive: Bool, maxUses: Int, minCartValue: Double) {
        self.id = id
        self.$vendor.id = vendorId
        self.code = code
        self.couponDescription = couponDescription
        self.discountType = discountType
        self.discountValue = discountValue
        self.isActive = isActive
        self.maxUses = maxUses
        self.minCartValue = minCartValue
    }
}
