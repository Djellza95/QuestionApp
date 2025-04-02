import Foundation

protocol StorageServiceProtocol {
    func saveContent(_ content: Item) throws
    func loadContent() throws -> Item
    func getLastUpdateTimestamp() -> Date?
    func clearCache()
} 