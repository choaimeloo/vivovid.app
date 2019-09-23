//
//  MainViewController.swift
//  vivovid
//
//  Created by Jan Cho on 9/23/19.
//  Copyright © 2019 Jan Cho. All rights reserved.
//

import UIKit
import SceneKit
import SpriteKit
import ARKit
import AVKit
import MessageUI

extension CMTime {
    var asDouble: Double {
        get {
            return Double(self.value) / Double(self.timescale)
        }
    }
    var asFloat: Float {
        get {
            return Float(self.value) / Float(self.timescale)
        }
    }
}

extension CMTime: CustomStringConvertible {
    public var description: String {
        get {
            let seconds = Int(round(self.asDouble))
            return String(format: "%02d:%02d", seconds / 60, seconds % 60)
        }
    }
}


class MainViewController: UIViewController, ARSCNViewDelegate, MFMailComposeViewControllerDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    @IBOutlet weak var playerSlider: UISlider!
    
    @IBOutlet weak var playerTimeLabel: UILabel!
    
    let videoScene = SKScene(size: CGSize(width: 480, height: 360))
    var configuration = ARImageTrackingConfiguration()
    let node = SCNNode()
    var videoURL: URL!
    var player: AVQueuePlayer!
    var playerItem: AVPlayerItem!
    var isPlaying: Bool = true
    var videoStarted: Bool = false
    var duration: CMTime = CMTime(seconds: 0, preferredTimescale: 100)
    var periodicTimeObserver: Any?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        videoURL = Bundle.main.url(forResource: "HubSpot-AboutUs.mp4", withExtension: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        configuration = ARImageTrackingConfiguration()
        
        // Find images to track
        if let trackedImages = ARReferenceImage.referenceImages(inGroupNamed: "Cards", bundle: Bundle.main)
            {
            // Set configuration and tell it that the image(s) it should be tracking is the one specified above
                configuration.trackingImages = trackedImages
                
            // Current configuration tracks only one image
                configuration.maximumNumberOfTrackedImages = 1
            }

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    
    private func seekToTime(_ seekTime: CMTime) {
        self.player?.seek(to: seekTime)
    }
    
    private func setTextLabel(cmtime: CMTime) -> UILabel {
        let label = UILabel()
        label.text = cmtime.description
        return label
    }
    
    
    @IBAction func sliderValueChanged(_ sender: Any) {
        
        let seekTime = CMTime(seconds: Double(playerSlider.value) * self.duration.asDouble, preferredTimescale: 100)
        self.seekToTime(seekTime)
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
        player?.pause()
    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        // imageAnchor is the business card or other collateral
        if let imageAnchor = anchor as? ARImageAnchor {
            let asset = AVAsset(url: videoURL)
            
            playerItem = AVPlayerItem(asset: asset)
            
            player = AVQueuePlayer(playerItem: playerItem)
            
            let videoNode = SKVideoNode(avPlayer: player)
            
            duration = self.player?.currentItem?.asset.duration ?? CMTime(value: 0, timescale: 100)
            print("DURATION: \(duration)")
            
            // Register time observer
            periodicTimeObserver = player!.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 100), queue: DispatchQueue?.none, using: { (cmtime) in
                self.playerSlider.value = Float(CMTimeGetSeconds(cmtime)) / Float(CMTimeGetSeconds(self.duration))
                print(self.playerSlider.value)
                
                self.playerTimeLabel.text = "\(cmtime.description) / \(self.duration)"
            })
            
            player.play()
            isPlaying = true
            
            // the videoNode is a SpriteKit video node and we need to add that to a SceneKit element (SCNPlane below) so we can place the SceneKit element into our Scene View session. To do that, we need to create a new scene:
            // the CGSize is an estimation (480p x 360p in resolution)
            
            // Change videoNode's position relative to its parent. Set parameters to display dead center.
            
            videoNode.position = CGPoint(x: videoScene.size.width / 2, y: videoScene.size.height / 2)
            
            videoScene.scaleMode = .aspectFit
            
            // Flip video on the y axis so that it displays right side up
            videoNode.yScale = -1.0
            
            videoScene.addChild(videoNode)
            
            // Create plane on which to display the video, of same dimensions as reference image
            let plane = SCNPlane(width: imageAnchor.referenceImage.physicalSize.width, height: imageAnchor.referenceImage.physicalSize.height)
            
            plane.firstMaterial?.diffuse.contents = videoScene
            
            // Let this plane node have the geometry of the plane created above
            let planeNode = SCNNode(geometry: plane)
            
            // Plane always gets rendered at 90 degrees to the image recognized so we need to rotate it
            // Rotate it on its x dimension, counterclockwise by half pi (which is 90 degrees) so that it's flat and flush with the image recognized
            planeNode.eulerAngles.x = -.pi / 2
            
            node.addChildNode(planeNode)
            
            NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: self.playerItem, queue: nil) { [weak self] _ in
                self?.playerItem?.seek(to: CMTime.zero, completionHandler: nil)
                videoNode.removeFromParent()
                planeNode.removeFromParentNode()
                self?.sceneView.session.run((self?.configuration ?? nil)!, options: [.resetTracking, .removeExistingAnchors])
                
            }
            
        }
        
        return node
    }
    
    // Hold pause state even if anchorImage is removed from and then returned to SCNView
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        if !isPlaying {
            player?.pause()
        }
    }
    
    
    @IBAction func playPauseTapped(_ sender: UIBarButtonItem) {
        if isPlaying && videoStarted == false {
               let alertController = UIAlertController(title: "No Card in View", message: "Find a Card to Start Watching", preferredStyle: .alert)
               let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
               alertController.addAction(defaultAction)
               self.present(alertController, animated: true, completion: nil)
               
           } else if isPlaying && videoStarted == true {
               player.pause()
               //            sender.setBackgroundImage(UIImage(named: "play-pause-circle")!, for: UIControl.State.normal, barMetrics: .default)
               isPlaying = false
               
           } else {
               player?.play()
               isPlaying = true
           }
    }
    
    
    @IBAction func moreInfoTapped(_ sender: UIButton) {
        if let url = NSURL(string: "http://www.hubspot.com") {
            UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
        }
    }
    
    
    @IBAction func shareButtonTapped(_ sender: UIBarButtonItem) {
        let items: [Any] = ["You should watch this video:", URL(string: "https://hubspot.hubs.vidyard.com/watch/Jgw4cuRZkXyuxZ3hQnoMAv?")!]
            
        let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
        
        present(activityVC, animated: true)
        
        activityVC.completionWithItemsHandler = { (activityType: UIActivity.ActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in
            
            // Note: behavior of native Messages & Mail apps is different from the other share options. Those two apps do not deallocate (is that the right term?) the current AVPlayer instance and instead create another one "on top" so you have multiple audio streams playing at the same time.
            if activityType == .message || activityType == .mail {
                self.player?.removeAllItems()
            } else {
                self.player?.pause()
            }

        }
        
    }
    
    
    @IBAction func contactButtonTapped(_ sender: UIBarButtonItem) {
        
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["newdeveloper1@maildrop.cc"])
            mail.setSubject("Would love to learn more")
            mail.setMessageBody("<p>You're so awesome! Let's set up a meeting.</p>", isHTML: true)
            
            present(mail, animated: true)
            
        } else {
            print("couldn't send email")
            
            // show failure alert
            let alert = UIAlertController(title: "email error alert", message: "Email was not sent. Please try again.", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "default action"), style:. default, handler: { _ in NSLog("The \"OK\" alert occurred.") }))
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        player?.pause()
        player?.removeAllItems()
        
        controller.dismiss(animated: true, completion: nil)
        
    }
    
    
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
