//
//  ProductListViewCell.swift
//  OpenMarket
//
//  Created by 예거 on 2022/01/13.
//

import UIKit

class ProductListViewCell: UITableViewCell {
    
    // static let reuseIdentifier = String(describing: ProductListViewCell.self)
    // String 으로 두게 되면, '연산'을 하게 된다. static 은 런타임에 할당이 된다.
    // 메모리에 올라간 뒤에 내려오지 않는다. 런타임에 String 이니셜라이저를 사용하면 오버헤드가 크다.
    // 가볍게 가기 위해선, '정적인 값'을 넣어야 한다.
    // 컴파일을 거치면 정적인 값으로 바뀐다. 오버헤드가 상대적으로 낮다.
    // static let reuseIdentifier = #fileID
    static let reuseIdentifier = "ProductListViewCell"
    // 정직하게 들어감. "OpenMarket/ProductListViewCell.swift" 로 들어간다.
    // * 오버헤드 = '비용' 으로 생각하면 된다.
    
    @IBOutlet weak var productThumbnail: UIImageView!
    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var productPrice: UILabel!
    @IBOutlet weak var productStock: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
