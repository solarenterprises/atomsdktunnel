//
/*
 * AtomPacketTunnelProvider.swift
 * AtomSDKTunnel
 
 * Created by AtomSDK on 02/12/2024.
 * Copyright © 2024 AtomSDK. All rights reserved.
 */

import Foundation
import AtomOVPNTunnel
import NetworkExtension
import OSLog
import os

extension NEPacketTunnelFlow: OpenVPNAdapterPacketFlow {}
@available(macOS 10.12, *)
open class AtomPacketTunnelProvider : NEPacketTunnelProvider {
    
    private lazy var defaultshared: UserDefaults = {
            guard let appGroup = appGroup else { return .standard }
            
            let sharedUserDefaults = UserDefaults(suiteName: appGroup)!
            return sharedUserDefaults
        }()
    
    
    private var appGroup: String!
    private var vpnStateManager: VPNStateManager!

    let log = OSLog.init(subsystem: "com.atomsdktunnel", category: "Logging")
    
    lazy var vpnAdapter: OpenVPNAdapter = {
        let adapter = OpenVPNAdapter()
        adapter.delegate = self
        return adapter
    }()
    let vpnReachability = OpenVPNReachability()
    var startHandler: ((Error?) -> Void)?
    var stopHandler: (() -> Void)?
    var uniqueID: String?
    var vpnStatusString = ""
    
    //  var wormhole: MMWormhole?
    override init() {
        super.init()
        
        // Now you can safely use self because the class is fully initialized
        vpnStateManager = VPNStateManager(tunnelProvider: self)
    }
    
    // MARK: - NEPacketTunnelProvider Overrides
    
    open override func startTunnel(options: [String: NSObject]? = nil, completionHandler: @escaping (Error?) -> Void) {
        

        
        guard let protocolConfiguration = protocolConfiguration as? NETunnelProviderProtocol,
              let providerConfiguration = protocolConfiguration.providerConfiguration,
              let ovpnFileContent = providerConfiguration["ovpn"] as? Data,
              let appGroup = providerConfiguration["AppGroup"] as? String,
              let credentialsData = providerConfiguration["credentials"] as? Data,
              let credentials = NSKeyedUnarchiver.unarchiveObject(with: credentialsData) as? [String: Any],
              let username = credentials["username"] as? String,
              let password = credentials["password"] as? String
        else {
            completionHandler(OpenVPNAdapterError.configurationFailure as? Error)
            return
        }
        
        NEPacketTunnelProvider.swizzleSetTunnelNetworkSettings()
        
        vpnStateManager.delegate = self
        
        let configuration = OpenVPNConfiguration()
        configuration.fileContent = ovpnFileContent
        configuration.clockTick = 1000
        configuration.connectionTimeout = providerConfiguration["openvpnTimeout"] as? Int ?? 30
        configuration.settings = ["verb": "5"]
        configuration.forceCiphersuitesAESCBC = true
        
        do {
            try vpnAdapter.apply(configuration: configuration)
        } catch {
            completionHandler(error)
            return
        }
        
        let openvpnCredentials = OpenVPNCredentials()
        openvpnCredentials.username = username
        openvpnCredentials.password = password
        
        do {
            try vpnAdapter.provide(credentials: openvpnCredentials)
        } catch {
            completionHandler(error)
            return
        }
        
        // Checking reachability. In some cases after switching from cellular to
        // WiFi the adapter still uses cellular data. Changing reachability forces
        // reconnection so the adapter will use actual connection.
        /*vpnReachability.startTracking { [weak self] status in
            if status == .reachableViaWiFi {
                self?.vpnAdapter.reconnect(afterTimeInterval: 5)
            }
        }*/
        
        startHandler = completionHandler
        vpnAdapter.connect(using: packetFlow)
    }
    open override func stopTunnel(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        stopHandler = completionHandler
        if vpnReachability.isTracking {
            vpnReachability.stopTracking()
        }
        vpnAdapter.disconnect()
        
#if os(macOS)
        exit(0)
#endif
    }
    open override func handleAppMessage(_ messageData: Data, completionHandler: ((Data?) -> Void)?) {
        do {
            if let json = try JSONSerialization.jsonObject(with: messageData, options: []) as? [String : Any] {
                let key1 = json["action"]
                let key2 = json["time"]
                
                guard let action = key1 as? String else {
                    completionHandler?("error".data(using: String.Encoding.utf8))
                    return
                }
                
                if action.elementsEqual("PAUSE") {
                    if let time = key2 as? Double, time != 0.0 {
                        pauseVPN(for: time)
                    } else {
                        // Don't auto resume.
                        pauseVPN(for: nil)
                    }
                    completionHandler?("PAUSED".data(using: String.Encoding.utf8))
                } else if action.elementsEqual("RESUME") {
                    resumeVPN()
                    completionHandler?("RESUMED".data(using: String.Encoding.utf8))
                } else if action.elementsEqual("VPNSTATUS") {
                    completionHandler?("\(vpnStatusString)".data(using: String.Encoding.utf8))
                } else {
                    completionHandler?("INVALID ACTION".data(using: String.Encoding.utf8))
                }
            } else {
                completionHandler?("INVALID JSON FORMAT".data(using: String.Encoding.utf8))
            }
        } catch {
            completionHandler?("CATCH JSON ERROR: \(error.localizedDescription)".data(using: String.Encoding.utf8))
        }
    }
    open override func sleep(completionHandler: @escaping () -> Void) {
        completionHandler()
    }
    open override func wake() {
    }
    
