//
//  ContentView.swift
//  Lyrics
//
//  Created by Hlwan Aung Phyo on 2025/02/15.
//

import SwiftUI

struct ContentView: View {
    
    @State var vm = MainViewModel()
    
    var body: some View {
        VStack {
            Text(vm.currentLyrics)
                .font(.title)
                .animation(.easeInOut, value: vm.currentLyrics)
            Text("\(vm.currentTime) s")
                .font(.title2)
            
         

        }
        .onAppear {
            
        }
        .frame(minWidth: 300, minHeight: 400)
    }
}

#Preview {
    ContentView()
}
