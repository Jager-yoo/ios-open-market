//
//  APIExecutor.swift
//  OpenMarket
//
//  Created by 예거 on 2022/01/07.
//

import Foundation

struct APIExecutor {
    
    func execute<T: Decodable>(_ request: APIRequest, completion: @escaping (Result<T, Error>) -> Void) {
        guard let url = request.url else { return }
        var urlRequest = URLRequest(url: url)

        urlRequest.httpMethod = request.httpMethod.rawValue

        request.header.forEach { (key, value) in
            urlRequest.addValue(value, forHTTPHeaderField: key)
        }

        urlRequest.httpBody = request.body
        // print(String(decoding: urlRequest.httpBody!, as: UTF8.self))
        executeTask(request: urlRequest, completion)
    }
    
    private func executeTask<T: Decodable>(request: URLRequest, _ completion: @escaping (Result<T, Error>) -> Void ) {
        let dataTask = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                      completion(.failure(APIError.invalidResponseDate))
                      return
                  }
            
            guard let data = data else {
                completion(.failure(APIError.dataIsNil))
                return
            } // 컴플리션 핸들러 호출할 필요 있음
            guard let decoded: T = JSONCodable().decode(from: data) else {
                completion(.failure(APIError.dataIsNotParsed))
                return
            }
            completion(.success(decoded))
        }
        dataTask.resume()
    }
}
