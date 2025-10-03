import Vapor

struct CreateDocumentDTO: Content {
    let businessLicense: String
    let pan: String
    let gst: String
    let bankStatement: String
}

struct DocumentResponseDTO: Codable {
    let id: UUID
    let verifiedOn: Date?
    let expiryDate: Date
    let status: DocumentStatus
}
