//
//  Item.swift
//  HPord
//
//  Created by Ville Sandgren on 2026-01-01.
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
