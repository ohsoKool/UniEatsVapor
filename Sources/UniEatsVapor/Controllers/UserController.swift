import Fluent
import Vapor

struct UserController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let users = routes.grouped("users")
        users.post(use: create)
//        users.get(use: index)
//        users.get(":userId", use: get)
//        users.put(":userId", use: update)
//        users.delete(":userId", use: delete)
    }
}

extension UserController {
    func create(req: Request) async throws -> UserResponseDTO {
        // 1. Decode input JSON into CreateUserDTO
        let dto = try req.content.decode(CreateUserDTO.self)

        // 2.Map DTO to the database Model
        let user = User(fullName: dto.fullName, email: dto.email, mobile: dto.mobile,
                        dob: dto.dob, gender: dto.gender)

        // 3.Save to Database
        try await user.save(on: req.db)

        // 4.Convert back to response DTO
        return UserResponseDTO(
            id: user.id!,
            fullName: user.fullName,
            email: user.email,
            mobile: user.mobile,
            dob: user.dob,
            gender: user.gender
        )
    }
}
