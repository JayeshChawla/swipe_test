//
//  AddProductsViewController.swift
//  Product_Swipe
//
//  Created by Quick tech  on 03/12/24.
//

import UIKit

class AddProductsViewController: UIViewController {
    
//MARK: Views
    @IBOutlet weak var productType: UIView!
    @IBOutlet weak var productImageView: UIView!
    @IBOutlet weak var productRateView: UIView!
    @IBOutlet weak var productPriceView: UIView!
    @IBOutlet weak var productNameView: UIView!
    @IBOutlet weak var mainView: UIView!
    
//MARK: Text Fields
    @IBOutlet weak var productRateTf: UITextField!
    @IBOutlet weak var productPriceTf: UITextField!
    @IBOutlet weak var productNameTf: UITextField!
    @IBOutlet weak var productTypeTf: UITextField!
    
//MARK: Buttons
    @IBOutlet weak var submitButton: UIButton!
    
//MARK: ImageView
    @IBOutlet weak var imageVIew: UIImageView!
    
//MARK: Picker View
    @IBOutlet weak var pickerView: UIPickerView!
    
    private let productTypes = ["Electronics", "Clothing", "Books", "Groceries"]
    private var selectedProductType: String?
    private var selectedImage: UIImage?
    private var activityIndicator: UIActivityIndicatorView?
    private var addProductVm = AddProductViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpUI()
    }

    @IBAction func imagePicker(_ sender: Any) {
        self.imageselect()
    }
    @IBAction func submitButton(_ sender: Any) {
        self.validationForProduct()
    }
    @IBAction func backBtn(_ sender: Any) {
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
}

extension AddProductsViewController {
    
    private func setUpUI() {
        pickerView.isHidden = true
        [productNameView, productRateView, productPriceView, productImageView].forEach { view in
            view?.layer.cornerRadius = 8
        }
        [productNameTf, productPriceTf, productRateTf].forEach { tf in
            tf?.addTarget(self, action: #selector(textFieldSelected), for: .allEvents)
        }
        [productRateTf, productPriceTf].forEach { tf in
            tf?.addTarget(self, action: #selector(numberPadSelected), for: .allEvents)
        }
        submitButton.layer.cornerRadius = 25.5
        
        imageVIew.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageSelection))
        imageVIew.addGestureRecognizer(tapGesture)
        productTypeTf.addTarget(self, action: #selector(productTypeSelected), for: .allEvents)
        
        let keyboardGesture = UITapGestureRecognizer(target: self, action: #selector(mainViewTapped))
        mainView.addGestureRecognizer(keyboardGesture)
        mainView.isUserInteractionEnabled = true
        
        pickerView.delegate = self
        pickerView.dataSource = self
    }
    
    @objc func mainViewTapped() {
        view.endEditing(true)
    }
    @objc func numberPadSelected() {
        productPriceTf.keyboardType = .numberPad
        productRateTf.keyboardType = .numberPad
    }
    @objc func textFieldSelected() {
        pickerView.isHidden = true
    }
    @objc func imageSelection() {
        self.imageselect()
    }
    
    @objc func productTypeSelected() {
        pickerView.isHidden = false
    }
    
    private func imageselect() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.mediaTypes = ["public.image"]
        present(imagePicker, animated: true)
    }
    
    private func validationForProduct() {
        guard let productName = productNameTf.text, !productName.isEmpty else {
            showAlert(message: "Please enter the product name.")
            return
        }
        guard let productType = productTypeTf.text, !productType.isEmpty else {
            showAlert(message: "Please enter the product type.")
            return
        }
        guard let productPrice = productPriceTf.text, let price = Double(productPrice), !productPrice.isEmpty else {
            showAlert(message: "Please enter the product price.")
            return
        }
        guard let productTax = productRateTf.text, let tax = Double(productTax), !productTax.isEmpty else {
            showAlert(message: "Please enter the product tax rate.")
            return
        }
        showLoading(true)
        let product = AddProducts(productName: productName, productType: productType, price: price, tax: tax, image: selectedImage)
        self.submitProduct(product)
    }
    
    private func submitProduct(_ product: AddProducts) {
        addProductVm.setProductDetails(with: product) { result in
            switch result {
            case .success(let response):
                DispatchQueue.main.async {
                    self.showLoading(false)
                }
                if NetworkMonitor.shared.isConnected {
                    self.showAlert(message: response!.message )
                } else {
                    self.showAlert(message: "Product Saved Offline.")
                }
            case.failure(let error):
                DispatchQueue.main.async {
                    self.showLoading(false)
                }
                self.showAlert(message: "Failed to add product: \(error.localizedDescription)")
            }
        }
    }
    
}

extension AddProductsViewController {
    
    private func showLoading(_ show: Bool) {
        if show {
            activityIndicator = UIActivityIndicatorView(style: .large)
            activityIndicator?.center = view.center
            activityIndicator?.startAnimating()
            if let activityIndicator = activityIndicator {
                view.addSubview(activityIndicator)
            }
        } else {
            activityIndicator?.stopAnimating()
            activityIndicator?.removeFromSuperview()
            activityIndicator = nil
        }
    }
}

//MARK: UIImageViewPicker Delegate Methods
extension AddProductsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
         if let image = info[.originalImage] as? UIImage {
             imageVIew.image = image
             selectedImage = image
         }
         picker.dismiss(animated: true)
     }
}

extension AddProductsViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return productTypes.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return productTypes[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedProductType = productTypes[row]
        productTypeTf.text = selectedProductType
        pickerView.isHidden = true
    }
}

