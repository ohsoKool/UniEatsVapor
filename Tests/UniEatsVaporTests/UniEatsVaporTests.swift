import Fluent
import Testing
@testable import UniEatsVapor
import VaporTesting

@Suite("App Tests with DB", .serialized)
struct UniEatsVaporTests {
    private func withApp(_ test: (Application) async throws -> ()) async throws {
        let app = try await Application.make(.testing)
        do {
            try await configure(app)
            try await app.autoMigrate()
            try await test(app)
            try await app.autoRevert()
        } catch {
            try? await app.autoRevert()
            try await app.asyncShutdown()
            throw error
        }
        try await app.asyncShutdown()
    }

    @Test("Test Hello World Route")
    func helloWorld() async throws {
        try await withApp { app in
            try await app.testing().test(.GET, "hello", afterResponse: { res async in
                #expect(res.status == .ok)
                #expect(res.body.string == "Hello, world!")
            })
        }
    }

    //    @Test("Creating a Todo")
    //    func createTodo() async throws {
    //        let newDTO = TodoDTO(id: nil, title: "test")
    //
    //        try await withApp { app in
    //            try await app.testing().test(.POST, "todos", beforeRequest: { req in
    //                try req.content.encode(newDTO)
    //            }, afterResponse: { res async throws in
    //                #expect(res.status == .ok)
    //                let models = try await Todo.query(on: app.db).all()
    //                #expect(models.map({ $0.toDTO().title }) == [newDTO.title])
    //            })
    //        }
    //    }
    //
}
