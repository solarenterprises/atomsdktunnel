//
/*
 * AtomSDKTunnelDarwinNotificationManager.swift
 * AtomSDKTunnel
 
 * Created by AtomSDK on 02/12/2024.
 * Copyright © 2024 AtomSDK. All rights reserved.
 */

import Foundation
@objc public class AtomSDKTunnelDarwinNotificationManager: NSObject {
    
    @objc static let shared = AtomSDKTunnelDarwinNotificationManager()
    
    private override init() {}
    
    // 1
    private var callbacks: [String: () -> Void] = [:]
    
    // Method to post a Darwin notification
    @objc func postNotification(name: String) {
        let notificationCenter = CFNotificationCenterGetDarwinNotifyCenter()
        CFNotificationCenterPostNotification(notificationCenter, CFNotificationName(name as CFString), nil, nil, true)
    }
    
    // 2
    @objc func startObserving(name: String, callback: @escaping () -> Void) {
        callbacks[name] = callback
        
        let notificationCenter = CFNotificationCenterGetDarwinNotifyCenter()
        
        CFNotificationCenterAddObserver(notificationCenter,
                                        Unmanaged.passUnretained(self).toOpaque(),
                                        AtomSDKTunnelDarwinNotificationManager.notificationCallback,
                                        name as CFString,
                                        nil,
                                        .deliverImmediately)
    }
    
    // 3
    @objc func stopObserving(name: String) {
        let notificationCenter = CFNotificationCenterGetDarwinNotifyCenter()
        CFNotificationCenterRemoveObserver(notificationCenter, Unmanaged.passUnretained(self).toOpaque(), CFNotificationName(name as CFString), nil)
        callbacks.removeValue(forKey: name)
    }
    
    // 4
    private static let notificationCallback: CFNotificationCallback = { center, observer, name, _, _ in
        guard let observer = observer else { return }
        let manager = Unmanaged<AtomSDKTunnelDarwinNotificationManager>.fromOpaque(observer).takeUnretainedValue()
        
        if let name = name?.rawValue as String?, let callback = manager.callbacks[name] {
            callback()
        }
    }
}
