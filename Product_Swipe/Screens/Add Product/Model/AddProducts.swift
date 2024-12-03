//
//  File.swift
//  Product_Swipe
//
//  Created by Quick tech  on 03/12/24.
//

import Foundation
import UIKit

//For network
struct AddProductsOffline: Codable {
    let productName: String
    let productType: String
    let price: Double
    let tax: Double
    let imageData: Data? // Store image as Data
    
    init(productName: String, productType: String, price: Double, tax: Double, image: UIImage?) {
        self.productName = productName
        self.productType = productType
        self.price = price
        self.tax = tax
        self.imageData = image?.jpegData(compressionQuality: 0.8)
    }
}

//for Api 
struct AddProducts: Encodable {
    let productName: String
    let productType: String
    let price: Double
    let tax: Double
    let image: UIImage?
    
    enum CodingKeys: String, CodingKey {
         case productName = "product_name"
         case productType = "product_type"
         case price
         case tax
     }
}

struct AddProductResponse: Codable {
    let message: String
    let success: Bool
}
