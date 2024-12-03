//
//  Network.swift
//  Product_Swipe
//
//  Created by Jayesh on 03/12/24.
//

import Network

class NetworkMonitor {
    static let shared = NetworkMonitor()
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    
    var isConnected: Bool = false
    
    private init() {
        monitor.pathUpdateHandler = { path in
            self.isConnected = path.status == .satisfied
            if self.isConnected {
                self.syncOfflineProducts()
            }
        }
        monitor.start(queue: queue)
    }
    
    private func syncOfflineProducts() {
        let products = OfflineStorageManager.shared.fetchProducts()
        guard !products.isEmpty else { return }
        
        Task {
            for product in products {
                do {
                    let response: AddProductResponse = try await ApiManager.shared.request(
                        modelType: AddProductResponse.self,
                        type: .addProductOffline(addProduct: product)
                    )
                    print("Synced product: \(response.message)")
                } catch {
                    print("Failed to sync product: \(error.localizedDescription)")
                }
            }
            OfflineStorageManager.shared.clearProducts()
        }
    }
}

