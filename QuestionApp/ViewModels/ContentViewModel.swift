//
//  ContentViewModel.swift
//  QuestionApp
//
//  Created by Djellza Rrustemi  on 2.4.25.
//


import Foundation
import UIKit
import Alamofire

class ContentViewModel {
    // MARK: - Types
    enum State {
        case loading
        case loaded
        case error(Error)
    }
    
    enum NetworkError: Error, LocalizedError {
        case offline
        case serverError
        case invalidData
        case poorConnection
        
        var errorDescription: String? {
            switch self {
            case .offline:
                return "No internet connection available"
            case .serverError:
                return "Unable to fetch content from server"
            case .invalidData:
                return "Received invalid data from server"
            case .poorConnection:
                return "Poor network connection"
            }
        }
    }
    
    // MARK: - Properties
    private(set) var items: [Item] = []
    var onStateChange: ((State) -> Void)?
    private let networkService: NetworkServiceProtocol
    private let storageService: StorageServiceProtocol
    private let networkTimeout: TimeInterval = 10.0 // 10 seconds timeout
    private var isRetrying = false
    private var retryCount = 0
    private let maxRetries = 3
    
    // MARK: - Initialization
    init(networkService: NetworkServiceProtocol, storageService: StorageServiceProtocol) {
        self.networkService = networkService
        self.storageService = storageService
    }
    
    // MARK: - Public Methods
    func fetchContent(forceRefresh: Bool = false) {
        if !forceRefresh && !items.isEmpty {
            // Use cached data if available and not forcing refresh
            onStateChange?(.loaded)
            return
        }
        
        guard isNetworkReachable() || isRetrying else {
            loadOfflineContent()
            return
        }
        
        onStateChange?(.loading)
        
        Task {
            do {
                let content = try await networkService.fetchContent()
                self.items = content.items ?? []
                self.isRetrying = false
                self.retryCount = 0
                // Save content for offline use
                try? self.storageService.saveContent(content)
                self.onStateChange?(.loaded)
            } catch {
                // Handle different types of network failures
                if let underlyingError = error as NSError? {
                    switch underlyingError.code {
                    case NSURLErrorTimedOut, NSURLErrorNetworkConnectionLost, NSURLErrorNotConnectedToInternet:
                        // Connection issues - try to retry
                        self.handleConnectionFailure()
                    default:
                        // Other errors - fallback to offline content
                        self.handleOtherFailure(error)
                    }
                } else {
                    self.handleOtherFailure(error)
                }
            }
        }
    }
    
    private func handleConnectionFailure() {
        if retryCount < maxRetries {
            retryCount += 1
            isRetrying = true
            // Exponential backoff: 2, 4, 8 seconds
            let delay = Double(pow(2.0, Double(retryCount)))
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
                self?.fetchContent(forceRefresh: true)
            }
        } else {
            // Max retries reached, fallback to offline content
            isRetrying = false
            retryCount = 0
            loadOfflineContent()
        }
    }
    
    private func handleOtherFailure(_ error: Error) {
        isRetrying = false
        retryCount = 0
        
        // Try to load offline content first
        if !items.isEmpty {
            onStateChange?(.error(NetworkError.poorConnection))
        } else {
            loadOfflineContent()
        }
    }
    
    private func loadOfflineContent() {
        do {
            let content = try storageService.loadContent()
            items = content.items ?? []
            onStateChange?(.loaded)
        } catch StorageError.noDataAvailable {
            onStateChange?(.error(NetworkError.offline))
        } catch {
            onStateChange?(.error(NetworkError.invalidData))
        }
    }
    
    private func isNetworkReachable() -> Bool {
        let reachabilityManager = NetworkReachabilityManager()
        return reachabilityManager?.isReachable ?? false
    }
    
    func getLastUpdateTime() -> String {
        if let lastUpdate = storageService.getLastUpdateTimestamp() {
            let formatter = RelativeDateTimeFormatter()
            formatter.unitsStyle = .full
            return "Last updated " + formatter.localizedString(for: lastUpdate, relativeTo: Date())
        }
        return "Never updated"
    }
    
    // Helper function to determine font size based on item type
    func fontSize(for item: Item) -> CGFloat {
        switch item.itemType {
        case .page:
            return 24 // Largest font size
        case .section:
            return 20 // Medium font size
        case .text, .image:
            return 16 // Smallest font size
        }
    }
    
    // Helper function to determine if an item is expandable
    func isExpandable(_ item: Item) -> Bool {
        return item.isExpandable
    }
    
    // Helper function to get nested items if any
    func getNestedItems(_ item: Item) -> [Item]? {
        return item.items
    }
} 
