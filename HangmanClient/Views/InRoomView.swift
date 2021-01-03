//
//  InRoomView.swift
//  ExampleUI
//
//  Created by Przemek Ambroży on 04/12/2020.
//

import SwiftUI

struct InRoomView: View {

    @ObservedObject
    var viewModel: RoomViewModel

    @State
    private var players = ["Jeden", "Dwa"]

    @State
    private var ready = false

    var body: some View {
        HStack(alignment: .center, spacing: 16.0) {

            VStack(alignment: .leading, spacing: 16.0) {

                GroupBox(label: Text("PIN"), content: {
                    Text(viewModel.status.id)
                        .kerning(8.0)
                        .font(.system(size: 32.0, weight: .semibold, design: .monospaced))
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .padding(4.0)
                })

                RoomInfoView(status: viewModel.status)

                if let error = viewModel.error {
                    GroupBox(label: Text("Błąd").foregroundColor(.red)) {
                        Text(error)
                            .frame(maxWidth: .infinity)
                    }
                }

                Spacer()

                HStack {
                    Button("Opuść pokój") {
                        viewModel.leave()
                    }

                    if viewModel.isHost {
                        Button(action: {
                            viewModel.play()
                        }, label: {
                            Text("🎮 Graj")
                                .fontWeight(.semibold)
                        })
                        .padding(.leading, 4.0)
                    }
                }
            }
            

            GroupBox(label: Text("Gracze")) {
                ScrollView {
                    ForEach(viewModel.status.players, id: \.self) { player in
                        PlayerCellView(player: player,
                                       hostFeatures: viewModel.isHost,
                                       isYou: player.id == viewModel.userID,
                                       makeHost: { viewModel.makeHost(player) },
                                       kick: { viewModel.kick(player) })
                    }
                }
            }

        }
        .frame(maxHeight: 800)
        .padding(16.0)
    }

    private func gameTimeString(_ gameTime: UInt16) -> String {
        String(format: "%02d:%02d", gameTime / 60, gameTime % 60)
    }

}

struct InRoomView_Previews: PreviewProvider {
    static var previews: some View {
        InRoomView(viewModel: RoomViewModel(Connection(hostname: "127.0.0.1", port: 1234),
                                            userID: 456,
                                            initialStatus: RoomStatus(language: Language("pl"), wordLength: 8, gameTime: 30, healthPoints: 4, id: "123457", players: [Player(id: 123, nick: "One"), Player(id: 456, nick: "Other", isHost: true)])))
            .frame(width: 800, height: 600.0)
    }
}
