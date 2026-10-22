//
//  BlockView.swift
//  SwiftUI2048
//
//  Created by Hongyu on 6/5/19.
//  Copyright © 2019 Cyandev. All rights reserved.
//
//  Meggic Tile restyle: tiles are drawn as glossy 3D blocks —
//  a vertical gradient body, a gloss highlight on the top half,
//  a shaded bottom edge, an embossed number and a soft drop shadow.
//  Game logic is untouched; only the drawing changed.
//

import SwiftUI

struct BlockView : View {

    // (top color, bottom color, text color) per tile value: 2, 4, 8, ... 2048
    fileprivate let colorScheme: [(Color, Color, Color)] = [
        // 2
        (Color(red:0.96, green:0.90, blue:0.78, opacity:1.00), Color(red:0.89, green:0.80, blue:0.62, opacity:1.00), Color(red:0.36, green:0.29, blue:0.19, opacity:1.00)),
        // 4
        (Color(red:0.96, green:0.82, blue:0.58, opacity:1.00), Color(red:0.90, green:0.68, blue:0.40, opacity:1.00), Color(red:0.36, green:0.29, blue:0.19, opacity:1.00)),
        // 8
        (Color(red:0.98, green:0.68, blue:0.32, opacity:1.00), Color(red:0.94, green:0.53, blue:0.13, opacity:1.00), Color.white),
        // 16
        (Color(red:0.98, green:0.58, blue:0.25, opacity:1.00), Color(red:0.93, green:0.42, blue:0.11, opacity:1.00), Color.white),
        // 32
        (Color(red:0.98, green:0.50, blue:0.35, opacity:1.00), Color(red:0.94, green:0.33, blue:0.19, opacity:1.00), Color.white),
        // 64
        (Color(red:0.97, green:0.38, blue:0.27, opacity:1.00), Color(red:0.90, green:0.22, blue:0.13, opacity:1.00), Color.white),
        // 128
        (Color(red:0.96, green:0.83, blue:0.38, opacity:1.00), Color(red:0.89, green:0.66, blue:0.16, opacity:1.00), Color.white),
        // 256
        (Color(red:0.95, green:0.78, blue:0.28, opacity:1.00), Color(red:0.87, green:0.60, blue:0.10, opacity:1.00), Color.white),
        // 512
        (Color(red:0.94, green:0.73, blue:0.20, opacity:1.00), Color(red:0.85, green:0.55, blue:0.06, opacity:1.00), Color.white),
        // 1024
        (Color(red:0.93, green:0.68, blue:0.14, opacity:1.00), Color(red:0.82, green:0.50, blue:0.03, opacity:1.00), Color.white),
        // 2048
        (Color(red:0.95, green:0.72, blue:0.10, opacity:1.00), Color(red:0.85, green:0.54, blue:0.02, opacity:1.00), Color.white),
    ]

    fileprivate let number: Int?

    // This is required to make the Text element be a different
    // instance every time the block is updated. Otherwise, the
    // text will be incorrectly rendered.
    //
    // TODO: File a bug.
    fileprivate let textId: String?

    init(block: IdentifiedBlock) {
        self.number = block.number
        self.textId = "\(block.id):\(block.number)"
    }

    fileprivate init() {
        self.number = nil
        self.textId = ""
    }

    static func blank() -> Self {
        return self.init()
    }

    fileprivate var numberText: String {
        guard let number = number else {
            return ""
        }
        return String(number)
    }

    fileprivate var fontSize: CGFloat {
        let textLength = numberText.count
        if textLength < 3 {
            return 32
        } else if textLength < 4 {
            return 18
        } else {
            return 12
        }
    }

    fileprivate var colors: (top: Color, bottom: Color, text: Color) {
        let index = Int(log2(Double(number ?? 2))) - 1
        let clamped = max(0, min(index, colorScheme.count - 1))
        let entry = colorScheme[clamped]
        return (entry.0, entry.1, entry.2)
    }

    // MARK: Body

    var body: some View {
        let isBlank = (number == nil)
        let tileShape = RoundedRectangle(cornerRadius: 10, style: .continuous)

        return ZStack {
            if isBlank {
                // Empty slot: a recessed socket carved into the board.
                tileShape
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red:0.32, green:0.26, blue:0.22, opacity:1.00),
                            Color(red:0.42, green:0.35, blue:0.29, opacity:1.00)
                        ]),
                        startPoint: .top, endPoint: .bottom))
                    .overlay(
                        tileShape.stroke(Color.black.opacity(0.25), lineWidth: 1)
                    )
                    .zIndex(1)
            } else {
                // Tile body: vertical gradient gives the block its volume.
                tileShape
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [colors.top, colors.bottom]),
                        startPoint: .top, endPoint: .bottom))
                    .zIndex(1)

                // Gloss: a soft light falling on the top half of the block.
                tileShape
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0.38),
                            Color.white.opacity(0.0)
                        ]),
                        startPoint: .top, endPoint: .center))
                    .zIndex(2)

                // Edge light: a bright rim on top, a dark rim at the bottom.
                tileShape
                    .stroke(LinearGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0.55),
                            Color.black.opacity(0.18)
                        ]),
                        startPoint: .top, endPoint: .bottom), lineWidth: 1)
                    .zIndex(3)
            }

            Text(numberText)
                .font(Font.system(size: fontSize).bold())
                .foregroundColor(colors.text)
                .shadow(color: Color.black.opacity(isBlank ? 0 : 0.28), radius: 1, x: 0, y: 1)
                .id(textId!)
                // ⚠️ Gotcha: `zIndex` is important for removal transition!!
                .zIndex(1000)
                .transition(AnyTransition.opacity.combined(with: .scale))
        }
        .shadow(color: Color.black.opacity(isBlank ? 0 : 0.30), radius: 3, x: 0, y: 2)
    }

}

// MARK: - Previews

#if DEBUG
struct BlockView_Previews : PreviewProvider {

    static var previews: some View {
        Group {
            ForEach((1...11).map { Int(pow(2, Double($0))) }, id: \.self) { i in
                BlockView(block: IdentifiedBlock(id: 0, number: i))
                    .previewLayout(.sizeThatFits)
            }

            BlockView.blank()
                .previewLayout(.sizeThatFits)
        }
    }

}
#endif
