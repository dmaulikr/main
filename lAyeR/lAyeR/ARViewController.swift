//
//  ARViewController.swift
//  lAyeR
//
//  Created by luoyuyang on 08/03/17.
//  Copyright © 2017年 nus.cs3217.layer. All rights reserved.
//

import AVFoundation
import CoreMotion
import Foundation
import MapKit
import UIKit

class ARViewController: UIViewController {
    
    // setting constants
    let sampleCardWidth = 108
    let sampleCardHeight = 108
    let sampleCardAlpha: CGFloat = 0.48
    let framePerSecond = 60
    var fov: Double!
    private let nearbyPOIsUpdatedNotificationName = NSNotification.Name(rawValue:
        Setting.nearbyPOIsUpdatedNotificationName)
    
    // for displaying camera view
    var videoDataOutput: AVCaptureVideoDataOutput!
    var videoDataOutputQueue: DispatchQueue!
    var cameraViewLayer: AVCaptureVideoPreviewLayer!
    var captureDevice: AVCaptureDevice!
    let session = AVCaptureSession()
    var currentFrame: CIImage!
    var done = false
    
    var cameraView: UIView!
    var checkpointCardControllers: [CheckpointCardController] = []
    private var currentPoiCardControllers: [PoiCardController] = []
    
    private lazy var displayLink: CADisplayLink = CADisplayLink(target: self, selector: #selector(updateLoop))

    let motionManager = DeviceMotionManager.getInstance()
    let geoManager = GeoManager.getInstance()

    let menuController = MenuViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addCameraView()
        addCheckPointCards()
        setupAVCapture()
        fov = Double(captureDevice.activeFormat.videoFieldOfView) * M_PI / 180
        monitorNearbyPOIsUpdate()
        startObservingDeviceMotion()
        displayLastUpdatedPOIs()
        prepareMenu()
    }
    
    private func addCameraView() {
        cameraView = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height))
        cameraView.contentMode = .scaleAspectFit
        view.insertSubview(cameraView, at: 0)
    }
    
    private func addCheckPointCards() {
        // FOR TESTING PURPOSE

        let sampleCard = CheckpointCard(center: view.center, distance: 0, superView: view)
        sampleCard.setCheckpointName("Prince Geroges' Park Residences")
        sampleCard.setCheckpointDescription("Prince George's Park Residences. One of the most famous residences in NUS, it is usually a place for foreign students to live. Most Chinese studenting are living here. This is the destination.")
        
        // can set blur mode using below code
        sampleCard.setBlurEffect(true)
        
        let sampleCardController = CheckpointCardController(checkpoint: CheckPoint(1.2909, 103.7813, "PGP Residence"),
                                                            card: sampleCard)
        sampleCardController.setSelected(true)
        checkpointCardControllers.append(sampleCardController)
        
    }
    
    private func monitorNearbyPOIsUpdate() {
        NotificationCenter.default.addObserver(forName: nearbyPOIsUpdatedNotificationName, object: nil, queue: nil,
                                               using: { [unowned self] _ in
            self.displayLastUpdatedPOIs()
        })
    }
    
    private func displayLastUpdatedPOIs() {
        let lastUpdatedPOIs = geoManager.getLastUpdatedNearbyPOIs()
        var newPOICardControllers: [PoiCardController] = []

        // keep the previous POI and corresponding card that also appears in the updated POI list
        // discard the obsolete POIs and remove corresponding card that does no appear in the updated list
        for poiCardController in currentPoiCardControllers {
            if lastUpdatedPOIs.contains(where: { $0.name == poiCardController.poiName }) {
                newPOICardControllers.append(poiCardController)
            }
        }
        
        // add the new POI and create corresponding card that appears in the updated list but not the previous list
        for newPoi in lastUpdatedPOIs {
            if !newPOICardControllers.contains(where: { $0.poiName == newPoi.name }) {
                guard let name = newPoi.name else {
                    break
                }
                let poiCard = PoiCard(center: view.center, distance: 0, type: "library", superView: view)
                poiCard.setPoiName(name)
                poiCard.setPoiDescription("To be specified...")
                poiCard.setPoiAddress(newPoi.vicinity!)
                newPOICardControllers.append(PoiCardController(poi: newPoi, card: poiCard))
            }
        }
        
        currentPoiCardControllers = newPOICardControllers
    }
    
    /**
     After this method is called, the system will monitor the device motion,
     and update the view accordingly
     */
    private func startObservingDeviceMotion() {
        displayLink.add(to: .current, forMode: .defaultRunLoopMode)
        displayLink.preferredFramesPerSecond = framePerSecond
    }
    
    @objc private func updateLoop() {
        let userPoint = geoManager.getLastUpdatedUserPoint()

        for checkPointCardController in checkpointCardControllers {
            checkPointCardController.updateCard(userPoint: userPoint, motionManager: motionManager,
                                                superView: view, fov: fov)
        }
        
        for poiCardController in currentPoiCardControllers {
            poiCardController.updateCard(userPoint: userPoint, motionManager: motionManager,
                                         superView: view, fov: fov)
        }
    }  
}














