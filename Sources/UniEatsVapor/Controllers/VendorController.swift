import Fluent
import PostgresKit
import Vapor

struct VendorController: RouteCollection {
    let storage: SupabaseStorage

    // let storage = SupabaseStorage(projectURL: "...", serviceRoleKey: "...")
    // The above method is not preferred for security reasons. Instead, inject via initializer.
    init(storage: SupabaseStorage) {
        self.storage = storage
    }

    func boot(routes: any RoutesBuilder) throws {
        let vendors = routes.grouped("vendors")
        vendors.post(use: create)
    }
}

extension VendorController {
    func create(req: Request) async throws -> VendorResponseDTO {
        // Decode input into CreateVendorDTO
        let dto = try req.content.decode(CreateVendorDTO.self)
//        Vapor cannot decode nested structs from multipart requests the same way it can decode JSON.

        // Convert string to Date
        guard let expiryDate = AppDateFormatter.shared.date(from: dto.expiryDateString) else {
            throw Abort(.badRequest, reason: "Invalid expiry date format")
        }

        // Run everything in a database transaction to avoid partial saves
        return try await req.db.transaction { db in
            // Store in a variable and save
            let vendor = Vendor(
                fullName: dto.fullName,
                email: dto.email,
                mobile: dto.mobile,
                street: dto.street,
                city: dto.city,
                state: dto.state,
                postalCode: dto.postalCode
            )

            // Handle Error to check unique violation
            do {
                try await vendor.save(on: db)
            } catch {
                if let postgresError = error as? PostgresError, postgresError.code == .uniqueViolation {
                    throw Abort(.conflict, reason: "A vendor with these details already exists.")
                }
                throw error
            }

            // Ensure vendor ID exists
            guard let vendorId = vendor.id else {
                throw Abort(.internalServerError, reason: "Failed to save vendor ID")
            }

            // Upload files in parallel
            async let businessLicenseUrl = storage.handleMultipartUpload(
                req: req, bucket: "unieats-private", fileField: "businessLicense", fileNamePrefix: "vendor-businessLicense"
            )
            async let panUrl = storage.handleMultipartUpload(
                req: req, bucket: "unieats-private", fileField: "pan", fileNamePrefix: "vendor-pan"
            )
            async let gstUrl = storage.handleMultipartUpload(
                req: req, bucket: "unieats-private", fileField: "gst", fileNamePrefix: "vendor-gst"
            )
            async let bankStatementUrl = storage.handleMultipartUpload(
                req: req, bucket: "unieats-private", fileField: "bankStatement", fileNamePrefix: "vendor-bankStatement"
            )

            // Await uploaded URLs
            let businessLicense = try await businessLicenseUrl
            let pan = try await panUrl
            let gst = try await gstUrl
            let bankStatement = try await bankStatementUrl

            // Save document
            let documents = Document(
                vendorId: vendorId,
                businessLicense: businessLicense,
                pan: pan,
                gst: gst,
                bankStatement: bankStatement,
                expiryDate: expiryDate
            )
            try await documents.save(on: db)

            let documentDto = DocumentResponseDTO(
                id: documents.id!,
                verifiedOn: documents.verifiedOn,
                expiryDate: documents.expiryDate,
                status: documents.status
            )

            return VendorResponseDTO(
                id: vendorId,
                fullName: vendor.fullName,
                documents: documentDto
            )
        }
    }
}
