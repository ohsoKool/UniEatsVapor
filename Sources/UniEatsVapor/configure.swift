import Fluent
import FluentPostgresDriver
import NIOSSL
import Vapor

// configures your application
public func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    // Configure database connection using environment variables
    // Falls back to defaults for local development
    app.databases.use(DatabaseConfigurationFactory.postgres(configuration: .init(
        hostname: Environment.get("DATABASE_HOST") ?? "localhost",
        port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? SQLPostgresConfiguration.ianaPortNumber,
        username: Environment.get("DATABASE_USERNAME") ?? "vapor_username",
        password: Environment.get("DATABASE_PASSWORD") ?? "vapor_password",
        database: Environment.get("DATABASE_NAME") ?? "vapor_database",
        tls: .disable // disabled in development to avoid SSL certificate issues
    )), as: .psql)

    // Register database migrations
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
    app.migrations.add(UpdateAddressSchema())
    app.migrations.add(UpdateUserIdField())
    app.migrations.add(AddTimestampsToAddress())
    app.migrations.add(CreateOtp())
    app.migrations.add(addStatusToUsers())

    // **Run migrations automatically**
    try await app.autoMigrate()

    // -----------------------------------------
    // SERVER CONFIGURATION FOR RENDER DEPLOYMENT
    // -----------------------------------------
    // Render provides PORT environment variable; fallback to 8080 locally
    let port = Environment.get("PORT").flatMap(Int.init) ?? 8080
    app.http.server.configuration.port = port
    app.http.server.configuration.hostname = "0.0.0.0"

    // register routes
    try routes(app)
}
