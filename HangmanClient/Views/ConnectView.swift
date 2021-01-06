//
//  ConnectView.swift
//  HangmanClient
//
//  Created by Przemek Ambroży on 03/01/2021.
//

import SwiftUI

struct ConnectView: View {

    @ObservedObject
    var viewModel: ConnectViewModel

    var body: some View {
        VStack(alignment: .center, spacing: 16) {

            Text("Hangman")
                .font(.title)

            GroupBox(label: Text("Łączenie")) {
                VStack {

                    Text("Wpisz adres IP serwera gry:")
                    TextField("Adres IP", text: $viewModel.host)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 12)

                    Text("Port:")
                    TextField("Port", text: $viewModel.port, onCommit: {
                        viewModel.connect()
                    })
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 12)

                    Button(viewModel.isConnecting ? "Łączenie..." : "Połącz") {
                        viewModel.connect()
                    }
                    .disabled(!viewModel.canConnect || viewModel.isConnecting)
                }
                .padding(8.0)
            }

            // Error
            if let error = viewModel.connectionError {
                GroupBox(label: Text("Błąd").foregroundColor(.red)) {
                    Text(error)
                        .frame(maxWidth: .infinity)
                }
            }

            Spacer()

            Text("Copyright © \(year)")
                .font(.footnote)
        }
        .padding()
        .frame(minWidth: 300, minHeight: 400)

    }

    private var year: String {
        let current = Calendar.current.component(.year, from: Date())
        return String(max(current, 2021))
    }
}

struct ConnectView_Previews: PreviewProvider {
    static var previews: some View {
        ConnectView(viewModel: ConnectViewModel())
            .frame(width: 300, height: 400, alignment: .center)
    }
}
