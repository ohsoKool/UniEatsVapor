import Fluent
import Vapor

final class MenuCategory: Model, Content, @unchecked Sendable {
    static let schema = "menu_categories"
    
    @ID(key: .id) var id: UUID?
    @Field(key: "category_name") var categoryName: String
    
    @Parent(key: "restaurant_id") var restaurant: Restaurant
    @Children(for: \.$menuCategory) var menuItems: [MenuItem]
    
    @Timestamp(key: "created_at", on: .create) var createdAt: Date?
    @Timestamp(key: "updated_at", on: .update) var updatedAt: Date?
    
    init() {}
    
    init(id: UUID? = nil, restaurant_id: UUID, categoryName: String) {
        self.id = id
        self.categoryName = categoryName
        self.$restaurant.id = restaurant_id
    }
}
