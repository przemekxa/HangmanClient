//
//  RoomInfoView.swift
//  HangmanClient
//
//  Created by Przemek Ambroży on 03/01/2021.
//

import SwiftUI

struct RoomInfoView: View {

    var status: RoomStatus

    var body: some View {
        GroupBox(label: Text("Ustawienia pokoju")) {
            HStack(alignment: .center, spacing: 16.0) {
                Text(["🌐 Język",
                      "🔢 Długość słowa",
                      "⏰ Długość gry",
                      "❤️ Punkty zdrowia",
                      "👤 Max. graczy"].joined(separator: "\n"))
                    .lineSpacing(8.0)
                    .multilineTextAlignment(.trailing)

                Divider()

                Text([status.language.name,
                      String(status.wordLength) + " liter",
                      gameTimeString(status.gameTime),
                      String(status.healthPoints) + " punkty zdrowia",
                      String(status.maxPlayers) + " graczy"].joined(separator: "\n"))
                    .lineSpacing(8.0)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .fixedSize(horizontal: false, vertical: true)
            .padding(8.0)
        }
    }

    private func gameTimeString(_ gameTime: UInt16) -> String {
        String(format: "%02d:%02d", gameTime / 60, gameTime % 60)
    }
}

struct RoomInfoView_Previews: PreviewProvider {
    static var previews: some View {
        RoomInfoView(status: RoomStatus(language: Language("pl"), wordLength: 8, gameTime: 30, healthPoints: 4, id: "123457", maxPlayers: 5, players: [Player(id: 123, nick: "One"), Player(id: 456, nick: "Other", isHost: true)]))
    }
}
