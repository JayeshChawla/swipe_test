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
        self.navigationController?.popViewController(animated: true)
    }
}

extension AddProductsViewController {
    
    private func setUpUI() {
        pickerView.isHidden = true
        [productNameView, productRateView, productPriceView, productImageView].forEach { view in
            view?.layer.cornerRadius = 8
        }
        
        submitButton.layer.cornerRadius = 25.5
        
        imageVIew.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageSelection))
        imageVIew.addGestureRecognizer(tapGesture)
        productTypeTf.addTarget(self, action: #selector(productTypeSelected), for: .allEvents)
        
        pickerView.delegate = self
        pickerView.dataSource = self
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
                self.showAlert(message: response.message)
            case.failure(let error):
                self.showAlert(message: "Failed to add product: \(error.localizedDescription)")
            }
        }
    }
    
}

extension AddProductsViewController {
    
    private func submitData(productName: String, productType: String, price: Double, tax: Double, image: UIImage?) {
        let url = URL(string: "https://app.getswipe.in/api/public/add")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        let body = createFormBody(productName: productName, productType: productType, price: price, tax: tax, image: image, boundary: boundary)
        request.httpBody = body
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.showLoading(false)
            }
            if let error = error {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return}
                    self.showAlert(message: "Failed to submit: \(error.localizedDescription)")
                }
                return
            }
            
            if let data = data, let responseDict = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    if let message = responseDict["message"] as? String {
                        self.showAlert(message: message)
                    }
                    self.showLoading(false)
                }
            }
            
        }
        task.resume()
    }
    
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

