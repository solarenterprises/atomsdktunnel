//
/*
 * NEPacketTunnelProvider+VPNStateManager.swift
 * AtomSDKTunnel
 
 * Created by AtomSDK on 02/12/2024.
 * Copyright © 2024 AtomSDK. All rights reserved.
 */

import Foundation
import NetworkExtension
import os.log
import OSLog
import os

// MARK: - VPNStateManagerDelegate
protocol VPNStateManagerDelegate: AnyObject {
    func didTriggerAutoResume()
}

// MARK: - NEPacketTunnelProvider Extension

private var tunnelNetworkSettingsKey: UInt8 = 0

extension NEPacketTunnelProvider {
    
    // MARK: - VPN State Manager Integration
    class VPNStateManager {
        
        // MARK: - Properties
        private var autoResumeTask: DispatchWorkItem?
        private(set) var isPaused = false
        private let stateQueue = DispatchQueue(label: "com.vpnmanager.stateQueue", attributes: .concurrent)
        weak var delegate: VPNStateManagerDelegate?
        
        // Reference to parent NEPacketTunnelProvider to access setTunnelNetworkSettings
        private weak var tunnelProvider: NEPacketTunnelProvider?
        
        init(tunnelProvider: NEPacketTunnelProvider) {
            self.tunnelProvider = tunnelProvider
        }
        
        var canPause: Bool {
            return stateQueue.sync { !isPaused }
        }
        
        var canResume: Bool {
            return stateQueue.sync { isPaused }
        }
        
        // MARK: - Public Methods
        
        /// Pauses the VPN and starts a timer for auto-resume
        func pauseVPN(interval: TimeInterval, completion: @escaping () -> Void) {
            // Update state to paused
            stateQueue.sync(flags: .barrier) {
                isPaused = true
            }
            
            // Cancel any existing auto-resume task
            autoResumeTask?.cancel()
            autoResumeTask = nil
            
            // Create a new auto-resume task
            let task = DispatchWorkItem { [weak self] in
                self?.autoResume()
            }
            autoResumeTask = task
            
            let settings = NEPacketTunnelNetworkSettings(tunnelRemoteAddress: "0.0.0.0")
            settings.ipv4Settings = nil
            settings.ipv6Settings = nil
            settings.dnsSettings = nil
            
            // Use the tunnelProvider reference to call setTunnelNetworkSettings
            tunnelProvider?.setTunnelNetworkSettings(settings) { error in
                if let error = error {
                    os_log("Failed to pause VPN: %{public}@", type: .error, error.localizedDescription)
                } else {
                    os_log("VPN paused successfully", type: .info)
                }
            }
            
            // Schedule the task
            DispatchQueue.main.asyncAfter(deadline: .now() + interval, execute: task)
            
            // Call completion handler
            completion()
        }
        
        /// Resumes the VPN manually
        func resumeVPN(completion: @escaping () -> Void) {
            // Update state to resumed
            stateQueue.sync(flags: .barrier) {
                isPaused = false
            }
            
            // Cancel any existing auto-resume task
            autoResumeTask?.cancel()
            autoResumeTask = nil
            
            // Retrieve stored settings and resume VPN using tunnelProvider reference
            tunnelProvider?.setTunnelNetworkSettings(tunnelProvider?.getStoredTunnelNetworkSettings()) { error in
                if let error = error {
                    os_log("Failed to resume VPN: %{public}@", type: .error, error.localizedDescription)
                } else {
                    os_log("VPN resumed successfully", type: .info)
                }
            }
            
            // Call completion handler
            completion()
        }
        
        // MARK: - Private Methods
        
        /// Called when the auto-resume timer fires
        private func autoResume() {
            guard isPaused else { return }
            
            // Notify the delegate that auto-resume has been triggered
            delegate?.didTriggerAutoResume()
            
            // Resume the VPN
//            resumeVPN {
//                os_log("Auto-resume completed", type: .info)
//            }
        }
    }
    
    // MARK: - Swizzling Method for Tunnel Settings
    
    static func swizzleSetTunnelNetworkSettings() {
        let originalSelector = #selector(NEPacketTunnelProvider.setTunnelNetworkSettings(_:completionHandler:))
        let swizzledSelector = #selector(swizzled_setTunnelNetworkSettings(_:completionHandler:))
        
        guard let originalMethod = class_getInstanceMethod(self, originalSelector),
              let swizzledMethod = class_getInstanceMethod(self, swizzledSelector) else {
            return
        }
        
        method_exchangeImplementations(originalMethod, swizzledMethod)
    }
    
    @objc private func swizzled_setTunnelNetworkSettings(
        _ tunnelNetworkSettings: NEPacketTunnelNetworkSettings?,
        completionHandler: @escaping (Error?) -> Void
    ) {
        // Store the tunnelNetworkSettings using associated objects
        if let settings = tunnelNetworkSettings, settings.dnsSettings != nil {
            objc_setAssociatedObject(self, &tunnelNetworkSettingsKey, settings, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        
        // Continue with the original method
        swizzled_setTunnelNetworkSettings(tunnelNetworkSettings, completionHandler: completionHandler)
    }
    
    func getStoredTunnelNetworkSettings() -> NEPacketTunnelNetworkSettings? {
        return objc_getAssociatedObject(self, &tunnelNetworkSettingsKey) as? NEPacketTunnelNetworkSettings
    }
}

