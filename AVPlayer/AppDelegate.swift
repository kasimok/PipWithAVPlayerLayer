//
//  AppDelegate.swift
//  AVPlayer
//
//  Created by 0x67 on 2025-01-09.
//
#if canImport(UIKit)
import UIKit
#else
import AppKit
#endif
import AVKit

class AppDelegate: NSObject, UIApplicationDelegate {
    
    var window: UIWindow?
    
#if canImport(UIKit)
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Setting category to AVAudioSessionCategoryPlayback failed.")
        }
        return true
    }
#endif
    
}
