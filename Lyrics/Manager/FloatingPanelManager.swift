//
//  FloatingPanelManager.swift
//  Lyrics
//
//  Created by Hlwan Aung Phyo on 2025/02/18.
//

import SwiftUI


class FloatingPanelManager: ObservableObject{
    static let shared = FloatingPanelManager()
    private var panel: FloatingPanel<FloatingWindow>?

    func show() {
        if panel == nil {
            let binding = Binding<Bool>(
                get: { true },
                set: { _ in }
            )
            
            panel = FloatingPanel(
                view: { FloatingWindow() },
                isPresented: binding
            )
        }
        panel?.makeKeyAndOrderFront(nil)
    }
}
