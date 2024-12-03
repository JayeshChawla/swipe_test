//
//  EndPointType.swift
//  Product_Swipe
//
//  Created by Jayesh on 02/12/24.
//

import Foundation

enum HTTPMethods: String {
    case get = "GET"
    case post = "POST"
}

protocol EndPointTypes {
    var path: String { get }
    var baseURL: String { get }
    var url: URL? { get }
    var methods: HTTPMethods { get }
    var body: Encodable? { get }
    var headers: [String: String]? { get }
    var requiresMultipart: Bool { get }
}

enum EndPointItems {
    case product
    case addProduct(addProduct: AddProducts)
}

extension EndPointItems: EndPointTypes {
    var path: String {
        switch self {
        case .product:
            return "get"
        case .addProduct:
            return "add"
        }
    }
    
    var baseURL: String {
        return "https://app.getswipe.in/api/public/"
    }
    
    var url: URL? {
        return URL(string: "\(baseURL)\(path)")
    }
    
    var methods: HTTPMethods {
        switch self {
        case .product:
            return .get
        case .addProduct:
            return .post
        }
    }
    
    var body: (any Encodable)? {
        switch self {
        case .product:
            return nil
        case .addProduct(let addProduct):
            return addProduct
        }
    }
    
    var requiresMultipart: Bool {
        switch self {
        case .product:
            return false
        case .addProduct:
            return true
        }
    }
    
    var headers: [String : String]? {
        return nil
    }
    
}
