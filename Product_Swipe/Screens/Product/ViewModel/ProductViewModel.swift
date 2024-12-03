//
//  ProductViewModel.swift
//  Product_Swipe
//
//  Created by Jayesh on 02/12/24.
//

import Foundation

class ProductViewModel {
    
    var productArray: [ProductResponse] = []
    var filteredProducts: [ProductResponse] = []
    
    func fetchProduct(completion: @escaping(Result<Bool, Error>) -> Void) {
        Task {
            do {
                let productResponse = try await ApiManager.shared.request(modelType: [ProductResponse].self, type: EndPointItems.product)
                self.productArray = productResponse
                self.filteredProducts = productResponse
                completion(.success(true))
            } catch {
                print("Error in fetching: \(error)")
                completion(.failure(error))
            }
        }
    }
    
    func filterProducts(by searchText: String) {
        if searchText.isEmpty {
            filteredProducts = productArray
        } else {
            filteredProducts = productArray.filter { $0.product_name.lowercased().contains(searchText.lowercased()) }
        }
    }
}
