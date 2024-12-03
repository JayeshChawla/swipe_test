//
//  AddProductViewModel.swift
//  Product_Swipe
//
//  Created by Quick tech  on 03/12/24.
//

import Foundation
import UIKit

class AddProductViewModel {
    
    func setProductDetails(with product: AddProducts, completion: @escaping(Result<AddProductResponse, Error>) -> Void) {
        Task {
            do {
                let addProductResponse = try await ApiManager.shared.request(modelType: AddProductResponse.self, type: EndPointItems.addProduct(addProduct: product))
                completion(.success(addProductResponse))
            } catch {
                completion(.failure(error))
            }
        }
    }
}
