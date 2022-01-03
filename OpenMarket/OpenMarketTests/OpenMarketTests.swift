//
//  OpenMarketTests.swift
//  OpenMarketTests
//
//  Created by 예거 on 2022/01/03.
//

import XCTest
@testable import OpenMarket

class OpenMarketTests: XCTestCase {
    
    var sut: ProductsList!
    let mockItem = "products"
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        sut = MockJSONParser<ProductsList>.decode(from: mockItem)
    }
    
    override func tearDownWithError() throws {
        try super.tearDownWithError()
        sut = nil
    }
    
    func test_mockJSON_currency_파싱_검증() {
        let result = sut.pages[0].currency
        let expectation = Currency.krw
        XCTAssertEqual(result, expectation)
    }
    
    func test_mockJSON_Date타입_파싱_검증() {
        let result = sut.pages[1].createdAt
        let expectation = Utility.formatDate(from: "2021-12-29 00:00:00.000")
        XCTAssertEqual(result, expectation)
    }
    
    func test_mockJSON_thumbnail_파싱_검증() {
        let result = sut.pages[2].thumbnail
        let expectation = "https://s3.ap-northeast-2.amazonaws.com/media.yagom-academy.kr/training-resources/3/thumb/87aa7c8966df11ecad1df993f20d4a2a.jpg"
        XCTAssertEqual(result, expectation)
    }
    
    // 상품 이미지 파일, png , jpeg, jpg 만 지원하는 거 검증하는 유닛 테스트도 필요하겠지?
}
