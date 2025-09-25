import Vapor

struct CreateUserDTO: Content {
    let fullName: String
    let email: String
    let mobile: String
    let dobString: String? // receive date as string
    let gender: String?

    var dob: Date? {
        guard let dobString else { return nil }
        return CreateUserDTO.dateFormatter.date(from: dobString)
    }

    // Static formatter means it's initialized once and reused everywhere
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        // en_US_POSIX locale makes sure it parses reliabily independant of system settings
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
}

struct UserResponseDTO: Content {
    let id: UUID
    let fullName: String
    let email: String
    let mobile: String
    let dob: Date?
    let gender: String?
}
