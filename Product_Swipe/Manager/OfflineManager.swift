//
//  OfflineManager.swift
//  Product_Swipe
//
//  Created by Jayesh on 03/12/24.
//

import Foundation

class OfflineStorageManager {
    static let shared = OfflineStorageManager()
    private let storageKey = "OfflineProducts"
    
    private init() {}
    
    // Save a product to local storage
    func saveProduct(_ product: AddProductsOffline) {
        var savedProducts = fetchProducts()
        savedProducts.append(product)
        if let data = try? JSONEncoder().encode(savedProducts) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }
    
    // Fetch all saved products
    func fetchProducts() -> [AddProductsOffline] {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let products = try? JSONDecoder().decode([AddProductsOffline].self, from: data) else {
            return []
        }
        return products
    }
    
    // Clear all saved products
    func clearProducts() {
        UserDefaults.standard.removeObject(forKey: storageKey)
    }
}

