//
//  ProductRegistrationViewController.swift
//  OpenMarket
//
//  Created by 예거 on 2022/01/21.
//

import UIKit

final class ProductRegistrationViewController: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet private weak var navigationBar: UINavigationBar?
    @IBOutlet private weak var scrollView: UIScrollView?
    @IBOutlet private weak var productImageCollectionView: UICollectionView?
    @IBOutlet private weak var nameTextField: UITextField?
    @IBOutlet private weak var priceTextField: UITextField?
    @IBOutlet private weak var currencySegmentedControl: UISegmentedControl?
    @IBOutlet private weak var discountedPriceTextField: UITextField?
    @IBOutlet private weak var stockTextField: UITextField?
    @IBOutlet private weak var descriptionsTextView: UITextView?
    
    // MARK: - Properties
    
    weak var tableViewRefreshDelegate: RefreshDelegate?
    weak var collectionViewRefreshDelegate: RefreshDelegate?
    private let imagePicker: UIImagePickerController = {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        return imagePicker
    }()
    private var productImages: [UIImage] = []
    private var cells: [CellType] = [.imagePickerCell]
    private let flowLayout = UICollectionViewFlowLayout()
    private var descriptionsTextViewPlaceholder: UITextView = {
        let textView = UITextView()
        textView.text = "브랜드, 사이즈, 색상, 소재 등 물품에 대한 자세한 정보를 작성하면 판매확률이 올라가요!"
        textView.textColor = .placeholderText
        textView.font = .preferredFont(forTextStyle: .body)
        textView.backgroundColor = .clear
        textView.isUserInteractionEnabled = false
        textView.isScrollEnabled = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    // MARK: - Methods
    
    @IBAction private func cancelButtonTapped(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true)
    }
    
    @IBAction private func doneButtonTapped(_ sender: UIBarButtonItem) {
        handleProductRegistrationRequest()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        productImageCollectionView?.delegate = self
        productImageCollectionView?.dataSource = self
        descriptionsTextView?.delegate = self
        configureDescriptionTextView()
        configureNavigationBar()
        configureFlowLayout()
        addKeyboardNotificationObserver()
        addKeyboardDismissGestureRecognizer()
    }
    
    private func configureNavigationBar() {
        let navigationAppearance = UINavigationBarAppearance()
        navigationAppearance.configureWithTransparentBackground()
        navigationBar?.standardAppearance = navigationAppearance
    }
    
    private func configureFlowLayout() {
        productImageCollectionView?.collectionViewLayout = flowLayout
        flowLayout.scrollDirection = .horizontal
        productImageCollectionView?.showsVerticalScrollIndicator = false
        productImageCollectionView?.showsHorizontalScrollIndicator = false
        
        let cellWidth = view.bounds.size.width / 4
        flowLayout.itemSize = CGSize(width: cellWidth, height: cellWidth)
        flowLayout.minimumLineSpacing = 10
        flowLayout.sectionInset = UIEdgeInsets(top: .zero, left: 10, bottom: .zero, right: 10)
    }
    
    private func configureDescriptionTextView() {
        guard let descriptionsTextView = descriptionsTextView else { return }
        descriptionsTextView.addSubview(descriptionsTextViewPlaceholder)
        NSLayoutConstraint.activate([
            descriptionsTextViewPlaceholder.widthAnchor.constraint(equalTo: descriptionsTextView.widthAnchor),
            descriptionsTextViewPlaceholder.leadingAnchor.constraint(equalTo: descriptionsTextView.leadingAnchor),
            descriptionsTextViewPlaceholder.trailingAnchor.constraint(equalTo: descriptionsTextView.trailingAnchor),
            descriptionsTextViewPlaceholder.topAnchor.constraint(equalTo: descriptionsTextView.topAnchor),
            descriptionsTextViewPlaceholder.bottomAnchor.constraint(equalTo: descriptionsTextView.bottomAnchor)
        ])
    }
    
    private func handleProductRegistrationRequest() {
        guard let newProduct = createNewProductInfo() else { return }
        guard let newProductImages = createImageFiles(newProductName: newProduct.name) else {
            return
        }
        
        let request = ProductRegistrationRequest(
            identifier: "c4dedd67-71fc-11ec-abfa-fd97ecfece87",
            params: newProduct,
            images: newProductImages
        )
        
        APIExecutor().execute(request) { [weak self] (result: Result<ProductDetail, Error>) in
            guard let self = self else { return }
            
            switch result {
            case .success:
                DispatchQueue.main.async {
                    self.showAlert(title: "상품이 성공적으로 등록됐습니다", message: "🤑") { _ in
                        self.dismiss(animated: true) {
                            self.tableViewRefreshDelegate?.refresh()
                            self.collectionViewRefreshDelegate?.refresh()
                        }
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.showAlert(title: "상품 등록에 실패했습니다", message: "🥲", handler: nil)
                }
                print("에러가 발생했습니다! : \(error)")
            }
        }
    }
    
    private func createNewProductInfo() -> NewProductInfo? {
        guard let name = nameTextField?.text else {
            return nil
        }
        guard let price = priceTextField?.text else {
            return nil
        }
        var currency: Currency
        if currencySegmentedControl?.selectedSegmentIndex == .zero {
            currency = .krw
        } else {
            currency = .usd
        }
        let discountedPrice = discountedPriceTextField?.text ?? "0"
        let stock = stockTextField?.text ?? "0"
        guard let descriptions = descriptionsTextView?.text else {
            return nil
        }
        
        let newProduct = NewProductInfo(
            name: name,
            descriptions: descriptions,
            price: (price as NSString).doubleValue,
            currency: currency,
            discountedPrice: (discountedPrice as NSString).doubleValue,
            stock: (stock as NSString).integerValue,
            secret: "aFJkk2KmB53A*6LT"
        )
        
        return newProduct
    }
    
    private func createImageFiles(newProductName: String) -> [ImageFile]? {
        var imageFileNumber = 1
        var newProductImages: [ImageFile] = []
        productImages.forEach { image in
            let imageFile = ImageFile(
                fileName: "\(newProductName)-\(imageFileNumber)",
                image: image
            )
            imageFileNumber += 1
            newProductImages.append(imageFile)
        }
        return newProductImages
    }
    
    private func addKeyboardNotificationObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    private func addKeyboardDismissGestureRecognizer() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func keyboardWillShow(_ sender: Notification) {
        if let keyboardFrame: NSValue = sender.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardHeight = keyboardFrame.cgRectValue.height
            scrollView?.contentInset.bottom = keyboardHeight
            scrollView?.verticalScrollIndicatorInsets.bottom = keyboardHeight
        }
    }
    
    @objc private func keyboardWillHide() {
        scrollView?.contentInset.bottom = .zero
        scrollView?.verticalScrollIndicatorInsets.bottom = .zero
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource

extension ProductRegistrationViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        let imagePickerCell = 1
        return imagePickerCell + productImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellType = cells[safe: indexPath.item]
        
        switch cellType {
        case .imagePickerCell:
            let cell = collectionView.dequeueReusableCell(
                withClass: ImagePickerCollectionViewCell.self,
                for: indexPath
            )
            cell.updateAddedImageCountLabel(images: productImages)
            return cell
        default:
            let cell = collectionView.dequeueReusableCell(
                withClass: ProductImageCollectionViewCell.self,
                for: indexPath
            )
            let targetImage = productImages[safe: indexPath.item - 1]
            cell.updateProductImageView(image: targetImage)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let maximumImageCount = 5
        let cellType = cells[safe: indexPath.item]
        
        guard cellType == .imagePickerCell else {
            // 사진 클릭 시, 자세히 보는 기능을 추가할 수 있음
            return
        }
        
        guard productImages.count < maximumImageCount else {
            showAlert(
                title: "Too Much Images",
                message: "최대 \(maximumImageCount)장까지만 첨부할 수 있어요",
                handler: nil
            )
            return
        }
        
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
}

// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate

extension ProductRegistrationViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        
        if let possibleImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            productImages.append(possibleImage)
        } else if let possibleImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            productImages.append(possibleImage)
        }
        cells.append(.productImageCell)
        productImageCollectionView?.reloadData()
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - UITextViewDelegate

extension ProductRegistrationViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.hasText {
            descriptionsTextViewPlaceholder.isHidden = true
        } else {
            descriptionsTextViewPlaceholder.isHidden = false
        }
    }
}
