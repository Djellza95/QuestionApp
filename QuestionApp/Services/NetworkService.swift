import Foundation
import Alamofire

protocol NetworkServiceProtocol {
    func fetchContent() async throws -> Item
}

class NetworkService: NetworkServiceProtocol {
    private let baseURL: String
    
    init(baseURL: String = "https://run.mocky.io/v3/610625ad-825b-40c6-a49a-85ce78cdcd73") {
        self.baseURL = baseURL
    }
    
    func fetchContent() async throws -> Item {
        return try await withCheckedThrowingContinuation { continuation in
            AF.request(baseURL)
                .validate()
                .responseDecodable(of: Item.self) { response in
                    if let data = response.data, let str = String(data: data, encoding: .utf8) {
                        print("Response Data: \(str)")
                    }
                    if let error = response.error {
                        print("Error: \(error)")
                    }
                    
                    switch response.result {
                    case .success(let content):
                        print("Success: Received content")
                        continuation.resume(returning: content)
                    case .failure(let error):
                        print("Failure: \(error)")
                        continuation.resume(throwing: error)
                    }
                }
        }
    }
} 