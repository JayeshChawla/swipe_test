//
//  ProductTableViewCell.swift
//  Product_Swipe
//
//  Created by Jayesh on 02/12/24.
//

import UIKit

class ProductTableViewCell: UITableViewCell {

    @IBOutlet weak var productView: UIView!
    @IBOutlet weak var productPrice: UILabel!
    @IBOutlet weak var productCategory: UILabel!
    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var productImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        productView.layer.shadowColor = UIColor.black.cgColor
        productView.layer.shadowOffset = .zero
        productView.layer.shadowOpacity = 0.1
        productView.layer.shadowRadius = 08
        productView.layer.cornerRadius = 20
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
