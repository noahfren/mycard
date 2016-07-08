//
//  MPCManager.swift
//  mycard
//
//  Created by Noah Frenkel on 7/6/16.
//  Copyright © 2016 Noah Frenkel. All rights reserved.
//

//import Cocoa
import Foundation
import MultipeerConnectivity

let SERVICE = "bb-nf-app"

protocol MPCManagerDelegate {
    
    func foundPeer()
    
    func lostPeer()
    
    func invitationWasReceived(fromPeer: String)
    
    func connectedWithPeer(peerID: MCPeerID)
}

class MPCManager: NSObject, MCSessionDelegate, MCNearbyServiceBrowserDelegate, MCNearbyServiceAdvertiserDelegate {
    
    var delegate: MPCManagerDelegate?
    
    var session: MCSession!
    var peer: MCPeerID!
    var browser: MCNearbyServiceBrowser!
    var advertiser: MCNearbyServiceAdvertiser!
    
    var foundPeers = [MCPeerID]()
    
    // This function alias will act based on whether the user accepts their invite (bool == true)
    // or declines the invite (bool == false)
    var invitationHandler: ((Bool, MCSession) -> Void)!
    
    override init() {
        super.init()
        
        // Initializing the peer with the name set as the current device's name
        // This peer's name will be what displays in the table cells as possible connections
        peer = MCPeerID(displayName: UIDevice.currentDevice().name)
        
        // Initializing the session with the users own peer object (aka the current device)
        // We will set MPCManager as the delegate for the session object because ???
        session = MCSession(peer: peer)
        session.delegate = self
        
        // Initializing the browser with the session we just created and a unique id for our apps service
        // We will set MPCManager as the delegate for this browser object because ???
        browser = MCNearbyServiceBrowser(peer: peer, serviceType: SERVICE)
        browser.delegate = self
        
        // Initializing the advertiser with our peer, the apps service id and discovery info
        // Discovery info will eventually be a dictionary containing the nearby contact name and preview pic
        advertiser = MCNearbyServiceAdvertiser(peer: peer, discoveryInfo: nil, serviceType: SERVICE)
        advertiser.delegate = self
        
    }
    
    // This function is called by the MPC when a nearby device is discovered
    func browser(browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        
        foundPeers.append(peerID)
        
        delegate?.foundPeer()
    }
    
    // This function is called by the MPC when a nearby device is no longer available
    // First we loop through the array of peers and find the lost peer then delete it
    func browser(browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        for (index, aPeer) in foundPeers.enumerate() {
            if aPeer == peerID {
                foundPeers.removeAtIndex(index)
                break
            }
        }
        
        delegate?.foundPeer()
    }
    
    // This function will display an error if the browsing can not finish
    func browser(browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: NSError) {
        print(error.localizedDescription)
    }
    
    // This function runs when an invitation is recieved, it sets the manager's invitation handler to
    // to the one passed as an argument
    func advertiser(advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: NSData?, invitationHandler: ((Bool, MCSession) -> Void)) {
        
        self.invitationHandler = invitationHandler
        
        delegate?.invitationWasReceived(peerID.displayName)
    }
    
    // This function runs when the advertiser could not start, it displays an error message to the user
    func advertiser(advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: NSError) {
        print(error.localizedDescription)
    }
    
    func session(session: MCSession, peer peerID: MCPeerID, didChangeState state: MCSessionState) {
        switch state {
            case MCSessionState.Connected:
                print("Connected to session: \(session)")
                delegate?.connectedWithPeer(peerID)
                
            case MCSessionState.Connecting:
                print("Connecting to session: \(session)")
                
            default:
                print("Did not connect to session: \(session)")
        }
    }
    
    // This function sends our data, bro
    func sendData(dataToSend data: NSData, toPeer targetPeer: MCPeerID) -> Bool {
        
        let peersArray = [targetPeer]
        
        do {
            try session.sendData(data, toPeers: peersArray, withMode: MCSessionSendDataMode.Reliable)
            return true
        } catch {
            
            return false
        }
    }
    
    // This function runs when the user has recieved data, for now it will simply display an alert with the info it recieved
    // MARK: TODO: Implement address book integration here
    func session(session: MCSession, didReceiveData data: NSData, fromPeer peerID: MCPeerID) {
        // Add alert view controller here
        print("Data was recieved")
        return
    }
    
    
    //  ------ Other required functions for MCSessionDelegate that we don't need functionality for ----------
    // ------------------------------------------------------------------------------------------------------
    func session(session: MCSession, didReceiveStream stream: NSInputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        return
    }
    
    func session(session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, atURL localURL: NSURL, withError error: NSError?) {
        return
    }
    
    func session(session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, withProgress progress: NSProgress) {
        return
    }
    
}
