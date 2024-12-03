//
//  ProductViewController.swift
//  Product_Swipe
//
//  Created by Jayesh on 02/12/24.
//

import UIKit

class ProductViewController: UIViewController {

    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    private var productVm = ProductViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.setUpTableView()
        self.fetchProducts()
        self.searchTexFieldSetUp()
    }
    
    private func setupUI() {
        searchView.layer.cornerRadius = 10
    }
    
    private func setUpTableView() {
        tableView.register(UINib(nibName: "ProductTableViewCell", bundle: nil), forCellReuseIdentifier: "ProductTableViewCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.showsVerticalScrollIndicator = false
    }
    
    private func fetchProducts() {
        productVm.fetchProduct { result in
            switch result {
            case .success:
                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }
                    tableView.reloadData()
                }
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    private func searchTexFieldSetUp() {
        searchTextField.delegate = self
        searchTextField.addTarget(self, action: #selector(searchTextChanged), for: .editingChanged)
    }
    
    @IBAction func addProductButton(_ sender: UIButton) {
        if let addProductVc = UIStoryboard(name: "AddProducts", bundle: nil).instantiateViewController(withIdentifier: "addProducts") as? AddProductsViewController {
            self.navigationController?.pushViewController(addProductVc, animated: true)
        }
    }
}

extension ProductViewController {
    
    @objc func searchTextChanged() {
        guard let searchText = searchTextField.text else { return }
        productVm.filterProducts(by: searchText)
        tableView.reloadData()
    }
}

//MARK: Search TexField Delegate
extension ProductViewController: UITextFieldDelegate {
}

//MARK: UITableViewDatasource and Delegate Methods
extension ProductViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return productVm.filteredProducts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ProductTableViewCell", for: indexPath) as? ProductTableViewCell else { return UITableViewCell() }
        
        let productData = productVm.filteredProducts[indexPath.row]
        cell.productName.text = productData.product_name
        cell.productCategory.text = "Type : \(productData.product_type)"
        cell.productPrice.text = "Starts from : $\(productData.price)"
        ImageLoader.shared.loadImage(from: productData.image, into: cell.productImage, placeholder: UIImage(named: "placeholder"))
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 122
    }
    
}


