//
//  ContentView.swift
//  pianoease
//
//  Created by zhudong on 7/8/26.
//

import SwiftUI

struct ContentView: View {
    @State private var midiManager = MIDIManager()
    
    var body: some View {
        NavigationStack {
            SongListView()
        }
        .environment(midiManager)
    }
}

#Preview {
    ContentView()
}
