//
//  JoinRoom.swift
//  ExampleUI
//
//  Created by Przemek Ambroży on 04/12/2020.
//

import SwiftUI

struct JoinRoom: View {

    @ObservedObject
    var viewModel: HomeViewModel

    @State
    private var pin = ""

    var body: some View {

        VStack {

            Text("Dołącz do pokoju")
                .font(.headline)

            Text("Aby dołączyć do pokoju, wpisz 6-cyfrowy kod.")

            TextField("PIN", text: $pin)
                .font(.system(size: 32.0, weight: .semibold, design: .monospaced))
                .lineLimit(1)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32.0)
                .padding(.vertical, 16.0)

            Button("Dołącz") {
                self.viewModel.joinRoom(with: pin)
            }
            .disabled(!verifyPin())

        }
        .padding()
    }

    private func verifyPin() -> Bool {
        return pin.count == 6 &&
            CharacterSet.decimalDigits
            .isSuperset(of: CharacterSet(charactersIn: pin))
    }
}

struct JoinRoom_Previews: PreviewProvider {
    static var previews: some View {
        JoinRoom(viewModel: HomeViewModel(Connection(hostname: "127.0.0.1", port: 1234)))
            .frame(width: 800.0, height: 600.0)
    }
}
