//
//  CreateRoom.swift
//  ExampleUI
//
//  Created by Przemek Ambroży on 04/12/2020.
//

import SwiftUI

struct CreateRoom: View {

    init(possibleSettings: PossibleRoomSettings, viewModel: HomeViewModel) {
        self.possibleSettings = possibleSettings
        self.viewModel = viewModel
        self._language = State(initialValue: possibleSettings.languages.first!.id)
        self._wordLength = State(initialValue: Double(possibleSettings.wordLength.lowerBound))
        self._gameTime = State(initialValue: Double(possibleSettings.gameTime.lowerBound))
        self._healthPoints = State(initialValue: possibleSettings.healthPoints.lowerBound)
        self._maxPlayers = State(initialValue: Double(possibleSettings.playerCount.lowerBound))
    }


    var possibleSettings: PossibleRoomSettings

    @ObservedObject
    var viewModel: HomeViewModel

    @State private var language: String
    @State private var wordLength: Double
    @State private var gameTime: Double
    @State private var healthPoints: UInt8
    @State private var maxPlayers: Double

    var body: some View {
        VStack {
            Text("Utwórz pokój")
                .font(.headline)

            Text("Utwórz i skonfiguruj nowy pokój.")
                .padding(.bottom, 16.0)

            VStack {
                Picker("🌐 Język", selection: $language) {
                    ForEach(possibleSettings.languages) { lang in
                        Text(lang.name).tag(lang.id)
                    }
                }

                HStack(alignment: .center, spacing: 8.0) {
                    Slider(value: $wordLength,
                           in: toDouble(possibleSettings.wordLength),
                           step: 1.0,
                           label: { Text("🔢 Długość słowa") })
                    Text("\(Int(wordLength)) liter")
                        .frame(width: 64.0, alignment: .trailing)
                }

                HStack(alignment: .center, spacing: 8.0) {
                    Slider(value: $gameTime,
                           in: toDouble(possibleSettings.gameTime),
                           label: { Text("⏰ Długość gry") })
                    Text(gameTimeString())
                        .frame(width: 64.0, alignment: .trailing)
                }

                Picker("❤️ Punkty zdrowia", selection: $healthPoints) {
                    ForEach(possibleSettings.healthPoints, id: \.self) { i in
                        Text("\(i) punkty zdrowia").tag(i)
                    }
                }

                HStack(alignment: .center, spacing: 8.0) {
                    Slider(value: $maxPlayers,
                           in: toDouble(possibleSettings.playerCount),
                           step: 1.0,
                           label: { Text("👤 Maksymalna liczba graczy") })
                    Text("\(Int(maxPlayers)) graczy")
                        .frame(width: 64.0, alignment: .trailing)
                }

            }
            .padding(.bottom, 8.0)

            Button("Utwórz pokój", action: createRoom)
            .padding(.top, 8.0)

        }
        .padding(.horizontal, 16.0)
        .padding(.vertical, 16.0)
    }

    private func gameTimeString() -> String {
        let all = Int(floor(gameTime))
        let seconds = all % 60
        let minutes = all / 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    private func toDouble<T: BinaryInteger>(_ value: ClosedRange<T>) -> ClosedRange<Double> {
        Double(value.lowerBound)...Double(value.upperBound)
    }

    private func createRoom() {
        let settings = RoomSettings(language: Language(language),
                                    wordLength: UInt8(wordLength),
                                    gameTime: UInt16(gameTime),
                                    healthPoints: UInt8(healthPoints),
                                    maxPlayers: UInt8(maxPlayers))
        viewModel.createRoom(with: settings)
    }
}

struct CreateRoom_Previews: PreviewProvider {
    static var previews: some View {
        CreateRoom(possibleSettings:
                    PossibleRoomSettings(languages: [Language("pl"), Language("us")],
                                         wordLength: 3...30,
                                         gameTime: 30...300,
                                         healthPoints: 1...5,
                                         playerCount: 2...4), viewModel: HomeViewModel(Connection(hostname: "127.0.0.1", port: 1234)))
            .frame(width: 800.0, height: 600.0)
    }
}
