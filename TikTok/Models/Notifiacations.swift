//
//  Notifiacations.swift
//  TikTok
//
//  Created by mai nguyen on 12/13/21.
//

import Foundation


struct Notification {
    let text: String
    let date: Date
    
    
    static func mockData() -> [Notification]{
        return Array(0...100).compactMap {
            Notification(text: "Something happened: \($0)", date: Date())
        }
    }
}