    // MARK: - VPN Management
    
    private func pauseVPN(for interval: TimeInterval?) {
        guard vpnStateManager.canPause else {
            os_log("VPN is already paused", log: log, type: .info)
            return
        }
        
        os_log("Pausing VPN for %{public}.2f seconds", log: log, type: .info, interval ?? 0.0)
        
        vpnStateManager.pauseVPN(interval: interval ?? 0) { [weak self] in
            guard let self = self else { return }
            os_log("Paused", log: self.log, type: .info)
            
        }
    }
    
    private func resumeVPN() {
        guard vpnStateManager.canResume else {
            os_log("VPN is not paused; cannot resume", log: log, type: .info)
            return
        }
        
        os_log("Resuming VPN", log: log, type: .info)
        
        vpnStateManager.resumeVPN { [weak self] in
            guard let self = self else { return }
            
            os_log("Resumed", log: self.log, type: .info)
            AtomSDKTunnelDarwinNotificationManager.shared.postNotification(name: "RESUMED")
            
            guard let startHandler = startHandler else {
                os_log("I AM Resumed but in else", log: self.log, type: .info)
                return
            }
            startHandler(nil)
            //self.startHandler = nil
        }
    }
    
}
@available(macOS 10.12, *)
extension AtomPacketTunnelProvider : OpenVPNAdapterDelegate {
    public func openVPNAdapter(_ openVPNAdapter: OpenVPNAdapter, configureTunnelWithNetworkSettings networkSettings: NEPacketTunnelNetworkSettings?, completionHandler: @escaping (Error?) -> Void) {
        // In order to direct all DNS queries first to the VPN DNS servers before the primary DNS servers
        // send empty string to NEDNSSettings.matchDomains
        
        // Set the network settings for the current tunneling session.
        setTunnelNetworkSettings(networkSettings, completionHandler: completionHandler)
    }
    public func openVPNAdapter(_ openVPNAdapter: OpenVPNAdapter, configureTunnelWithNetworkSettings networkSettings: NEPacketTunnelNetworkSettings, completionHandler: @escaping (OpenVPNAdapterPacketFlow?) -> Void) {
        setTunnelNetworkSettings(networkSettings) { (error) in
            completionHandler(error == nil ? self.packetFlow : nil)
        }
    }
    public func openVPNAdapter(_ openVPNAdapter: OpenVPNAdapter, handleError error: Error) {
        // Handle only fatal errors
        guard let fatal = (error as NSError).userInfo[OpenVPNAdapterErrorFatalKey] as? Bool, fatal == true else {
            return
        }
        if vpnReachability.isTracking {
            vpnReachability.stopTracking()
        }
        if let startHandler = startHandler {
            startHandler(error)
            self.startHandler = nil
        } else {
            cancelTunnelWithError(error)
        }
    }
    public func openVPNAdapter(_ openVPNAdapter: OpenVPNAdapter, handleEvent event: OpenVPNAdapterEvent, message: String?) {
        switch event {
        case .connecting:
            vpnStatusString = "CONNECTING"
            break
        case .connected:
            if reasserting {
                reasserting = false
            }
            guard let startHandler = startHandler else { return }
            startHandler(nil)
            self.startHandler = nil
            vpnStatusString = "CONNECTED"
            break
        case .disconnected:
            guard let stopHandler = stopHandler else { return }
            if vpnReachability.isTracking {
                vpnReachability.stopTracking()
            }
            stopHandler()
            self.stopHandler = nil
            vpnStatusString = "DISCONNECTED"
            break
        case .reconnecting:
            reasserting = true
            vpnStatusString = "RECONNECTING"
            break
        case .info:
            vpnStatusString = "INFO"
            break
        case .pause:
            vpnStatusString = "PAUSE"
            break
        case .resume:
            vpnStatusString = "RESUME"
            break
        case .resolve:
            vpnStatusString = "RESOLVE"
            break
        case .wait:
            vpnStatusString = "WAIT"
            break
        case .getConfig:
            vpnStatusString = "GETCONFIG"
            break
        case .assignIP:
            vpnStatusString = "ASSIGNIP"
            break
        default:
            vpnStatusString = "DEFAULT"
            break
        }
    }
    public func openVPNAdapterDidReceiveClockTick(_ openVPNAdapter: OpenVPNAdapter) {
        var toSave = ""
        let formatter = ByteCountFormatter();
        formatter.countStyle = ByteCountFormatter.CountStyle.binary
        toSave+="_"
        toSave += formatter.string(for: openVPNAdapter.transportStatistics.bytesIn)!
        toSave+="_"
        toSave += formatter.string(for: openVPNAdapter.transportStatistics.bytesOut)!
    }
    public func openVPNAdapter(_ openVPNAdapter: OpenVPNAdapter, handleLogMessage logMessage: String) {
        NSLog("OpenVPN \(logMessage)")
    }
}

extension AtomPacketTunnelProvider : VPNStateManagerDelegate {
    func didTriggerAutoResume() {
        self.resumeVPN()
    }
}
