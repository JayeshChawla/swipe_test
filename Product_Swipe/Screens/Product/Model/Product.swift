//
//  Product.swift
//  Product_Swipe
//
//  Created by Jayesh on 02/12/24.
//

import Foundation

struct ProductResponse: Codable {
    let image: String?
    let price: Float
    let product_name: String
    let product_type: String
    let tax: Int
}
