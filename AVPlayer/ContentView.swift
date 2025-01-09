//
//  ContentView.swift
//  AVPlayer
//
//  Created by 0x67 on 2025-01-09.
//

import SwiftUI
import AVKit


struct PlayerView: UIViewRepresentable {
    
    @ObservedObject
    public private(set) var coordinator: Coordinator
    
    public init(coordinator: Coordinator) {
        self.coordinator = coordinator
    }
    
}

extension PlayerView {
    
    class Coordinator: NSObject, AVPictureInPictureControllerDelegate, ObservableObject {
        var player: AVPlayer
        var pipController: AVPictureInPictureController?
        var pipPossibleObservation: NSKeyValueObservation?
        var isPlaying = true
        var layer: AVPlayerLayer
        @Published
        public var pipPossible: Bool = false
        
        convenience override init() {
            let player =  AVPlayer(url: URL(string: "http://aktv.top/AKTV/live/aktv/null-6/AKTV.m3u8")!)
            self.init(player: player)
        }
        
        public func pause() {
            player.pause()
        }
        
        public func play() {
            player.play()
        }
        
        init(player: AVPlayer) {
            self.player = player
            let layer = AVPlayerLayer(player: player)
            self.layer = layer
            super.init()
            
            if AVPictureInPictureController.isPictureInPictureSupported() {
                pipController = AVPictureInPictureController(playerLayer: layer)
                pipController?.delegate = self
                
                // Observe the PiP possibility and update pipState.isPossible
                pipPossibleObservation = pipController?.observe(
                    \.isPictureInPicturePossible,
                     options: [.initial, .new]
                ) { [weak self] _, change in
                    guard let self = self else { return }
                    let possible = change.newValue ?? false
                    debugPrint(">>> possible: \(possible)")
                    Task { @MainActor [weak self] in
                        guard let self else { return }
                        pipPossible = possible
                    }
                }
            }
        }
        
        func pictureInPictureControllerDidStopPictureInPicture(
            _ pictureInPictureController: AVPictureInPictureController
        ) {
            debugPrint("pip STOPPED")
        }
        
        func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController) async -> Bool {
            true
        }
        
        func pictureInPictureControllerDidStartPictureInPicture(
            _ pictureInPictureController: AVPictureInPictureController
        ) {
            debugPrint("pip STARTED")
        }
        
        func pictureInPictureControllerWillStopPictureInPicture(
            _ pictureInPictureController: AVPictureInPictureController
        ) {
            debugPrint("pip will STOP")
        }
        
        func pictureInPictureControllerWillStartPictureInPicture(
            _ pictureInPictureController: AVPictureInPictureController
        ) {
            debugPrint("pip will START")
        }
        
        func pictureInPictureController(
            _ pictureInPictureController: AVPictureInPictureController,
            failedToStartPictureInPictureWithError error: any Error
        ) {
            debugPrint("failed to start PiP, error: \(error)")
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return coordinator
    }
    
    func makeUIView(context: Context) -> UIView {
        let view = PlayerUIView()
        view.playerLayer = context.coordinator.layer
        view.layer.addSublayer(view.playerLayer)
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) { }
}

class PlayerUIView: UIView {
    
    var playerLayer: AVPlayerLayer!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
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
    @State private var isPipActive = false
    @StateObject private var coordinator: PlayerView.Coordinator
    
    init(
        isPipActive: Bool = false,
        coordinator: PlayerView.Coordinator
    ) {
        self.isPipActive = isPipActive
        _coordinator = .init(wrappedValue: coordinator)
    }
    
    var body: some View {
        let _ = Self._printChanges()
        ZStack {
            PlayerView(coordinator: coordinator)
                .edgesIgnoringSafeArea(.all)
            
            HStack(spacing: 30) {
                Spacer()
                Button {
                    coordinator.pause()
                } label: {
                    Image(systemName: "pause.fill").font(.largeTitle)
                }
                
                Button {
                    coordinator.play()
                } label: {
                    Image(systemName: "play.fill").font(.largeTitle)
                }
                Spacer()
            }.foregroundStyle(.white)


            pipButton
        }.onAppear {
            /**
             Sometimes deferring the call to player.play() until
             after the SwiftUI view hierarchy has settled (e.g.,
             using a small DispatchQueue.main.asyncAfter)
             can help confirm if it’s purely a timing issue.
             */
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                coordinator.play()
                debugPrint("called play")
            }
        }
    }
    
    private func togglePiP() {
        guard let pipController = coordinator.pipController else { return }
        if pipController.isPictureInPictureActive {
            pipController.stopPictureInPicture()
            isPipActive = false
        } else {
            pipController.startPictureInPicture()
            isPipActive = true
        }
    }
    
    @ViewBuilder
    private var pipButton: some View {
        if coordinator.pipPossible {
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: togglePiP) {
                        Image(systemName: isPipActive ? "pip.exit" : "pip.enter")
                            .font(.title)
                            .padding()
                            .background(Color.black.opacity(0.5))
                            .foregroundColor(.white)
                            .clipShape(Circle())
                    }
                    .padding()
                }
            }
        }
    }
    
}
