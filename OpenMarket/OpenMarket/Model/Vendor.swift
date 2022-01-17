//
//  Vendor.swift
//  OpenMarket
//
//  Created by lily on 2022/01/05.
//

import Foundation

struct Vendor: Codable {
    
    let name: String
    let id: Int
    let createdAt: Date // JSONObject 니까, Data 타입이 아니고 String 이다!
    let issuedAt: Date // JSONObject 니까, Data 타입이 아니고 String 이다!
    
    private enum CodingKeys: String, CodingKey { // 여기 스펠링 틀려있었음..
        
        case createdAt = "created_at"
        case issuedAt = "issued_at"
        case name, id
    }
}
