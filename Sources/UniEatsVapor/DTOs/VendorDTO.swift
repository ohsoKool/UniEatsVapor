import Vapor

struct CreateVendorDTO: Content {
    let fullName: String
    let email: String
    let mobile: String
    let street: String
    let city: String
    let state: String
    let postalCode: String
    let expiryDateString: String // received from client
    // Document info (flattened because multipart can’t do nested)
//    let documents: CreateDocumentDTO
}

struct VendorResponseDTO: Content {
    let id: UUID
    let fullName: String
    let documents: DocumentResponseDTO
}
