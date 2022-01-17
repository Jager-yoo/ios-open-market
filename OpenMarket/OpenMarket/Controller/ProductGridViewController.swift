//
//  ProductGridViewController.swift
//  OpenMarket
//
//  Created by 예거 on 2022/01/12.
//

import UIKit

class ProductGridViewController: UICollectionViewController {
    
    private var initialProductsListPage: ProductsListPage?
    private let flowLayout = UICollectionViewFlowLayout()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureGridLayout()
        
        let request = ProductsListPageRequest(pageNo: 1, itemsPerPage: 20)
        APIExecutor().execute(request) { (result: Result<ProductsListPage, Error>) in
            switch result {
            case .success(let productsListPage):
                self.initialProductsListPage = productsListPage
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            case .failure(let error):
                // Alert 넣기
                print("ProductsListPage 통신 중 에러 발생 : \(error)")
                return
            }
        }
    }
    
    private func configureGridLayout() {
        // flowLayout 에게 역할을 줘버리는 것.
        collectionView.collectionViewLayout = flowLayout
        let cellWidth = view.bounds.size.width / 2 - 10
        flowLayout.itemSize = CGSize(width: cellWidth, height: cellWidth * 1.5)
        flowLayout.minimumLineSpacing = 10
        flowLayout.minimumInteritemSpacing = 10
        flowLayout.scrollDirection = .vertical
        flowLayout.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: .zero, right: 5)
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return initialProductsListPage?.pages.count ?? .zero
    }

    override func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ProductGridViewCell.reuseIdentifier,
            for: indexPath
        ) as? ProductGridViewCell else {
            return ProductGridViewCell()
        }
        
        guard let product = initialProductsListPage?.pages[indexPath.item] else {
            return cell
        }
        
        configureGridContent(of: cell, with: product)
        configureGridCellLayer(of: cell)
        
        return cell
    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        let cellWidth = view.bounds.size.width / 2 - 10
//        return CGSize(width: cellWidth, height: cellWidth * 1.5)
//    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//        return 10
//    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
//        return 10
//    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
//        return UIEdgeInsets(top: 5, left: 5, bottom: .zero, right: 5)
//    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("🥺선택한 아이템은 \(indexPath.section) 에서 \(indexPath.item)")
    }
    
    private func configureGridContent(of cell: ProductGridViewCell, with product: Product) {
        DispatchQueue.main.async {
            cell.productThumbnail.image = self.getImage(from: product.thumbnail)
            cell.productName.attributedText = product.attributedName
            cell.productPrice.attributedText = product.attributedPrice
            cell.productStock.attributedText = product.attributedStock
        }
    }
    
    private func configureGridCellLayer(of cell: ProductGridViewCell) {
        cell.layer.borderColor = UIColor.systemGray.cgColor
        cell.layer.borderWidth = 1
        cell.layer.cornerRadius = 5
    }
    
    private func getImage(from url: String) -> UIImage? {
        guard let url = URL(string: url), let imageData = try? Data(contentsOf: url) else {
            let defaultImage = UIImage(systemName: "xmark.icloud")
            return defaultImage?.withTintColor(.systemGray)
        }
        return UIImage(data: imageData)
    }
}
