//
//  FloatingWindowController.swift
//  Lyrics
//
//  Created by Hlwan Aung Phyo on 2025/02/18.
//

import SwiftUI

enum WindowXYPositionKeys: String {
    case windowXPosition = "windowXPosition"
    case windowYPosition = "windowYPosition"
}

class FloatingPanel<Content: View>: NSPanel, NSWindowDelegate {
    private let defaultX = UserDefaults.standard.double(forKey: WindowXYPositionKeys.windowXPosition.rawValue)
    private let defaultY = UserDefaults.standard.double(forKey: WindowXYPositionKeys.windowYPosition.rawValue)
   
    @Binding var isPresented: Bool
    
    init(view: () -> Content,
         backing: NSWindow.BackingStoreType = .buffered,
         defer flag: Bool = false,
         isPresented: Binding<Bool>) {
        
        self._isPresented = isPresented
        
        // Use saved position if available, otherwise default values
        let x = defaultX == 0 ? 200 : defaultX
        let y = defaultY == 0 ? 100 : defaultY
        let savedRect = NSRect(x: x, y: y, width: 400, height: 100)
        
        super.init(
            contentRect: savedRect,
            styleMask: [.nonactivatingPanel, .titled, .resizable, .closable, .fullSizeContentView],
            backing: backing,
            defer: flag
        )
                
        isFloatingPanel = true
        level = .floating
        
        collectionBehavior.insert(.fullScreenAuxiliary)
        
        titleVisibility = .hidden
        titlebarAppearsTransparent = true
        
        hidesOnDeactivate = false
        
        standardWindowButton(.closeButton)?.isHidden = true
        standardWindowButton(.miniaturizeButton)?.isHidden = true
        standardWindowButton(.zoomButton)?.isHidden = true
        
        animationBehavior = .utilityWindow
        
        collectionBehavior = [.canJoinAllSpaces, .canJoinAllApplications]
        
        delegate = self
        
        contentView = NSHostingView(
            rootView: view()
                .ignoresSafeArea()
                .environment(\.floatingPanel, self))
        
        contentView?.window?.backgroundColor = NSColor.clear
    }
    
    func windowDidMove(_ notification: Notification) {
        UserDefaults.standard.set(frame.origin.x, forKey: WindowXYPositionKeys.windowXPosition.rawValue)
        UserDefaults.standard.set(frame.origin.y, forKey: WindowXYPositionKeys.windowYPosition.rawValue)
    }
}
