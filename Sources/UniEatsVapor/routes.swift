import Vapor

func routes(_ app: Application) throws {
    // Allow larger uploads (e.g., 20 MB)
    app.routes.defaultMaxBodySize = "20mb"

    // Load secrets from environment
    guard
        let projectURL = Environment.get("SUPABASE_PROJECT_URL"),
        let serviceRoleKey = Environment.get("SUPABASE_SERVICE_ROLE")
    else {
        fatalError("Supabase environment variables not set")
    }

    let storage = SupabaseStorage(
        projectURL: projectURL,
        serviceRoleKey: serviceRoleKey
    )

    try app.register(collection: UserController())
    try app.register(collection: AddressController())
    try app.register(collection: VendorController(storage: storage))

    app.get("hello") { _ in
        "👋 Hello from Vapor backend!"
    }
}
