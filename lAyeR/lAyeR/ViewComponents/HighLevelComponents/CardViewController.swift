//
//  CardViewController.swift
//  lAyeR
//
//  Created by Yang Zhuohan on 24/3/17.
//  Copyright © 2017 nus.cs3217.layer. All rights reserved.
//

import UIKit

class CardViewController: NSObject {

    // The marker of the card
    var markerCard: BasicMarker!
    
    // The popup controller of the card
    var popupController: BasicAlertController!
    
    // The superview in which the marker and the popup will be
    // displayed
    var superView: UIView!
    
    // Specifies the center of the card
    var center: CGPoint!
    
    /// Initialization
    /// - Parameters:
    ///     - center: the center of the popup & marker card
    ///     - distance: distance to that place that the card is representing
    ///     - superView: the super view in which the marker card & popup will
    ///         be displayed
    init(center: CGPoint, distance: Double, superView: UIView) {
        super.init()
        self.center = center
        self.superView = superView
        initMarker(with: CGFloat(distance))
        initAlert()
        prepareDisplay()
    }
    
    /// Initializes the marker with specified frame and distance
    /// - Parameters:
    ///     - frame: the frame of the marker in the card view
    ///     - distance: the distance to that place
    private func initMarker(with distance: CGFloat) {
        let newMarker = BasicMarker(frame: markerFrame)
        newMarker.setDistance(distance)
        self.markerCard = newMarker
        addMarkerGesture()
    }
    
    /// Adds a single tap gesture recognizor to the marker
    private func addMarkerGesture() {
        let markerIsPressed = UITapGestureRecognizer(target: self, action: #selector(openPopup))
        markerCard.addGestureRecognizer(markerIsPressed)
    }
    
    /// Initializes the popup with its name
    /// - Parameters:
    ///     - name: the name of the check point
    private func initAlert() {
        let newAlertController = BasicAlertController(title: defaultTitle, frame: popupFrame)
        let alertWidth = newAlertController.alert.infoPanel.bounds.width
        let alertHeight = newAlertController.alert.infoPanel.bounds.height
        newAlertController.addViewToAlert(InformativeInnerView(width: alertWidth,
                                                               height: alertHeight))
        self.popupController = newAlertController
    }
    
    /// Prepares the card view for display
    private func prepareDisplay() {
        superView.addSubview(markerCard)
    }
    
    /// Calculates the frame of the marker
    /// - Note: the frame is defined by suggested maker height/width, which are
    ///     defined in config
    private var markerFrame: CGRect {
        let originX = center.x - suggestedMarkerWidth / 2
        let originY = center.y - suggestedMarkerHeight / 2
        return CGRect(x: originX, y: originY, width: suggestedMarkerWidth, height: suggestedMarkerHeight)
    }
    
    /// Calculates the frame of the popup
    /// - Note: the frame is defined by suggested popup height/width, which are
    ///     defined in config
    private var popupFrame: CGRect {
        let originX = center.x - suggestedPopupWidth / 2
        let originY = center.y - suggestedPopupHeight / 2
        return CGRect(x: originX, y: originY, width: suggestedPopupWidth, height: suggestedPopupHeight)
    }
    
}

/**
 An extension that is used to define interactions
 */
extension CardViewController {
    
    /// Opens the popup
    func openPopup() {
        popupController.presentAlert(within: superView)
        UIView.animate(withDuration: 0.2, animations: {
            self.markerCard.alpha = 0
        })
    }
    
    /// Closes the popup
    func closePopup() {
        popupController.closeAlert()
        UIView.animate(withDuration: 0.2, animations: {
            self.markerCard.alpha = 1
        })
    }
    
    /// Updates the distance that will be displayed on marker card
    /// - Parameter distance: thte distance that will be displayed
    func update(_ distance: Double) {
        markerCard.setDistance(CGFloat(distance))
    }
    
    /// Sets/unsets the blur effect
    /// - Parameter isBlurMode: corresponding blur mode
    func setBlurEffect(_ isBlurMode: Bool) {
        markerCard.blurMode = isBlurMode
        popupController.setBlurEffect(isBlurMode)
    }
    
}

/**
 An extension that is to specify that this controller conforms `View-
 LayoutAdjustable`
 */
extension CardViewController: ViewLayoutAdjustable {
    
    /// Applies view adjustment to the marker and popup when neccessary.
    /// - Parameter adjustment: the corresponding adjustment
    func applyViewAdjustment(_ adjustment: ARViewLayoutAdjustment) {
        markerCard.applyViewAdjustment(adjustment)
        popupController.alertView.applyViewAdjustment(adjustment)
    }
    
    /// Removes the current checkpoint card from its super view
    func removeFromSuperview() {
        markerCard.removeFromSuperview()
        popupController.closeAlert()
    }
    
}
