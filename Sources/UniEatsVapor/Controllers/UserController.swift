import Fluent
import Vapor

struct UserController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let users = routes.grouped("users")
        users.post(use: createUser)
        users.get(use: getAllUsers)
        users.get(":userId", use: getUser)
        users.put(":userId", use: updateUser)
        users.delete(":userId", use: deleteUser)
    }
}

extension UserController {
    func createUser(req: Request) async throws -> UserResponseDTO {
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

    func getUser(req: Request) async throws -> UserResponseDTO {
        // 1.Get the userId from the request parameter
        guard let userID = req.parameters.get("userId", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Missing userID")
        }
        // 2.Get the User from the database
        guard let user = try await User.find(userID, on: req.db) else {
            throw Abort(.notFound, reason: "User not found")
        }

        return UserResponseDTO(
            id: user.id!,
            fullName: user.fullName,
            email: user.email,
            mobile: user.mobile,
            dob: user.dob,
            gender: user.gender
        )
    }

    func updateUser(req: Request) async throws -> UserResponseDTO {
        // 1.Get the userId from the request parameter
        guard let userId = req.parameters.get("userId", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Missing user Id")
        }
        // 2. Decode input json into CreateUserDTO
        let dto = try req.content.decode(CreateUserDTO.self)

        // 3.Find the Existing User
        guard let user = try await User.find(userId, on: req.db) else {
            throw Abort(.notFound, reason: "User not found!")
        }

        // 4. Update User's fields with new data
        user.fullName = dto.fullName
        user.email = dto.email
        user.mobile = dto.mobile
        user.dob = dto.dob
        user.gender = dto.gender

        // 5. Save Updated User back to the Database
        try await user.save(on: req.db)

        // 6. Return response
        return UserResponseDTO(id: user.id!, fullName: user.fullName, email: user.email, mobile: user.mobile, dob: user.dob, gender: user.gender)
    }

    func getAllUsers(req: Request) async throws -> [UserResponseDTO] {
        let users = try await User.query(on: req.db).all()
        return users.map { user in
            UserResponseDTO(id: user.id!,
                            fullName: user.fullName,
                            email: user.email,
                            mobile: user.mobile,
                            dob: user.dob,
                            gender: user.gender)
        }
    }

    func deleteUser(req: Request) async throws -> HTTPStatus {
        guard let userId = req.parameters.get("userId", as: UUID.self) else {
            throw Abort(.notFound, reason: "Missing User Id")
        }
        guard let user = try await User.find(userId, on: req.db) else {
            throw Abort(.notFound, reason: "User Not Found")
        }
        try await user.delete(on: req.db)

        return .noContent
    }
}
