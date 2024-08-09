//
//  AtomPacketTunnelProvider.swift
//  AtomPacketTunnelProvider
//
//  Created by Atom on 27/05/2017.
//
//

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
    //  var wormhole: MMWormhole?
    override init() {
    }
    private func initializeDependencies(appGroup : String){
//        for (key, value) in self.defaultshared.dictionaryRepresentation() {
//            
//        }
        
    }
    open override func startTunnel(options: [String : NSObject]? = nil, completionHandler: @escaping (Error?) -> Void) {
        // There are many ways to provide OpenVPN settings to the tunnel provider. For instance,
        // you can use `options` argument of `startTunnel(options:completionHandler:)` method or get
        // settings from `protocolConfiguration.providerConfiguration` property of `NEPacketTunnelProvider`
        // class. Also you may provide just content of a ovpn file or use key:value pairs
        // that may be provided exclusively or in addition to file content.
        // In our case we need providerConfiguration dictionary to retrieve content
        // of the OpenVPN configuration file. Other options related to the tunnel
        // provider also can be stored there.
        guard
            let protocolConfiguration = protocolConfiguration as? NETunnelProviderProtocol,
            let providerConfiguration = protocolConfiguration.providerConfiguration
        else {
            fatalError()
        }
        guard let ovpnFileContent: Data = providerConfiguration["ovpn"] as? Data else {
            fatalError()
        }
        guard let appGroup: String = providerConfiguration["AppGroup"] as? String else {
            fatalError()
        }
        guard let credentialsData = (providerConfiguration["credentials"] as? Data) else {
            fatalError()
        }
        guard let credentials = NSKeyedUnarchiver.unarchiveObject(with: credentialsData) as? [String : Any] else {
            fatalError()
        }
        guard let username = (credentials["username"]) as? String else {
            fatalError()
        }
        guard let password = (credentials["password"]) as? String else {
            fatalError()
        }
        
        uniqueID = UUID().uuidString
        initializeDependencies(appGroup: appGroup)
        let configuration = OpenVPNConfiguration()
        configuration.fileContent = ovpnFileContent
        configuration.clockTick = 1000
       
        
        if let timeout = providerConfiguration["openvpnTimeout"] as? Double {
            configuration.connectionTimeout = Int(timeout)
        }
        
        configuration.settings = ["verb": "5"]
        configuration.disableClientCert = false
        configuration.forceCiphersuitesAESCBC = true
        // Uncomment this line if you want to keep TUN interface active during pauses or reconnections
        // configuration.tunPersist = true
        // Apply OpenVPN configuration
        let properties: OpenVPNConfigurationEvaluation
        do {
            properties = try vpnAdapter.apply(configuration: configuration)
        } catch {
            completionHandler(error)
            return
        }
        if !properties.autologin {
            // Provide credentials if needed
            // If your VPN configuration requires user credentials you can provide them by
            // `protocolConfiguration.username` and `protocolConfiguration.passwordReference`
            // properties. It is recommended to use persistent keychain reference to a keychain
            // item containing the password.
            let credentials = OpenVPNCredentials()
            credentials.username = username
            credentials.password = password
            do {
                try vpnAdapter.provide(credentials: credentials)
            } catch {
                completionHandler(error)
                return
            }
        }
        // Checking reachability. In some cases after switching from cellular to
        // WiFi the adapter still uses cellular data. Changing reachability forces
        // reconnection so the adapter will use actual connection.
        vpnReachability.startTracking { [weak self] status in
            guard status == .reachableViaWiFi else { return }
            self?.vpnAdapter.reconnect(afterTimeInterval: 5)
        }
        startHandler = completionHandler
        vpnAdapter.connect(using: packetFlow)
//        if let uniqueid = uniqueID {
//        }
    }
    open override func stopTunnel(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        stopHandler = completionHandler
        if vpnReachability.isTracking {
            vpnReachability.stopTracking()
        }
        vpnAdapter.disconnect()
//        if let uniqueid = uniqueID {
//
//        }
#if os(macOS)
        exit(0)
#endif
    }
    open override func handleAppMessage(_ messageData: Data, completionHandler: ((Data?) -> Void)?) {
        if let handler = completionHandler {
            handler(messageData)
        }
    }
    open override func sleep(completionHandler: @escaping () -> Void) {
        completionHandler()
    }
    open override func wake() {
    }
}
@available(macOS 10.12, *)
extension AtomPacketTunnelProvider : OpenVPNAdapterDelegate {
    public func openVPNAdapter(_ openVPNAdapter: OpenVPNAdapter, configureTunnelWithNetworkSettings networkSettings: NEPacketTunnelNetworkSettings?, completionHandler: @escaping (Error?) -> Void) {
        // In order to direct all DNS queries first to the VPN DNS servers before the primary DNS servers
        // send empty string to NEDNSSettings.matchDomains
        networkSettings?.dnsSettings?.matchDomains = [""]
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
        case .connected:
            if reasserting {
                reasserting = false
            }
            guard let startHandler = startHandler else { return }
            startHandler(nil)
            self.startHandler = nil
        case .disconnected:
            guard let stopHandler = stopHandler else { return }
            if vpnReachability.isTracking {
                vpnReachability.stopTracking()
            }
            stopHandler()
            self.stopHandler = nil
        case .reconnecting:
            reasserting = true
        case .info:
            break
        default:
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

