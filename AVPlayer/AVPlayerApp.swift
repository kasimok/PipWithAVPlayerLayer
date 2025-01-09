//
//  AVPlayerApp.swift
//  AVPlayer
//
//  Created by 0x67 on 2025-01-09.
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#else
import AppKit
#endif

@main
struct AVPlayerApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self)
    var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView(coordinator: PlayerView.Coordinator())
        }
    }
}
