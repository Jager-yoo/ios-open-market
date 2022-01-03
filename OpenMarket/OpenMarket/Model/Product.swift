//
//  Product.swift
//  OpenMarket
//
//  Created by 예거 on 2022/01/04.
//

import Foundation

struct Product: Codable {
    
    var id: Int
    var vendorID: Int
    var name: String
    var thumbnail: String
    var currency: Currency
    var price: Int
    var bargainPrice: Int
    var discountedPrice: Int
    var stock: Int
    var createdAt: Date
    var issuedAt: Date
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Self.CodingKeys)
        id = try container.decode(Int.self, forKey: .id)
        vendorID = try container.decode(Int.self, forKey: .vendorID)
        name = try container.decode(String.self, forKey: .name)
        thumbnail = try container.decode(String.self, forKey: .thumbnail)
        currency = try container.decode(Currency.self, forKey: .currency)
        price = try container.decode(Int.self, forKey: .price)
        bargainPrice = try container.decode(Int.self, forKey: .bargainPrice)
        discountedPrice = try container.decode(Int.self, forKey: .discountedPrice)
        stock = try container.decode(Int.self, forKey: .stock)
        createdAt = Utility.formatDate(from: try container.decode(String.self, forKey: .createdAt))
        issuedAt = Utility.formatDate(from: try container.decode(String.self, forKey: .issuedAt))
    }

    enum CodingKeys: String, CodingKey {

        case id
        case vendorID = "vendor_id"
        case name
        case thumbnail
        case currency
        case price
        case bargainPrice = "bargain_price"
        case discountedPrice = "discounted_price"
        case stock
        case createdAt = "created_at"
        case issuedAt = "issued_at"
    }
}
