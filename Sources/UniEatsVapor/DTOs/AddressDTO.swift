import Fluent
import Vapor

struct CreateAddressDTO: Content {
    let name: String? // Name for someone else
    let phoneNumber: String? // Phone number
    let instructions: String? // Delivery instructions
    let addressType: String // Home / Work / Other
    let street: String
    let city: String
    let state: String
    let postalCode: String
    let isDefault: Bool
}

struct AddressResponseDTO: Content {
    let id: UUID
    let userId: UUID
    let name: String?
    let phoneNumber: String?
    let instructions: String?
    let addressType: String
    let street: String
    let city: String
    let state: String
    let postalCode: String
    let isDefault: Bool
}
