//
//  ContentView.swift
//  HangmanClient
//
//  Created by Przemek Ambroży on 14/12/2020.
//

import SwiftUI

struct ContentView: View {
    @State
    private var inRoom = false

    var body: some View {

        ZStack {
            if inRoom {
                Text("In room")
                //InRoomView()
            } else {
                HomeView(viewModel: HomeViewModel(Connection(hostname: "127.0.0.1", port: 1234)))
            }

        }
        .frame(minWidth: 800, maxWidth: .infinity, minHeight: 600, maxHeight: .infinity)
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
