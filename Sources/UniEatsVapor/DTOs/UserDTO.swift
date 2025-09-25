import Vapor

struct CreateUserDTO: Content {
    let fullName: String
    let email: String
    let mobile: String
    let dob: Date?
    let gender: String?
}

struct UserResponseDTO: Content {
    let id: UUID
    let fullName: String
    let email: String
    let mobile: String
    let dob: Date?
    let gender: String?
}
