//
//  GameView.swift
//  MagicTile
//
//  Created by Hongyu on 6/5/19.
//  Copyright © 2019 Cyandev. All rights reserved.
//

import SwiftUI

extension Edge {
    
    static func from(_ from: GameLogic.Direction) -> Self {
        switch from {
        case .down:
            return .top
        case .up:
            return .bottom
        case .left:
            return .trailing
        case .right:
            return .leading
        }
    }
    
}

struct GameView : View {
    
    @State var ignoreGesture = false
    @State var showNewGameConfirm = false
    @EnvironmentObject var gameLogic: GameLogic
    
    fileprivate struct LayoutTraits {
        let bannerOffset: CGSize
        let showsBanner: Bool
        let containerAlignment: Alignment
    }
    
    fileprivate func layoutTraits(`for` proxy: GeometryProxy) -> LayoutTraits {
#if os(macOS)
        let landscape = false
#else
        let landscape = proxy.size.width > proxy.size.height
#endif
        
        return LayoutTraits(
            bannerOffset: landscape
                ? .init(width: 32, height: 0)
                : .init(width: 0, height: 32),
            showsBanner: landscape ? proxy.size.width > 720 : proxy.size.height > 550,
            containerAlignment: landscape ? .leading : .top
        )
    }
    
    var gestureEnabled: Bool {
        // Existed for future usage.
#if os(macOS) || targetEnvironment(macCatalyst)
        return false
#else
        return true
#endif
    }
    
    var gesture: some Gesture {
        let threshold: CGFloat = 44
        let drag = DragGesture()
            .onChanged { v in
                guard !self.ignoreGesture else { return }
                
                guard abs(v.translation.width) > threshold ||
                    abs(v.translation.height) > threshold else {
                    return
                }
                
                withTransaction(Transaction(animation: .spring())) {
                    self.ignoreGesture = true
                    
                    if v.translation.width > threshold {
                        // Move right
                        self.gameLogic.move(.right)
                    } else if v.translation.width < -threshold {
                        // Move left
                        self.gameLogic.move(.left)
                    } else if v.translation.height > threshold {
                        // Move down
                        self.gameLogic.move(.down)
                    } else if v.translation.height < -threshold {
                        // Move up
                        self.gameLogic.move(.up)
                    }
                }
            }
            .onEnded { _ in
                self.ignoreGesture = false
            }
        return drag
    }
    
    fileprivate func scoreCard(title: String, value: Int) -> some View {
        VStack(spacing: 1) {
            Text(title)
                .font(Font.system(size: 10).weight(.bold))
                .foregroundColor(Color.white.opacity(0.75))
            Text("\(value)")
                .font(Font.system(size: 20).weight(.heavy))
                .foregroundColor(Color.white)
        }
        .frame(minWidth: 62)
        .padding(EdgeInsets(top: 6, leading: 10, bottom: 6, trailing: 10))
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white.opacity(0.16))
        )
    }
    
    var newGameButton: some View {
        Button(action: {
            if self.gameLogic.score > 0 && !self.gameLogic.isGameOver {
                self.showNewGameConfirm = true
            } else {
                self.gameLogic.newGame()
            }
        }) {
            Text("New Game")
                .font(Font.system(size: 17).weight(.bold))
                .foregroundColor(Color.white)
                .padding(EdgeInsets(top: 11, leading: 30, bottom: 11, trailing: 30))
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red:0.42, green:0.26, blue:0.85, opacity:1.00),
                                Color(red:0.30, green:0.17, blue:0.62, opacity:1.00)
                            ]),
                            startPoint: .top, endPoint: .bottom))
                        .shadow(color: Color.black.opacity(0.35), radius: 4, x: 0, y: 3)
                )
        }
        .alert(isPresented: $showNewGameConfirm) {
            Alert(
                title: Text("Start a new game?"),
                message: Text("Your current game will be lost."),
                primaryButton: .destructive(Text("New Game")) {
                    self.gameLogic.newGame()
                },
                secondaryButton: .cancel()
            )
        }
    }
    
    var gameOverOverlay: some View {
        ZStack {
            Color.black.opacity(0.5)
                .edgesIgnoringSafeArea(.all)
            VStack(spacing: 10) {
                Text("Game Over")
                    .font(Font.system(size: 32).weight(.black))
                    .foregroundColor(Color.white)
                Text("Score: \(self.gameLogic.score)")
                    .font(Font.system(size: 18).weight(.semibold))
                    .foregroundColor(Color.white.opacity(0.9))
                Text("Best: \(self.gameLogic.bestScore)")
                    .font(Font.system(size: 14).weight(.medium))
                    .foregroundColor(Color.white.opacity(0.7))
                Button(action: { self.gameLogic.newGame() }) {
                    Text("Play Again")
                        .font(Font.system(size: 17).weight(.bold))
                        .foregroundColor(Color(red:0.24, green:0.14, blue:0.50, opacity:1.00))
                        .padding(EdgeInsets(top: 11, leading: 26, bottom: 11, trailing: 26))
                        .background(RoundedRectangle(cornerRadius: 12).fill(Color.white))
                }
                .padding(.top, 6)
            }
            .padding(28)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(red:0.19, green:0.13, blue:0.40, opacity:1.00))
                    .shadow(color: Color.black.opacity(0.5), radius: 12, x: 0, y: 6)
            )
            .padding(36)
        }
    }
    
    var content: some View {
        GeometryReader { proxy in
            ZStack {
                Rectangle()
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red:0.13, green:0.08, blue:0.30, opacity:1.00),
                            Color(red:0.24, green:0.12, blue:0.45, opacity:1.00),
                            Color(red:0.10, green:0.06, blue:0.22, opacity:1.00)
                        ]),
                        startPoint: .top, endPoint: .bottom))
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 14) {
                    HStack(alignment: .center, spacing: 10) {
                        Text("Magic Tile")
                            .font(Font.system(size: 30).weight(.black))
                            .foregroundColor(Color.white)
                            .shadow(color: Color.black.opacity(0.35), radius: 4, x: 0, y: 2)
                        Spacer()
                        self.scoreCard(title: "SCORE", value: self.gameLogic.score)
                        self.scoreCard(title: "BEST", value: self.gameLogic.bestScore)
                    }
                    
                    BlockGridView(matrix: self.gameLogic.blockMatrix,
                                  blockEnterEdge: .from(self.gameLogic.lastGestureDirection))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                    self.newGameButton
                    
                    #if os(iOS)
                    BannerAdView()
                        .frame(height: 50)
                    #endif
                }
                .padding(16)
                
                if self.gameLogic.isGameOver {
                    self.gameOverOverlay
                        .onAppear {
                            #if os(iOS)
                            InterstitialAd.shared.show()
                            #endif
                        }
                }
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
    }
    
    var body: AnyView {
        return gestureEnabled ? (
            content
                .gesture(gesture, including: .all)>*
        ) : content>*
    }
    
}

#if DEBUG
struct GameView_Previews : PreviewProvider {
    
    static var previews: some View {
        GameView()
            .environmentObject(GameLogic())
    }
    
}
#endif
