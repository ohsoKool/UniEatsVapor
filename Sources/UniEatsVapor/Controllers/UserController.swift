import Fluent
import Vapor

struct UserController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let users = routes.grouped("users")
        users.post("send-otp", use: sendOtp)
        users.patch("verify-otp", use: verifyOtp)
    }
}

extension UserController {
    // --- Send OTP ---
    func sendOtp(req: Request) async throws -> HTTPStatus {
        let dto = try req.content.decode(SendOtpDTO.self)

        // 1. Generate a random 6-digit OTP
        let otpCode = String(Int.random(in: 111111 ... 999999))
        let expiry = Date().addingTimeInterval(5 * 60) // 5 minutes

        // 2. Save or update OTP record
        if let existingOtp = try await Otp.query(on: req.db)
            .filter(\.$mobile == dto.mobile)
            .first()
        {
            existingOtp.code = otpCode
            existingOtp.expiresAt = expiry
            try await existingOtp.save(on: req.db)
        } else {
            let otp = Otp(mobile: dto.mobile, code: otpCode, expiresAt: expiry)
            try await otp.save(on: req.db)
        }

        // 5. Create an instance of TwilioService
        //        let twilio = TwilioService(app: req.application)
        //        let otpMessage = "Welcome to MeritMeals!. Get ready to indulge in the world of aromatic flavours. Your OTP is \(otpCode)"
        //        // 6.Call sendSMS to send the message
        //        try await twilio.sendSMS(to: dto.mobile, body: otpMessage)

        return .ok
    }

    // --- Verify OTP ---
    func verifyOtp(req: Request) async throws -> User.ResponseDTO {
        let dto = try req.content.decode(VerifyOtpRequest.self)

        guard let storedOtp = try await Otp.query(on: req.db)
            .filter(\.$mobile == dto.mobile)
            .sort(\.$expiresAt, .descending)
            .first()
        else {
            throw Abort(.notFound, reason: "No OTP found for this number")
        }

        // 1. Check expiry
        guard storedOtp.expiresAt > Date() else {
            throw Abort(.unauthorized, reason: "OTP expired")
        }

        // 2. Check OTP code
        guard storedOtp.code == dto.otp else {
            throw Abort(.unauthorized, reason: "Invalid OTP")
        }

        // 3. Mark mobile as verified in User table (create if not exists)
        let user = try await User.query(on: req.db)
            .filter(\.$mobile == dto.mobile)
            .first() ?? User(mobile: dto.mobile, status: .verified)

        user.status = .verified
        try await user.save(on: req.db)

        // 4. Delete OTP after verification
        try await storedOtp.delete(on: req.db)

        // 5. Return user info
        return try user.asResponseDTO()
    }
}
