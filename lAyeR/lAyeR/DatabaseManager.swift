//
//  DatabaseManager.swift
//  lAyeR
//
//  Created by Victoria Duan on 2017/3/28.
//  Copyright © 2017年 nus.cs3217.layer. All rights reserved.
//

import ObjectMapper
import FirebaseDatabase

class DatabaseManager {
    
    static let instance = DatabaseManager()
    private(set) var currentUserProfile: UserProfile?
    
    func addUserProfileToDatabase(uid: String, userProfile: UserProfile) {
        
        FIRDatabase.database().reference().child("profiles").child(uid).setValue(userProfile.toJSON())
    }
    
    func updateUserProfile(uid: String, userProfile: UserProfile) {
        currentUserProfile = userProfile
        FIRDatabase.database().reference().child("profiles").child(uid).setValue(userProfile.toJSON())
    }
    
    func addRouteToDatabase(route: Route) {
        
        FIRDatabase.database().reference().child("routes").observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.hasChild(route.name) {
                print("route exists")
                return
            }
            FIRDatabase.database().reference().child("routes").child(route.name).setValue(route.toJSON())
            guard let uid = UserAuthenticator.instance.currentUser?.uid else { return }
            self.getUserProfile(uid: uid) { userProfile in
                userProfile.designedRoutes.append(route.name)
                self.updateUserProfile(uid: uid, userProfile: userProfile)
            }
        })
        
    }
    
    func verifyUserProfile(uid: String, completion: @escaping () -> ()) {
        FIRDatabase.database().reference().child("profiles").observeSingleEvent(of: .value, with: { (snapshot) in
            guard snapshot.hasChild(uid) else {
                completion()
                return
            }
        })
    }
    
    func removeRouteFromDatabase(routeName: String) {
        FIRDatabase.database().reference().child("routes").child(routeName).removeValue()
    }
    
    /// Currently, updates whole structure. Subject to change after
    /// updating Route designer.
    func updateRouteInDatabase(route: Route) {
        FIRDatabase.database().reference().child("routes").child(route.name).setValue(route.toJSON())
    }
    
    func getUserProfile(uid: String, completion: @escaping (_ userProfile: UserProfile) -> ()) {
        FIRDatabase.database().reference().child("profiles").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let value = snapshot.value as? [String: Any],
                  let profile = UserProfile(JSON: value) else {
                    return
            }
            completion(profile)
        }) { error in
            print(error.localizedDescription)
        }
    }
    
    /// Use in user profile.
    func getRoute(withName routeName: String, completion: @escaping (_ route: Route) -> ()) {
        FIRDatabase.database().reference().child("routes").child(routeName).observeSingleEvent(of: .value, with: { snapshot in
            guard let value = snapshot.value as? [String: Any],
                let points = value["checkPoints"] as? [[String: Any]],
                let name = value["name"] as? String,
                let checkPoints = points.map ({ CheckPoint(JSON: $0) }) as? [CheckPoint],
                let image = value["imagePath"] as? String else { return }
            let route = Route(name, checkPoints)
            route.setImage(path: image)
            completion(route)
        }) { error in
            print(error.localizedDescription)
        }
    }
    
    /// Queries routes in range
    func getRoutes(between source: GeoPoint, and destination: GeoPoint, inRange range: Double, completion: @escaping (_ routes: [Route]) -> ()) {
        FIRDatabase.database().reference().child("routes").observeSingleEvent(of: .value, with: { snapshot in
            guard let value = snapshot.value as? [String: [String: Any]] else {
                return
            }
            var routes: [Route] = []
            for result in value.values {
                guard let points = result["checkPoints"] as? [[String: Any]],
                    let name = result["name"] as? String else {
                        continue
                }
                guard let checkPoints = points.map ({ CheckPoint(JSON: $0) }) as? [CheckPoint] else { return }
                let route = Route(name, checkPoints)
                var sourceIndex = -1
                var destIndex = -1
                var sourceDist = range
                var destDist = range
                for i in 0 ..< route.size {
                    let newSourceDist = GeoUtil.getCoordinateDistance(route.checkPoints[i], source)
                    if newSourceDist < sourceDist {
                        sourceIndex = i
                        sourceDist = newSourceDist
                    }
                    let newDestDist = GeoUtil.getCoordinateDistance(route.checkPoints[i], destination)
                    if  newDestDist < destDist {
                        destIndex = i
                        destDist = newDestDist
                    }
                }
                if sourceIndex == destIndex {
                    continue
                }
                if sourceIndex >= 0 && destIndex >= 0 {
                    let section = destIndex > sourceIndex ? route.checkPoints[sourceIndex ... destIndex] : route.checkPoints[destIndex ... sourceIndex]
                    let returnRoute = Route(route.name)
                    for checkpoint in section {
                        if destIndex > sourceIndex {
                            returnRoute.append(checkpoint)
                        } else {
                            returnRoute.insert(checkpoint, at: 0)
                        }
                    }
                    routes.append(returnRoute)
                }
            }
            completion(routes)
        }) { error in
            print(error.localizedDescription)
        }
    }
}
