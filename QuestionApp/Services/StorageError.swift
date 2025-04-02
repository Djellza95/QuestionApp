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

class StorageService: StorageServiceProtocol {
    private let contentKey: String
    private let lastUpdateKey: String
    private let userDefaults: UserDefaults
    
    init(contentKey: String = "cached_content",
         lastUpdateKey: String = "last_update_timestamp",
         userDefaults: UserDefaults = .standard) {
        self.contentKey = contentKey
        self.lastUpdateKey = lastUpdateKey
        self.userDefaults = userDefaults
    }
    
    func saveContent(_ content: Item) throws {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(content)
            userDefaults.set(data, forKey: contentKey)
            userDefaults.set(Date().timeIntervalSince1970, forKey: lastUpdateKey)
        } catch {
            throw StorageError.saveFailed
        }
    }
    
    func loadContent() throws -> Item {
        guard let data = userDefaults.data(forKey: contentKey) else {
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
        let timestamp = userDefaults.double(forKey: lastUpdateKey)
        return timestamp > 0 ? Date(timeIntervalSince1970: timestamp) : nil
    }
    
    func clearCache() {
        userDefaults.removeObject(forKey: contentKey)
        userDefaults.removeObject(forKey: lastUpdateKey)
    }
} 
