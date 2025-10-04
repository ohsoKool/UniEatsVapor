import Foundation
import Vapor

struct TwilioService {
    let accountSID: String
    let authToken: String
    let fromNumber: String
    let client: any Client
    
    init(app: Application) {
        // 1. Get the details from the Environment
        guard let sid = Environment.get("TWILIO_ACCOUNT_SID"),
              let token = Environment.get("TWILIO_AUTH_TOKEN"),
              let from = Environment.get("TWILIO_FROM_NUMBER")
        else {
            fatalError("Twilio credentials not set in environment")
        }
        
        self.accountSID = sid
        self.authToken = token
        self.fromNumber = from
        self.client = app.client
    }
    
    func sendSMS(to: String, body: String) async throws {
        // 2. Build the URL for Twilio's REST API
        let url = URI(string: "https://api.twilio.com/2010-04-01/Accounts/\(accountSID)/Messages.json")
        // 3. HTTP request setup
        var headers = HTTPHeaders()
        let authString = "\(accountSID):\(authToken)"
        let authData = Data(authString.utf8)
        let authBase64 = authData.base64EncodedString()
        headers.add(name: .authorization, value: "Basic \(authBase64)")
        headers.add(name: .contentType, value: "application/x-www-form-urlencoded")
        // 4. Build the message to be sent
        let body = "From=\(fromNumber)&To=\(to)&Body=\(body)"
        // 5.Construct a HTTP request
        let request = ClientRequest(
            method: .POST,
            url: url,
            headers: headers,
            body: .init(string: body)
        )
        
        // 6.Send the request
        let response = try await client.send(request)
        
        // 7.Check the status, If we get an error --> Display it using flatMap into errorBody
        guard response.status == .created else {
            let errorBody = response.body.flatMap { $0.getString(at: 0, length: $0.readableBytes) } ?? ""
            throw Abort(.internalServerError, reason: "Twilio SMS failed: \(errorBody)")
        }
    }
}
