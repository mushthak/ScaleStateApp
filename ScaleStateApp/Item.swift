//
//  Item.swift
//  ScaleStateApp
//
//  Created by Mushthak Ebrahim on 13/01/25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
