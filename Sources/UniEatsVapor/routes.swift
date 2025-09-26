import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.get { _ async in
        "It works!"
    }
    try app.register(collection: UserController())
    try app.register(collection: AddressController())
}
