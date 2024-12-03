//
//  APIManager.swift
//  Product_Swipe
//
//  Created by Jayesh on 02/12/24.
//

import Foundation
import UIKit

enum DataError: Error {
    case invalidURl
    case invalidResponse
    case invalidData
    case message(Error?)
}

class ApiManager {
    
    static let shared = ApiManager()
    
    func request<T: Codable>(
        modelType: T.Type,
        type: EndPointItems
    ) async throws -> T {
        
        guard let url = type.url else { throw DataError.invalidURl }
        
        var request = URLRequest(url: url)
        request.httpMethod = type.methods.rawValue
        if type.requiresMultipart {
             let boundary = "Boundary-\(UUID().uuidString)"
             request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
             
             if let addProduct = type.body as? AddProducts {
                 request.httpBody = createFormBody(
                     productName: addProduct.productName,
                     productType: addProduct.productType,
                     price: addProduct.price,
                     tax: addProduct.tax,
                     image: addProduct.image,
                     boundary: boundary
                 )
             }
         } else if let parameters = type.body {
             request.addValue("application/json", forHTTPHeaderField: "Content-Type")
             request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
         }
        request.allHTTPHeaderFields = type.headers
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                guard 200 ... 299 ~= httpResponse.statusCode else {
                    throw DataError.invalidResponse
                }
            }
            
            let decodeData = try JSONDecoder().decode(modelType, from: data)
            return decodeData
        } catch {
            throw DataError.message(error)
        }
    }
}
extension ApiManager {
    private func createFormBody(productName: String, productType: String, price: Double, tax: Double, image: UIImage?, boundary: String) -> Data {
        
        var body = Data()
        
        func appendValue(name: String, value: String) {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(value)\r\n".data(using: .utf8)!)
        }
        
        appendValue(name: "product_name", value: productName)
        appendValue(name: "product_type", value: productType)
        appendValue(name: "price", value: "\(price)")
        appendValue(name: "tax", value: "\(tax)")
        
        if let image = image, let imageData = image.jpegData(compressionQuality: 0.8) {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"files[]\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            body.append(imageData)
            body.append("\r\n".data(using: .utf8)!)
        }
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        return body
    }
}
