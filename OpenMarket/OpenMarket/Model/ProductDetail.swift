//
//  ProductDetail.swift
//  OpenMarket
//
//  Created by lily on 2022/01/05.
//

import Foundation

struct ProductDetail: Codable {
    
    let id: Int
    let vendorID: Int
    let name: String
    let thumbnail: String
    let currency: Currency // 이거 Currency 타입으로 바로 못 받음. String 으로 받아야 함!
    let price: Double
    let bargainPrice: Double
    let discountedPrice: Double
    let stock: Int
    let images: [Image]
    let vendor: Vendor
    let createdAt: Date // 이것도 JSON이라서 String 타입이 맞다
    let issuedAt: Date // 여기 체크
    
    private enum CodingKeys: String, CodingKey {
        
        case vendorID = "vendor_id"
        case bargainPrice = "bargain_price"
        case discountedPrice = "discounted_price"
        case vendor = "vendors"
        case createdAt = "created_at"
        case issuedAt = "issued_at"
        case id, name, thumbnail, currency, price, stock, images
    }
}
