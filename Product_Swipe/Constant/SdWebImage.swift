//
//  SdWebImage.swift
//  Product_Swipe
//
//  Created by Jayesh on 02/12/24.
//

import SDWebImage
import UIKit

class ImageLoader {
    static let shared = ImageLoader()

    private init() {}

    func loadImage(from url: String?, into imageView: UIImageView, placeholder: UIImage? = nil) {
        guard let urlString = url, let imageURL = URL(string: urlString) else {
            imageView.image = placeholder
            return
        }

        imageView.sd_setImage(with: imageURL, placeholderImage: placeholder, options: [.continueInBackground, .progressiveLoad], completed: nil)
    }
}
