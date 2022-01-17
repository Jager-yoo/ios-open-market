//
//  Image.swift
//  OpenMarket
//
//  Created by lily on 2022/01/05.
//

import Foundation

struct Image: Codable {
    
    let id: Int
    let url: String
    let thumbnailURL: String
    let succeed: Bool
    let issuedAt: Date // 잘보면 Data 타입이 아니고 String 타입임 ㅎ
    // JSON에서 표현할 수 있는 건, 숫자, 문자, 불, 어레이, json객체 밖에 없음. 그니까 String 이 될 수밖에!
    
    private enum CodingKeys: String, CodingKey {
        
        case thumbnailURL = "thumbnail_url"
        case issuedAt = "issued_at"
        case id, url, succeed
    }
}
