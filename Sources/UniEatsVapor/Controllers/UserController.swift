import Fluent
import Logging
import Vapor

struct UserController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let users = routes.grouped("users")

//        users.post(use: createUser)
//        users.get(use: getAllUsers)
//        users.get(":userId", use: getUser)
//        users.put(":userId", use: updateUser)
//        users.delete(":userId", use: deleteUser)
//        users.patch(":userId", ":vendorId", use: verifyVendor)
        users.post("send-otp", use: SendOtp)
        users.patch("verify-otp", use: verifyOtp)
    }
}

extension UserController {
    func SendOtp(req: Request) async throws -> HTTPStatus {
        // --- Updated Logic for OTP Flow ---

        // 1. Decode input into SendOtpDTO
        let dto = try req.content.decode(SendOtpDTO.self)

        // 3.Generate a random six digit number from 111111 to 999999
        let otpCode = String(Int.random(in: 111111 ... 999999))

        // 3.Set the expiry for the otp
        let expiry = Date().addingTimeInterval(5 * 60) // 5 minutes

        // 4. Create/update OTP record
        if let existing = try await Otp.query(on: req.db)
            .filter(\.$mobile == dto.mobile)
            .first()
        {
            existing.code = otpCode
            existing.expiresAt = expiry
            try await existing.save(on: req.db)
        } else {
            let otp = Otp(mobile: dto.mobile, code: otpCode, expiresAt: expiry)
            try await otp.save(on: req.db)
        }

        // 5. Create an instance of TwilioService
        let twilio = TwilioService(app: req.application)
        let otpMessage = "Welcome to MeritMeals!. Get ready to indulge in the world of aromatic flavours. Your OTP is \(otpCode)"
        // 6.Call sendSMS to send the message
        try await twilio.sendSMS(to: dto.mobile, body: otpMessage)
        return .ok
    }

    func verifyOtp(req: Request) async throws -> Response {
        // 1. Decode input into VerifyOtpRequest
        let dto = try req.content.decode(VerifyOtpRequest.self)

        // 2. fetch the stored Otp from the database
        guard let storedOtp = try await Otp.query(on: req.db)
            .filter(\.$mobile == dto.mobile)
            .sort(\.$expiresAt, .descending)
            .first()
        else {
            throw Abort(.notFound, reason: "No OTP found for this number")
        }

        // 3. Check for the expiry of the otp
        guard storedOtp.expiresAt > Date() else {
            throw Abort(.unauthorized, reason: "OTP Expired!")
        }

        // 4. Check for invalid otp
        guard storedOtp.code == dto.otp else {
            throw Abort(.unauthorized, reason: "Invalid OTP!")
        }

        // 5. Create a record into the User table
        let user = try await User.query(on: req.db)
            .filter(\.$mobile == dto.mobile)
            .first() ?? User(mobile: dto.mobile, status: .verified)

        user.status = .verified

        try await user.save(on: req.db)
        req.logger.info("User saved: \(user)")
        // 6. Save the User to the database and delete the otp
        try await storedOtp.delete(on: req.db)

        // 7. Converts the user to the DTO (resDto) to ensure a clean API response.
//        encodeResponse(status:for:) sends this DTO back as a HTTP response with a 200 OK status.
        let resDto = try user.asResponseDTO()
//         similar to res.status(200).json(resDto)
        return try await resDto.encodeResponse(status: HTTPStatus.ok, for: req)
    }

//    func getUser(req: Request) async throws -> UserResponseDTO {
//        // 1.Get the userId from the request parameter
//        guard let userID = req.parameters.get("userId", as: UUID.self) else {
//            throw Abort(.badRequest, reason: "Missing userID")
//        }
//        // 2.Get the User from the database
//        guard let user = try await User.find(userID, on: req.db) else {
//            throw Abort(.notFound, reason: "User not found")
//        }
//
//        return UserResponseDTO(
//            id: user.id!,
//            fullName: user.fullName",
//            email: user.email,
//            mobile: user.mobile,
//            dob: user.dob,
//            gender: user.gender
//        )
//    }
//
//    func updateUser(req: Request) async throws -> UserResponseDTO {
//        // 1.Get the userId from the request parameter
//        guard let userId = req.parameters.get("userId", as: UUID.self) else {
//            throw Abort(.badRequest, reason: "Missing user Id")
//        }
//        // 2. Decode input json into CreateUserDTO
//        let dto = try req.content.decode(CreateUserDTO.self)
//
//        // 3.Find the Existing User
//        guard let user = try await User.find(userId, on: req.db) else {
//            throw Abort(.notFound, reason: "User not found!")
//        }
//
//        // 4. Update User's fields with new data
//        user.fullName = dto.fullName
//        user.email = dto.email
//        user.mobile = dto.mobile
//        user.dob = dto.dob
//        user.gender = dto.gender
//
//        // 5. Save Updated User back to the Database
//        try await user.save(on: req.db)
//
//        // 6. Return response
//        return UserResponseDTO(id: user.id!, fullName: user.fullName, email: user.email, mobile: user.mobile, dob: user.dob, gender: user.gender)
//    }
//
//    func getAllUsers(req: Request) async throws -> [UserResponseDTO] {
//        let users = try await User.query(on: req.db).all()
//        return users.map { user in
//            UserResponseDTO(id: user.id!,
//                            fullName: user.fullName,
//                            email: user.email,
//                            mobile: user.mobile,
//                            dob: user.dob,
//                            gender: user.gender)
//        }
//    }
//
//    func deleteUser(req: Request) async throws -> HTTPStatus {
//        guard let userId = req.parameters.get("userId", as: UUID.self) else {
//            throw Abort(.notFound, reason: "Missing User Id")
//        }
//        guard let user = try await User.find(userId, on: req.db) else {
//            throw Abort(.notFound, reason: "User Not Found")
//        }
//        try await user.delete(on: req.db)
//
//        return .noContent
//    }
//
//    func verifyVendor(req: Request) async throws -> String {
//        // 1. Get Both userId and vendorId from the request parameters
//        guard
//            // Both userId and vendorId must exist
//            let userId = req.parameters.get("userId", as: UUID.self),
//            let vendorId = req.parameters.get("vendorId", as: UUID.self)
//        else {
//            throw Abort(.badRequest, reason: "userId and vendorId are required!")
//        }
//
//        // 2. Check whether the user is present or not
//        guard let user = try await User.find(userId, on: req.db) else {
//            throw Abort(.notFound, reason: "User not found!")
//        }
//
//        // 3. Check whether the vendor exists or not
//        guard let vendor = try await Vendor.find(vendorId, on: req.db) else {
//            throw Abort(.notFound, reason: "Vendor not found!")
//        }
//
//        // 4.Update the status of the Vendor Documents as accepted
//        try await Document.query(on: req.db)
//            .filter(\.$vendor.$id == vendorId)
//            .set(\.$status, to: .accepted)
//            .set(\.$verifiedOn, to: Date())
//            .update()
//
//        return "User has been successfully verified as a vendor."
//    }
}
