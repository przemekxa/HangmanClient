//
//  WordView.swift
//  HangmanClient
//
//  Created by Przemek Ambroży on 03/01/2021.
//

import SwiftUI

struct WordView: View {

    @Binding
    var chars: [Character?]

    var body: some View {
        HStack(alignment: .center, spacing: 8.0) {
            ForEach(chars, id: \.self) { char in
                if let char = char {
                    Text(String(char))
                        .padding(4.0)
                } else {
                    Text(" ")
                        .padding(4.0)
                        .background(Color.primary.opacity(0.3))
                }
            }
            .font(.system(size: 16.0, weight: .bold, design: .monospaced))
        }
    }
}

struct WordView_Previews: PreviewProvider {
    static var previews: some View {
        WordView(chars: .constant(["a", "b", nil, nil, "d"]))
    }
}
