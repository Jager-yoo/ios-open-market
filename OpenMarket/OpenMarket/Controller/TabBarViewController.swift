//
//  OpenMarket - ViewController.swift
//  Created by yagom. 
//  Copyright © yagom. All rights reserved.
// 

import UIKit

class TabBarViewController: UITabBarController {
    
    @IBOutlet private weak var viewSegmentedControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.isHidden = true
        configureViewSegmentedControl()
        
        // image 는 binary 로 보내야 한다.
        // let testImageJpegData = UIImage(data: testImageData)!.jpegData(compressionQuality: 1)!
        // 인코딩은 String -> Data 변환
        // 디코딩은 Data -> String 변환
        
        // 이미지 업로드 실험 - 임시 NewProductInfo() 생성
        let newItem = NewProductInfo(name: "해커맨", descriptions: "냉무", price: 1000, currency: .krw, discountedPrice: 200, stock: 10, secret: "password")
        let newItem2 = NewProductInfo(name: "애플 NFT", descriptions: "아 어려워", price: 10000, currency: .usd, discountedPrice: 0, stock: 1, secret: "password")

        // jpeg 이미지 링크 따서 URL 만들기 (jpeg 포맷인 거 확인함)
        let testImageURL = URL(string: "https://preview.redd.it/vreph5xqwm311.jpg?auto=webp&s=c130c4e60ef9354cbbe15080a7fc51d521875bf5")!
        let testImageURL2 = URL(string: "data:image/png;base64,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")!

        // 그 URL을 데이터로 변환하기
        let testImageData = try! Data(contentsOf: testImageURL)
        let testImageData2 = try! Data(contentsOf: testImageURL2)

        // 위 이미지 데이터와 각종 정보를 넣어서 ImageFile 인스턴스 만들기
        let testImage = ImageFile(key: "\"images\"", fileName: "\"vreph5xqwm311.jpeg\"", data: testImageData, type: .jpeg)
        let testImage2 = ImageFile(key: "\"images\"", fileName: "\"몰라.png\"", data: testImageData2, type: .png)

        // 리퀘스트 만들기
        let request = ProductRegistrationRequest(identifier: "cd706a3e-66db-11ec-9626-796401f2341a", params: newItem, images: [testImage])
        let request2 = ProductRegistrationRequest(identifier: "cd706a3e-66db-11ec-9626-796401f2341a", params: newItem2, images: [testImage2])

        // execute 실험
        APIExecutor().execute(request2) { (result: Result<ProductDetail, Error>) in
            switch result {
            case .success(let productDetail):
                print("🍓상품 업로드 성공! + \(productDetail)")
            case .failure(let error):
                print("🍓에러 발생! : \(error)")
            }
        }
    }
    
    @IBAction private func switchViewController(_ sender: UISegmentedControl) {
        selectedIndex = sender.selectedSegmentIndex
    }
    
    private func configureViewSegmentedControl() {
        viewSegmentedControl.setTitle("LIST", forSegmentAt: 0)
        viewSegmentedControl.setTitle("GRID", forSegmentAt: 1)
        viewSegmentedControl.setTitleTextAttributes(
            [.foregroundColor: UIColor.systemIndigo],
            for: .normal
        )
        viewSegmentedControl.setTitleTextAttributes(
            [.foregroundColor: UIColor.white],
            for: .selected
        )
        viewSegmentedControl.selectedSegmentTintColor = .systemIndigo
        viewSegmentedControl.backgroundColor = .white
        viewSegmentedControl.layer.borderColor = UIColor.systemIndigo.cgColor
        viewSegmentedControl.layer.borderWidth = 1
    }
    
}

