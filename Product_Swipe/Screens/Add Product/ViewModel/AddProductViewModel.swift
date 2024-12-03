//
//  AddProductViewModel.swift
//  Product_Swipe
//
//  Created by Quick tech  on 03/12/24.
//

import Foundation
import UIKit

class AddProductViewModel {
    
    func setProductDetails(with product: AddProducts, completion: @escaping(Result<AddProductResponse?, Error>) -> Void) {
        Task {
            do {
                if NetworkMonitor.shared.isConnected {
                    let addProductResponse = try await ApiManager.shared.request(modelType: AddProductResponse.self, type: EndPointItems.addProduct(addProduct: product))
                    completion(.success(addProductResponse))
                } else {
                    let productsOffline = AddProductsOffline(productName: product.productName, productType: product.productType, price: product.price, tax: product.tax, image: product.image)
                    saveOffline(productsOffline)
                    completion(.success(nil))
                }
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    private func saveOffline(_ product: AddProductsOffline) {
        OfflineStorageManager.shared.saveProduct(product)
        print("Product saved offline")
    }
}
