//
//  OpenMarketAPI.swift
//  OpenMarket
//
//  Created by 예거 on 2022/01/03.
//

import Foundation

final class OpenMarketAPI {
    
    static let shared = OpenMarketAPI()
    
    func fetchOpenMarketData() {
        let urlString = "https://market-training.yagom-academy.kr/"
        guard let url = URL(string: urlString) else {
            print("---url을 찾을 수 없습니다.---")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                print("---data was nil---")
                return
            }
            guard let openMarketData = try? JSONDecoder().decode(ProductsList.self, from: data) else {
                print("---couldn't decode JSON---")
                return
            }
            print(openMarketData)
        }
        task.resume()
    }
}
