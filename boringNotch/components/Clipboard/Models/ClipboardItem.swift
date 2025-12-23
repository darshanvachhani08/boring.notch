//
//  ClipboardItem.swift
//  boringNotch
//

import Foundation
import Defaults

struct ClipboardItem: Identifiable, Codable, Equatable, Defaults.Serializable {
    let id: UUID
    let content: String
    let timestamp: Date
    
    init(id: UUID = UUID(), content: String, timestamp: Date = Date()) {
        self.id = id
        self.content = content
        self.timestamp = timestamp
    }
}
