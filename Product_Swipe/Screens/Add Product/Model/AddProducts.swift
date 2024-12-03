//
//  File.swift
//  Product_Swipe
//
//  Created by Quick tech  on 03/12/24.
//

import Foundation
import UIKit

//{
//    "message": "Product added Successfully!",
//    "product_details": {
//        //details of added product
//},
//"product_id": 2657, "success": true
//}

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
