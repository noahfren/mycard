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

let SERVICE = "my-card-app"


// MARK: - Peer Struct
struct PeerStruct {
    var id: MCPeerID
    var userInfo: Dictionary<String, String>
}

// MARK: - Recieved Card Notifaction Struct
class RecievedCardNotification {
    var sentFrom: String
    var cardId: String
    
    required init (sentFrom: String, cardId: String) {
        
        self.sentFrom = sentFrom
        self.cardId = cardId
    }
    
    func toDictionary() -> Dictionary<String, String> {
        return Dictionary<String, String>(dictionaryLiteral: ("type", "Card Recieved"), ("sentFrom", sentFrom), ("cardId", cardId))
    }
}

// MARK: - Find Devices Delegate Protocol
protocol MPCManagerFindDevicesDelegate {
    
    func foundPeer()
    
    func lostPeer()
    
    func invitationWasReceived(peerInfo: PeerStruct)
    
    func connectedWithPeer(peerInfo: PeerStruct)
    
    func didNotConnectWithPeer(peerInfo: PeerStruct)
}

// MARK: - Share Data Delegate Protocol
protocol MPCManagerShareDataDelegate {
    
    func recievedData(data: NSData)
    
    func disconnectedFromSession()
}

// MARK: - MPC Manager
class MPCManager: NSObject, MCSessionDelegate, MCNearbyServiceBrowserDelegate, MCNearbyServiceAdvertiserDelegate {
    
    // MARK: - Properties
    var findDevicesDelegate: MPCManagerFindDevicesDelegate?
    var shareDataDelegate: MPCManagerShareDataDelegate?
    
    var session: MCSession!
    var peer: MCPeerID!
    var browser: MCNearbyServiceBrowser!
    var advertiser: MCNearbyServiceAdvertiser!
    
    var foundPeers = [PeerStruct]()
    var connectedPeer: MCPeerID?
    
    // This function alias will act based on whether the user accepts their invite (bool == true)
    // or declines the invite (bool == false)
    var invitationHandler: ((Bool, MCSession) -> Void)!
    
    // - Methods
    init(currentUserCard: Card, currentUserID: String) {
        super.init()
        
        let discoveryInfo: Dictionary<String, String> = [
            "firstName": currentUserCard.firstName!,
            "lastName": currentUserCard.lastName!,
            "cardId": currentUserCard.objectId!
        ]
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
        advertiser = MCNearbyServiceAdvertiser(peer: peer, discoveryInfo: discoveryInfo, serviceType: SERVICE)
        advertiser.delegate = self
        
    }
    
    // This function is called by the MPC when a nearby device is discovered
    func browser(browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        
        var addPeer = true
        for peer in foundPeers {
            if peer.id == peerID.displayName {
                addPeer = false
            }
        }
        if addPeer {
            foundPeers.append(PeerStruct(id: peerID, userInfo: info!))
        }
        
        findDevicesDelegate?.foundPeer()
    }
    
    // This function is called by the MPC when a nearby device is no longer available
    // First we loop through the array of peers and find the lost peer then delete it
    func browser(browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        for (index, aPeer) in foundPeers.enumerate() {
            if aPeer.id == peerID {
                foundPeers.removeAtIndex(index)
                break
            }
        }
        
        findDevicesDelegate?.lostPeer()
    }
    
    // This function will display an error if the browsing can not finish
    func browser(browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: NSError) {
        print(error.localizedDescription)
    }
    
    // This function runs when an invitation is recieved, it sets the manager's invitation handler to
    // to the one passed as an argument
    func advertiser(advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: NSData?, invitationHandler: ((Bool, MCSession) -> Void)) {
        
        self.invitationHandler = invitationHandler
        
        for peer in foundPeers {
            if peer.id == peerID {
                findDevicesDelegate?.invitationWasReceived(peer)
            }
        }
        
    }
    
    // This function runs when the advertiser could not start, it displays an error message to the user
    func advertiser(advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: NSError) {
        print(error.localizedDescription)
    }
    
    func session(session: MCSession, peer peerID: MCPeerID, didChangeState state: MCSessionState) {
        
        for peer in foundPeers {
            if peer.id == peerID {
                switch state {
                case MCSessionState.Connected:
                    findDevicesDelegate?.connectedWithPeer(peer)
                    connectedPeer = peerID
                    foundPeers = []
                    print("Connected to session: \(session.connectedPeers)")
                    
                case MCSessionState.Connecting:
                    print("Connecting to session: \(session.connectedPeers)")
                    
                default:
                    if (connectedPeer != nil) {
                        shareDataDelegate?.disconnectedFromSession()
                        connectedPeer = nil
                        print("Did not connect to session: \(session.connectedPeers)")
                    }
                    else {
                        findDevicesDelegate?.didNotConnectWithPeer(peer)
                        print("Ended session: \(session.connectedPeers)")
                        
                    }
                }
            }
        }
    }
    
    func session(session: MCSession, didReceiveData data: NSData, fromPeer peerID: MCPeerID) {
        
        let dict = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! Dictionary<String, String>
        let type = dict["type"]!
        
        if (type == "Card Recieved") {
            shareDataDelegate?.recievedData(data)
        }
        else {
            session.disconnect()
        }
    }
    
    func sendNotification(notification: RecievedCardNotification, connectedPeer: MCPeerID) {
        
        let data = NSKeyedArchiver.archivedDataWithRootObject(notification.toDictionary())
        do {
            try session.sendData(data, toPeers: [connectedPeer], withMode: .Reliable)
        } catch {
            print("could not notification data over session")
        }
    }
    
    func disconnectFromSession() {
        
        let dictionary = Dictionary(dictionaryLiteral: ("type:", "Disconnect"))
        let data = NSKeyedArchiver.archivedDataWithRootObject(dictionary)
        if let connectedPeer = connectedPeer {
            do {
                try session.sendData(data, toPeers: [connectedPeer], withMode: .Reliable)
            } catch {
                print("could not notification data over session")
            }
            self.connectedPeer = nil
        }
        session.disconnect()
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
