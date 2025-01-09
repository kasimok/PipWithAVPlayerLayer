//
//  ContentView.swift
//  AVPlayer
//
//  Created by 0x67 on 2025-01-09.
//

import SwiftUI
import AVKit

struct PlayerView: UIViewRepresentable {
    class Coordinator {
        var player: AVPlayer
        
        init(player: AVPlayer) {
            self.player = player
        }
    }
    
    func makeCoordinator() -> Coordinator {
        let player = AVPlayer(url: URL(string: "http://aktv.top/AKTV/live/aktv/null-6/AKTV.m3u8")!)
        return Coordinator(player: player)
    }
    
    func makeUIView(context: Context) -> UIView {
        let view = PlayerUIView()
        let player = context.coordinator.player
        view.playerLayer.player = player
        player.play()
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}

class PlayerUIView: UIView {
    var playerLayer: AVPlayerLayer
    
    override init(frame: CGRect) {
        self.playerLayer = AVPlayerLayer()
        super.init(frame: frame)
        self.layer.addSublayer(playerLayer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = self.bounds
    }
}

struct ContentView: View {
    var body: some View {
        PlayerView()
            .edgesIgnoringSafeArea(.all)
    }
}

#Preview {
    ContentView()
}
