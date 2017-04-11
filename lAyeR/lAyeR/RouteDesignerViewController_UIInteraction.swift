//
//  RouteDesignerViewController_UIInteraction.swift
//  lAyeR
//
//  Created by BillStark on 4/11/17.
//  Copyright © 2017 nus.cs3217.layer. All rights reserved.
//

import UIKit

/**
 this is an extension of the vieww controller that defines UI interactions
 */
extension RouteDesignerViewController {

    /// Defines the action when save button is pressed.
    @IBAction func saveButtonPressed(_ sender: Any) {
        let alertFrame = CGRect(x: 0, y: 0, width: suggestedPopupWidth, height: suggestedPopupHeight)
        storeRoutePopupController = BasicAlertController(title: "Store Your Route", frame: alertFrame)
        storeRoutePopupController.alertView.center = view.center
        addInnerView()
        storeRoutePopupController.addButtonToAlert(createCloseButton())
        storeRoutePopupController.presentAlert(within: view)
    }
    
    /// Adds inner view to the popup
    private func addInnerView() {
        let innerView = InformativeInnerView(width: infoPanelBounds.width,
                                             height: infoPanelBounds.height,
                                             hasSubTitle: false)
        storeRoutePopupController.addViewToAlert(innerView)
        innerView.insertSubInfo(createSaveButton())
        innerView.insertSubInfo(createExportButton())
    }
    
    /// Creates a close button
    /// - Returns: a close button which will close the popup if it is clicked
    private func createCloseButton() -> UIButton {
        let newButton = UIButton()
        newButton.setTitle("Cancel", for: .normal)
        newButton.titleLabel?.font = UIFont(name: alterDefaultFontRegular, size: buttonFontSize)
        newButton.addTarget(self, action: #selector(closePopup), for: .touchUpInside)
        return newButton
    }
    
    /// Creates a save button
    /// - Returns: a save button which will close the popup if it is clicked
    private func createSaveButton() -> UIButton {
        let saveButton = UIButton()
        saveButton.setTitle("Save to cloud", for: .normal)
        stylizeButton(saveButton)
        saveButton.addTarget(self, action: #selector(saveRoute), for: .touchUpInside)
        return saveButton
    }
    
    /// Creates a export button
    /// - Returns: a export button which will close the popup if it is clicked
    private func createExportButton() -> UIButton {
        let exportButton = UIButton()
        exportButton.setTitle("Export GPS file", for: .normal)
        stylizeButton(exportButton)
        exportButton.addTarget(self, action: #selector(exportRoute), for: .touchUpInside)
        return exportButton
    }
    
    /// defines the styling of the button
    /// - Parameter button: the button that is to add styling
    private func stylizeButton(_ button: UIButton) {
        button.titleLabel?.font = UIFont(name: alterDefaultFontRegular, size: buttonFontSize)
        button.frame = CGRect(x: 0, y: 0,
                              width: infoPanelBounds.width - innerViewSidePadding * 2,
                              height: 50)
        button.layer.cornerRadius = infoBlockBorderRadius
        button.layer.masksToBounds = true
        button.backgroundColor = UIColor.lightGray
    }
    
    /// Closes the popup
    func closePopup() {
        storeRoutePopupController.closeAlert()
    }
    
    /// Saves the route
    func saveRoute() {
        closePopup()
        let alert = UIAlertController(title: "Saving Route to Cloud", message: "Enter a Unique Name", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Enter Route Name"
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .default))
        alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { [weak alert] (_) in
            let textField = alert!.textFields![0]
            if (textField.text != nil && textField.text != "") {
                let route = Route(textField.text!)
                route.append(CheckPoint(self.source!.latitude, self.source!.longitude, self.checkpointDefaultName, self.checkpointDefaultDescription, true))
                for marker in self.markers {
                    let markerData = marker.userData as! CheckPoint
                    route.append(markerData)
                }
                do {
                    let url = try GPXManager.save(name: route.name, image: self.viewCapture(view: self.mapView))
                    route.setImage(path: url.absoluteString)
                } catch {
                }
                // TODO: separate local storage and server
                self.routeDesignerModel.saveToLocal(route: route)
                self.routeDesignerModel.saveToDB(route: route)
                
                let resultAlert = UIAlertController(title: "Saved Successfully", message: "Congrats", preferredStyle: .alert)
                resultAlert.addAction(UIAlertAction(title: "Okay", style: .default))
                self.present(resultAlert, animated: true, completion: nil)
            } else {
                let resultAlert = UIAlertController(title: "Save Failed", message: "Please give a name to your route", preferredStyle: .alert)
                resultAlert.addAction(UIAlertAction(title: "Okay", style: .default))
                self.present(resultAlert, animated: true, completion: nil)
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    /// exports the route
    func exportRoute() {
        closePopup()
        let alert = UIAlertController(title: "Exporting Route", message: "Enter a Unique Name", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Enter Route Name"
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .default))
        alert.addAction(UIAlertAction(title: "Export", style: .default, handler: { [weak alert] (_) in
            let textField = alert!.textFields![0] // Force unwrapping because we know it exists.
            if (textField.text != nil && textField.text != "") {
                let route = Route(textField.text!)
                route.append(CheckPoint(self.source!.latitude, self.source!.longitude, self.checkpointDefaultName, self.checkpointDefaultDescription, true))
                for marker in self.markers {
                    let markerData = marker.userData as! CheckPoint
                    route.append(markerData)
                }
                self.share(routes: [route])
            } else {
                let resultAlert = UIAlertController(title: "Save Failed", message: "Please give a name to your route", preferredStyle: .alert)
                resultAlert.addAction(UIAlertAction(title: "Okay", style: .default))
                self.present(resultAlert, animated: true, completion: nil)
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    /// Calculates info panel bounds
    private var infoPanelBounds: CGRect {
        return storeRoutePopupController.alert.infoPanel.bounds
    }

}