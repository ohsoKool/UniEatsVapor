import Fluent
import Vapor

final class Otp: Model, Content, @unchecked Sendable {
    static let schema = "otps"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "mobile")
    var mobile: String

    @Field(key: "code")
    var code: String // Need to be hashed

    @Field(key: "expires_at")
    var expiresAt: Date

    init() {}

    init(mobile: String, code: String, expiresAt: Date) {
        self.mobile = mobile
        self.code = code
        self.expiresAt = expiresAt
    }
}
