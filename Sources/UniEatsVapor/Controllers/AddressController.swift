import Fluent
import Vapor

struct AddressController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let addresses = routes.grouped("addresses") // This addresses in quotes describes the route name
        let users = addresses.grouped("user")
        users.post(":userId", use: createUserAddress)
        users.get(":userId", use: getAllUserAddresses)

        let single = addresses.grouped("address")
        single.patch(":addressId", use: updateAddressDetails)
        single.get(":addressId", use: getOneAddress)
        single.delete(":addressId", use: deleteUserAddress)
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
        let address = Address(
            userId: userId,
            name: dto.name,
            phoneNumber: dto.phoneNumber,
            instructions: dto.instructions,
            addressType: dto.addressType,
            street: dto.street,
            city: dto.city,
            state: dto.state,
            postalCode: dto.postalCode,
            isDefault: dto.isDefault
        )

        // 4. Save to database
        try await address.save(on: req.db)

        // 5. Return Response
        return AddressResponseDTO(
            id: address.id!,
            userId: address.$user.id,
            name: address.name,
            phoneNumber: address.phoneNumber,
            instructions: address.instructions,
            addressType: address.addressType,
            street: address.street,
            city: address.city,
            state: address.state,
            postalCode: address.postalCode,
            isDefault: address.isDefault
        )
    }

    func deleteUserAddress(req: Request) async throws -> HTTPStatus {
        // 1. Get the addressId of the address user is about to delete
        guard let addressId = req.parameters.get("addressId", as: UUID.self) else {
            throw Abort(.badRequest, reason: "AddressId not Found!")
        }
        // 2. Get the address record from the database
        guard let address = try await Address.find(addressId, on: req.db) else {
            throw Abort(.notFound, reason: "Address Details not Found!")
        }
        // 3. Delete the address record
        try await address.delete(on: req.db)

        // 4. Return
        return .noContent
    }

    func getAllUserAddresses(req: Request) async throws -> [AddressResponseDTO] {
        // 1. Get the userId from the req parameters
        guard let userId = req.parameters.get("userId", as: UUID.self) else {
            throw Abort(.badRequest, reason: "UserId missing!")
        }

        // 2. Ensure the user exists
        guard let user = try await User.find(userId, on: req.db) else {
            throw Abort(.notFound, reason: "User not Found!")
        }

        // 3. Retrieve all addresses for this user
        let addresses = try await Address.query(on: req.db)
            .filter(\.$user.$id == userId)
            .all()

        // 4. Map into DTOs
        return addresses.map { address in
            AddressResponseDTO(
                id: address.id!,
                userId: user.id!,
                name: address.name,
                phoneNumber: address.phoneNumber,
                instructions: address.instructions,
                addressType: address.addressType,
                street: address.street,
                city: address.city,
                state: address.state,
                postalCode: address.postalCode,
                isDefault: address.isDefault
            )
        }
    }

    func updateAddressDetails(req: Request) async throws -> AddressResponseDTO {
        // 1. Get the addressId from the req parameters
        guard let addressId = req.parameters.get("addressId", as: UUID.self) else {
            throw Abort(.badRequest, reason: "AddressId is required!")
        }
        // 2. Check whether Address exists in the record
        guard let address = try await Address.find(addressId, on: req.db) else {
            throw Abort(.notFound, reason: "Address not Found!")
        }
        // 3. Decode input into CreateAddressDTO
        let dto = try req.content.decode(CreateAddressDTO.self)

        // 4. Update values from DTO
        address.name = dto.name
        address.phoneNumber = dto.phoneNumber
        address.instructions = dto.instructions
        address.addressType = dto.addressType
        address.street = dto.street
        address.city = dto.city
        address.state = dto.state
        address.postalCode = dto.postalCode
        address.isDefault = dto.isDefault

        // 5. Save the details to the database
        try await address.save(on: req.db)

        // 6. Return the details of the address
        return AddressResponseDTO(
            id: address.id!,
            userId: address.$user.id,
            name: address.name,
            phoneNumber: address.phoneNumber,
            instructions: address.instructions,
            addressType: address.addressType,
            street: address.street,
            city: address.city,
            state: address.state,
            postalCode: address.postalCode,
            isDefault: address.isDefault
        )
    }

    func getOneAddress(req: Request) async throws -> AddressResponseDTO {
        // 1. Get the addressId from the req parameters
        guard let addressId = req.parameters.get("addressId", as: UUID.self) else {
            throw Abort(.badRequest, reason: "addressId is required!")
        }

        // 2. Check the database to see if the address record for the addressId actually exists
        guard let address = try await Address.find(addressId, on: req.db) else {
            throw Abort(.notFound, reason: "Address not found!")
        }

        return AddressResponseDTO(
            id: address.id!,
            userId: address.$user.id,
            name: address.name,
            phoneNumber: address.phoneNumber,
            instructions: address.instructions,
            addressType: address.addressType,
            street: address.street,
            city: address.city,
            state: address.state,
            postalCode: address.postalCode,
            isDefault: address.isDefault
        )
    }
}
