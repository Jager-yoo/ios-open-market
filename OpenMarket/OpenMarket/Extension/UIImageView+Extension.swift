//
//  UIImageView+Extension.swift
//  OpenMarket
//
//  Created by lily on 2022/01/19.
//

import UIKit

protocol Cancellable {
    
    func cancel()
}

extension URLSessionDataTask: Cancellable { }

extension UIImageView {
    
    func setImage(with url: URL, invalidImage: UIImage) -> Cancellable? {
        let cacheKey = url.absoluteString as NSString
        
        if let cachedImage = ImageCacheManager.shared.object(forKey: cacheKey) {
            self.image = cachedImage
            return nil
        }
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let self = self else { return }
            
            if let error = error, error.localizedDescription != "cancelled" {
                DispatchQueue.main.async {
                    self.image = invalidImage
                }
                print("❌ 에러 : \(error.localizedDescription) 발생!")
                return
            } else {
                DispatchQueue.main.async {
                    guard let imageData = data,
                          let image = UIImage(data: imageData) else { return }
                    self.image = image
                    ImageCacheManager.shared.setObject(image, forKey: cacheKey)
                }
            }
        }
        task.resume()
        return task
    }
}
