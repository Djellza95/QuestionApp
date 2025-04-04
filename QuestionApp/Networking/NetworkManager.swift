//
//  NetworkManager.swift
//  QuestionApp
//
//  Created by Djellza Rrustemi  on 2.4.25.
//


import Foundation
import Alamofire

class NetworkManager {
    static let shared = NetworkManager()
    
    private init() {}
    
    private let baseURL = "https://run.mocky.io/v3/610625ad-825b-40c6-a49a-85ce78cdcd73"
    
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
