// Complete flow for file upload:
// 1. Client sends a multipart/form-data POST request with the file.
// 2. The handleMultipartUpload function extracts the file from the request.
// 3. It converts the file data to Swift's Data type and generates a unique filename
// 4. Calls uploadFile to perform the actual upload to Supabase Storage.
// 5. uploadFile constructs the appropriate URL, sets headers, and sends the PUT request
// 6. If successful, it returns the public URL of the uploaded file.

// Instead of converting the data received to handleMultipartUpload from ByteBuffer to Swift's Data and then convert it to Vapor's HTTPBody - We can directly pass the file.data as ByteBuffer to the uploadFile function but the advantage of converting is that we can easily manipulate the data if needed in future (like compressing images etc) using Swift's Data APIs

import Foundation
import Vapor

struct SupabaseStorage { // Container for Supabase Storage
    let projectURL: String // Project URL --> tells which Supabase project to use
    let serviceRoleKey: String // Secret Key which makes sure the request is authenticated
    
    // --- Low-level upload function ---
    func uploadFile(
        data: Data, // File binary data
        fileName: String, // To name it for proper storage
        bucket: String, // which bucket to choose from
        on req: Request
    ) async throws -> String { // return type string
        // Construct the URL for the Supabase Storage API
        guard let url = URL(string: "\(projectURL)/storage/v1/object/\(bucket)/\(fileName)") else {
            throw Abort(.internalServerError, reason: "Invalid URL")
        }
        
        // convert url to vapors URI type because vapor prefers URI so it can handle HTTP-specific details like path, query, port etc
        let response = try await req.client.put(URI(string: url.absoluteString)) { req in
            // url.absoluteString converts the url into string and then string is converted to URI
            // Configuring the client request
            
            // Here .init is a initializer for HTTPBody which takes (Swift)data as input and converts it to ByteBuffer which vapor can send over HTTP
            req.body = .init(data: data)
            // Adding Authorization header with Bearer token
            req.headers.add(name: "Authorization", value: "Bearer \(serviceRoleKey)")
            // Tells the server we're sending raw bytes
            req.headers.add(name: "Content-Type", value: "application/octet-stream")
        }
        
        // Check if the upload was successful
        guard response.status == .ok else {
            // If not successful, extract the response body for debugging
            let body = response.body.flatMap { String(buffer: $0) } ?? "No response body"
            throw Abort(.internalServerError, reason: "Upload failed: \(body)")
        }
        
        // Returning back the URL so that it's understood universally
        return "\(projectURL)/storage/v1/object/public/\(bucket)/\(fileName)"
    }
    
    // --- Reusable Multipart upload utility ---
    func handleMultipartUpload(
        req: Request,
        bucket: String,
        fileField: String = "file",
        fileNamePrefix: String = "file"
    ) async throws -> String {
        // Vapor lets you access multipart/form-data uploads via the below line
        let file = try req.content.get(File.self, at: fileField)
        // file has data and filename properties
        
        // Converts the file’s ByteBuffer into Swift’s Data type because uploadFile expects Data as input
        let data = Data(buffer: file.data)
        
        // Extract and preserve original file extension
        let fileExtension = (file.filename as NSString?)?.pathExtension ?? "dat"
        // Create a unique file name using UUID to avoid collisions
        let fileName = "\(fileNamePrefix)-\(UUID().uuidString).\(fileExtension)"
        
        // Upload to Supabase
        let uploadedURL = try await uploadFile(data: data, fileName: fileName, bucket: bucket, on: req)
        
        return uploadedURL
    }
}
