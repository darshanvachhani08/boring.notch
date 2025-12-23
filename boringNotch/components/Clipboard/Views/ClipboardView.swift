//
//  ClipboardView.swift
//  boringNotch
//

import SwiftUI

struct ClipboardView: View {
    @EnvironmentObject var vm: BoringViewModel
    @StateObject private var clipboardManager = ClipboardManager.shared
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(spacing: 8) {
                Image(systemName: "doc.on.clipboard.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.gray)
                
                Text("\(clipboardManager.items.count)")
                    .font(.system(.caption, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(.gray)
                
                Spacer()
            }
            .frame(width: 60)
            .padding(.top, 12)
            
            panel
        }
        .frame(maxHeight: .infinity)
    }
    
    var panel: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(Color.white.opacity(0.05))
            .overlay {
                content
            }
            .frame(maxHeight: .infinity)
            .clipped()
    }
    
    var content: some View {
        Group {
            if clipboardManager.items.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "doc.on.clipboard")
                        .symbolVariant(.fill)
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(.white, .gray)
                        .imageScale(.large)
                    
                    Text("Clipboard is empty")
                        .foregroundStyle(.gray)
                        .font(.system(.title3, design: .rounded))
                        .fontWeight(.medium)
                }
            } else {
                VStack(spacing: 0) {
                    HStack {
                        Text("Recently Copied")
                            .font(.system(.headline, design: .rounded))
                            .foregroundColor(.gray)
                        Spacer()
                        Button(action: {
                            clipboardManager.clearAll()
                        }) {
                            Text("Clear All")
                                .font(.system(.caption, design: .rounded))
                                .foregroundColor(.red.opacity(0.8))
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(.horizontal)
                    .padding(.top, 12)
                    .padding(.bottom, 8)
                    
                    ScrollView {
                        VStack(spacing: 4) {
                            ForEach(clipboardManager.items) { item in
                                ClipboardItemRow(item: item)
                            }
                        }
                        .padding(.horizontal, 8)
                        .padding(.bottom, 12)
                    }
                    .scrollIndicators(.never)
                }
            }
        }
    }
}

struct ClipboardItemRow: View {
    let item: ClipboardItem
    @ObservedObject private var clipboardManager = ClipboardManager.shared
    @State private var isHovered = false
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(item.content)
                    .lineLimit(1)
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundColor(.white)
                
                Text(item.timestamp, style: .time)
                    .font(.system(size: 10, design: .rounded))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            if isHovered {
                HStack(spacing: 8) {
                    Button(action: {
                        clipboardManager.copyToPasteboard(item)
                    }) {
                        Image(systemName: "doc.on.doc.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.accentColor)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Button(action: {
                        clipboardManager.removeItem(item)
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.red.opacity(0.7))
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(isHovered ? Color.white.opacity(0.1) : Color.clear)
        .cornerRadius(8)
        .onHover { isHovered = $0 }
        .onTapGesture {
            clipboardManager.copyToPasteboard(item)
        }
    }
}
