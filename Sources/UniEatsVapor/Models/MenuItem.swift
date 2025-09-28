import Fluent
import Vapor

final class MenuItem: Model, Content, @unchecked Sendable {
    static let schema = "menu_items"
    
    @ID(key: .id) var id: UUID?
    @Field(key: "item_name") var itemName: String
    @Field(key: "price") var price: Double
    @Field(key: "description") var description: String
    @Field(key: "is_available") var isAvailable: Bool
    @Field(key: "item_image") var itemImage: String
    // Tags stored as a string array (JSONB/Array column in Postgres)
    @Field(key: "tags") var tags: [String]
    
    @Parent(key: "menu_category_id") var menuCategory: MenuCategory
    
    @Timestamp(key: "created_at", on: .create) var createdAt: Date?
    @Timestamp(key: "updated_at", on: .update) var updatedAt: Date?
    
    init() {}
    
    init(
        id: UUID? = nil,
        itemName: String,
        price: Double,
        description: String,
        isAvailable: Bool,
        itemImage: String,
        tags: [String],
        menu_category_id: UUID
    ) {
        self.id = id
        self.itemName = itemName
        self.price = price
        self.description = description
        self.isAvailable = isAvailable
        self.itemImage = itemImage
        self.tags = tags
        self.$menuCategory.id = menu_category_id
    }
}
