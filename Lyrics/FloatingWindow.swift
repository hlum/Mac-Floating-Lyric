//
//  FloatingWindow.swift
//  Lyrics
//
//  Created by Hlwan Aung Phyo on 2025/02/18.
//
import SwiftUI

struct FloatingWindow: View {
    @State var vm = MainViewModel()

    var body: some View {
        VStack {
            Text(vm.currentLyrics)
                .font(.title)
                .animation(.easeInOut, value: vm.currentLyrics)
        }
        .frame(minWidth: minWidth, minHeight: minHeight)
    }
    
    private var minWidth: CGFloat {
        min(300, CGFloat(vm.currentLyrics.count) * 30)
    }

    private var minHeight: CGFloat {
        min(100, 50 + CGFloat(vm.currentLyrics.count) * 2)
    }
    
}

