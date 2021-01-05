//
//  PlayerInGameCellView.swift
//  HangmanClient
//
//  Created by Przemek Ambroży on 05/01/2021.
//

import SwiftUI

struct PlayerInGameCellView: View {

    @State
    var player: PlayerInGame

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(player.nick)
                    .font(.title)
                    .fontWeight(.bold)
                Text("(#" + String(player.id) + ")")
                    .font(.caption)
            }
            .padding(.top, 12.0)
            HStack {
                Text("Punkty:")
                    .font(.headline)
                    .fontWeight(.regular)
                Text(String(player.points))
                    .font(.headline)
                    .fontWeight(.bold)
            }
            HStack {
                Text("Życie:")
                    .font(.headline)
                    .fontWeight(.regular)
                Text(String(repeating: "❤️", count: Int(player.remainingHealth)))
            }
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("Odgadnięte hasło:")
                    .font(.headline)
                    .fontWeight(.regular)
                Text(player.guessed ? "✅ tak" : "nie")
                    .font(.headline)
                    .fontWeight(player.guessed ? .bold : .regular)
            }
            .padding(.bottom, 12.0)
            Divider()
        }
    }
}

struct PlayerInGameCellView_Previews: PreviewProvider {
    static var previews: some View {
        PlayerInGameCellView(player: PlayerInGame(id: 123,
                                                  nick: "Nick",
                                                  points: 1000,
                                                  remainingHealth: 5,
                                                  guessed: false))
    }
}
