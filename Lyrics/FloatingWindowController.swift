//
//  FloatingWindowController.swift
//  Lyrics
//
//  Created by Hlwan Aung Phyo on 2025/02/18.
//

import SwiftUI

class FloatingPanel<Content: View>: NSPanel {
    @Binding var isPresented: Bool
    
    init(view: () -> Content,
         contentRect: NSRect,
         backing: NSWindow.BackingStoreType = .buffered,
         defer flag: Bool = false,
         isPresented: Binding<Bool>) {
        
        self._isPresented = isPresented
        
        super.init(
            contentRect: contentRect,
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
        
        contentView = NSHostingView(
            rootView: view()
                .ignoresSafeArea()
                .environment(\.floatingPanel, self))
        
        contentView?.window?.backgroundColor = NSColor.clear
    }
   
}
