import Fluent
import Vapor

enum DocumentStatus: String, Codable {
    case pending, accepted, rejected
}

final class Document: Model, Content, @unchecked Sendable {
    static let schema = "documents"

    @ID(key: .id) var id: UUID?
    @Parent(key: "vendor_id") var vendor: Vendor

    @Field(key: "business_license") var businessLicense: String
    @Field(key: "pan") var pan: String
    @Field(key: "gst") var gst: String
    @Field(key: "bank_statement") var bankStatement: String
    @Field(key: "expiry_date") var expiryDate: Date

    @OptionalField(key: "verified_on") var verifiedOn: Date?
    @Enum(key: "status") var status: DocumentStatus
    @OptionalField(key: "note") var note: String?

    @Timestamp(key: "created_at", on: .create) var createdAt: Date?
    @Timestamp(key: "updated_at", on: .update) var updatedAt: Date?
    @Timestamp(key: "deleted_at", on: .delete) var deletedAt: Date?

    init() {}

    init(id: UUID? = nil, vendorId: UUID, businessLicense: String, pan: String, gst: String, bankStatement: String, expiryDate: Date, status: DocumentStatus = .pending, verifiedOn: Date? = nil, note: String? = nil) {
        self.id = id
        self.$vendor.id = vendorId
        self.businessLicense = businessLicense
        self.pan = pan
        self.gst = gst
        self.bankStatement = bankStatement
        self.expiryDate = expiryDate
        self.status = status
        self.verifiedOn = verifiedOn
        self.note = note
    }
}
