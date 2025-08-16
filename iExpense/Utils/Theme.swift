//
//  Colours.swift
//  iExpense
//

import SwiftUI

struct Theme {
    struct Gradients {
        static let lightBlue = LinearGradient(
            colors: [
                Color(red: 0.72, green: 0.75, blue: 1.0), // violet lavande pâle
                Color(red: 0.85, green: 0.90, blue: 1.0), // bleu clair givré
                Color(red: 1.0, green: 0.88, blue: 0.95)  // rose poudré
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        static let lightPurple =  RadialGradient(
            gradient: Gradient(colors: [
                Color(red: 0.75, green: 0.85, blue: 1.0).opacity(0.6),
                Color(red: 0.82, green: 0.70, blue: 1.0).opacity(0.5),
                Color(red: 1.0, green: 0.70, blue: 0.85).opacity(0.6)
            ]),
            center: .center,
            startRadius: 10,
            endRadius: 260
        )
        
        static let midBlue = LinearGradient(
            colors: [
                Color(red: 0.52, green: 0.55, blue: 1.0), // violet lavande pâle
                Color(red: 0.45, green: 0.50, blue: 1.0), // bleu clair givré
                Color(red: 0.55, green: 0.60, blue: 1.0), // bleu clair givré
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

//    Rectangle().fill(Theme.Gradients.whiteToBlackCenter)

