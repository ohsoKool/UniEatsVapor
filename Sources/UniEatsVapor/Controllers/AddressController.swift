import Fluent
import Vapor

struct AddressController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let addresses = routes.grouped("addresses") // This addresses in quotes describes the route name
        addresses.post(":userId", use: createUserAddress)
    }
}

extension AddressController {
    func createUserAddress(req: Request) async throws -> AddressResponseDTO {
        // 1. Get userId from the parameters
        guard let userId = req.parameters.get("userId", as: UUID.self) else {
            throw Abort(.badRequest, reason: "User Id is required!")
        }

        guard let user = try await User.find(userId, on: req.db) else {
            throw Abort(.notFound, reason: "User not found!")
        }

        // 2. Decode req body into CreateAddressDTO
        let dto = try req.content.decode(CreateAddressDTO.self)

        // 3. Map DTO to database model
        let address = Address(userId: userId, street: dto.street, city: dto.city, state: dto.state, postalCode: dto.postalCode, isDefault: dto.isDefault)
        // 4. Save to database
        try await address.save(on: req.db)

        // 5.Return Response
        return AddressResponseDTO(id: address.id!, userId: address.$user.id, street: address.street, city: address.city, state: address.state, postalCode: address.postalCode, isDefault: address.isDefault)
    }
}
