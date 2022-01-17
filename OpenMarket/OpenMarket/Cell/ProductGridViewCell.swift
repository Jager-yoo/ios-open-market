//
//  ProductGridViewCell.swift
//  OpenMarket
//
//  Created by lily on 2022/01/13.
//

import UIKit

class ProductGridViewCell: UICollectionViewCell {
    
    // static let reuseIdentifier = String(describing: ProductGridViewCell.self)
    // static let reuseIdentifier = #fileID
    static let reuseIdentifier = "ProductGridViewCell"
    
    @IBOutlet weak var productThumbnail: UIImageView!
    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var productPrice: UILabel!
    @IBOutlet weak var productStock: UILabel!
}
