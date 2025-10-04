import Vapor

struct SendOtpDTO: Content {
    let mobile: String
}

struct VerifyOtpRequest: Content {
    let mobile: String
    let otp: String
}

struct OtpResponseDTO: Content {
    let message: String
    let mobile: String
    let status: String?
}

struct CreateUserDTO: Content {
    let fullName: String?
    let email: String?
    let mobile: String
    let dobString: String? // receive date as string
    let gender: String?

    // Computed property converts string → Date using shared formatter
    var dob: Date? {
        guard let dobString else { return nil }
        return AppDateFormatter.shared.date(from: dobString)
    }
}

struct UserResponseDTO: Content {
    let id: UUID
    let fullName: String
    let email: String
    let mobile: String
    let dob: Date?
    let gender: String?
}
