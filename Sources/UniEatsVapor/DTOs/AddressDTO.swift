import Vapor

struct CreateAddressDTO: Content {
//    let userId: UUID
    let street: String
    let city: String
    let state: String
    let postalCode: String
    let isDefault: Bool
}

struct AddressResponseDTO: Content {
    let id: UUID
    let userId: UUID
    let street: String
    let city: String
    let state: String
    let postalCode: String
    let isDefault: Bool
}
