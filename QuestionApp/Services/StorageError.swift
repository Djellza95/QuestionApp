//
//  StorageError.swift
//  QuestionApp
//
//  Created by Djellza Rrustemi  on 2.4.25.
//


import Foundation

enum StorageError: Error {
    case saveFailed
    case loadFailed
    case noDataAvailable
}

class StorageService {
    static let shared = StorageService()
    private let contentKey = "cached_content"
    private let lastUpdateKey = "last_update_timestamp"
    
    private init() {}
    
    func saveContent(_ content: Item) throws {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(content)
            UserDefaults.standard.set(data, forKey: contentKey)
            UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: lastUpdateKey)
        } catch {
            throw StorageError.saveFailed
        }
    }
    
    func loadContent() throws -> Item {
        guard let data = UserDefaults.standard.data(forKey: contentKey) else {
            throw StorageError.noDataAvailable
        }
        
        let decoder = JSONDecoder()
        do {
            return try decoder.decode(Item.self, from: data)
        } catch {
            throw StorageError.loadFailed
        }
    }
    
    func getLastUpdateTimestamp() -> Date? {
        let timestamp = UserDefaults.standard.double(forKey: lastUpdateKey)
        return timestamp > 0 ? Date(timeIntervalSince1970: timestamp) : nil
    }
    
    func clearCache() {
        UserDefaults.standard.removeObject(forKey: contentKey)
        UserDefaults.standard.removeObject(forKey: lastUpdateKey)
    }
} 
