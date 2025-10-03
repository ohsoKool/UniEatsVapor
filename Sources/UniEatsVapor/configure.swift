import Fluent
import FluentPostgresDriver
import NIOSSL
import Vapor

// configures your application
public func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    app.databases.use(DatabaseConfigurationFactory.postgres(configuration: .init(
        hostname: Environment.get("DATABASE_HOST") ?? "localhost",
        port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? SQLPostgresConfiguration.ianaPortNumber,
        username: Environment.get("DATABASE_USERNAME") ?? "vapor_username",
        password: Environment.get("DATABASE_PASSWORD") ?? "vapor_password",
        database: Environment.get("DATABASE_NAME") ?? "vapor_database",
        tls: .disable
        // transport layer security which is an encryption layer for securing the connection between vapor app and postgres db
        // disabled in development because we might encounter ssl is not trusted
    )
    ), as: .psql)

    app.migrations.add(CreateUser())
    app.migrations.add(CreateAddress())
    app.migrations.add(CreateVendor())
    app.migrations.add(CreateDocument())
    app.migrations.add(CreateRestaurant())
    app.migrations.add(CreateCoupon())
    app.migrations.add(CreateMenuCategory())
    app.migrations.add(CreateMenuItem())
    app.migrations.add(AddFullNameToUsers())
    app.migrations.add(RemoveOldFullNameAndAddTimestamps())

    // **Run migrations automatically**
    try await app.autoMigrate()

    // register routes
    try routes(app)
}
