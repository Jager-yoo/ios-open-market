//
//  DateFormatter.swift
//  OpenMarket
//
//  Created by 예거 on 2022/01/04.
//

import Foundation

enum Utility {
    
    private static let dateFormatter = DateFormatter()
    
    static func formatDate(from date: String) -> Date {
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        return dateFormatter.date(from: date) ?? Date()
    }
}
