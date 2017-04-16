//
//  RouteDesignerConstants.swift
//  lAyeR
//
//  Created by Patrick Cho on 4/15/17.
//  Copyright © 2017 nus.cs3217.layer. All rights reserved.
//

import Foundation

struct RouteDesignerConstants {
    
    //---------- Testing ----------
    
    // If set to true, will do Check_Rep (might slow down the app significantly)
    static let testing = true
    
    //---------- Thresholds ----------
    
    // Determines how close a tap must be to a pixel in order for the pixel to be considered as tapped
    static let tapPixelThreshold = 45.0 // in pixels
    
    // Determines how similar two routes are before the second route is not shown
    static let routeSimilarityThreshold = 0.001 // in lat lng coordinates
    
    // Determines the turn angle required for a point to be automatically considered a control point
    static let turnAngleThreshold = 2.5 // in radians
    
    // Determines how far two control points are before a control point needs to be added automatically
    static let distanceThreshold = 0.01 // in lat lng coordinates
    
    //---------- Display Text ----------
    
    static let currentLocationText = "Current Location"
    static let checkpointDefaultDescription = ""
    static let checkpointDefaultName = "Checkpoint"
    static let selectDestinationText = "Please select destination"
    static let selectSourceText = "Please select source"
    
    // For Error Messages
    static let cannotFindDestinationText = "We can't find this destination!"
    static let cannotFindSourceText = "We can't find this source!"
    static let cannotChooseSameSourceAndDestinationText = "Please select different source and destination!"
    
    //---------- Design ----------
    
    static let mapLineColor = UIColor(red: 0, green: 0.7098, blue: 0.7098, alpha: 1)
    static let mapBottomPadding: CGFloat = 55
    static let goButtonCornerRadius: CGFloat = 5
    static let startButtonCornerRadius: CGFloat = 7
    static let pinActivatedAlpha: CGFloat = 1.0
    static let pinDeactivatedAlpha: CGFloat = 0.5
    
}
