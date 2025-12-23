//
//  ClipboardManager.swift
//  boringNotch
//

import AppKit
import Combine
import Defaults
import SwiftUI

extension Defaults.Keys {
    static let clipboardHistory = Key<[ClipboardItem]>("clipboardHistory", default: [])
}

@MainActor
class ClipboardManager: ObservableObject {
    static let shared = ClipboardManager()
    
    @Published var items: [ClipboardItem] = [] {
        didSet {
            Defaults[.clipboardHistory] = items
        }
    }
    
    private var timer: Timer?
    private var lastChangeCount: Int
    
    private init() {
        self.lastChangeCount = NSPasteboard.general.changeCount
        self.items = Defaults[.clipboardHistory]
        startMonitoring()
    }
    
    func startMonitoring() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.checkPasteboard()
            }
        }
    }
    
    private func checkPasteboard() {
        let pasteboard = NSPasteboard.general
        guard pasteboard.changeCount != lastChangeCount else { return }
        lastChangeCount = pasteboard.changeCount
        
        if let content = pasteboard.string(forType: .string) {
            addItem(content)
        }
    }
    
    private func addItem(_ content: String) {
        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        // Don't re-add if the same as top item
        if let first = items.first, first.content == trimmed {
            return
        }
        
        // Remove if already exists elsewhere to move to top
        items.removeAll { $0.content == trimmed }
        
        let newItem = ClipboardItem(content: trimmed)
        withAnimation(.smooth) {
            items.insert(newItem, at: 0)
            
            // Limit to 50 items
            if items.count > 50 {
                items.removeLast()
            }
        }
    }
    
    func copyToPasteboard(_ item: ClipboardItem) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(item.content, forType: .string)
        lastChangeCount = pasteboard.changeCount // Avoid re-adding it
        
        // Move to top
        withAnimation(.smooth) {
            items.removeAll { $0.id == item.id }
            items.insert(ClipboardItem(content: item.content), at: 0)
        }
    }
    
    func removeItem(_ item: ClipboardItem) {
        withAnimation(.smooth) {
            items.removeAll { $0.id == item.id }
        }
    }
    
    func clearAll() {
        withAnimation(.smooth) {
            items.removeAll()
        }
    }
}
