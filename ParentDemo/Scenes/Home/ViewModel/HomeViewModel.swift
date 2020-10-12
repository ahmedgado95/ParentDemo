//
//  HomeViewModel.swift
//  ParentDemo
//
//  Created by ahmed gado on 10/5/20.
//  Copyright © 2020 ahmed gado. All rights reserved.
//

import Foundation
import GoogleMaps
import FirebaseAuth
class HomeViewModel {
    
    func logoutUser(successed : @escaping (String) -> Void) {
        do {
            try Auth.auth().signOut()
            successed("LogOUt")
        }
        catch {
            print("already logged out")
        }
    }
    
    func drowRoute( sourceLat : Double , sourceLng : Double  , destinationLat : Double , destinationLng: Double , mapView : GMSMapView  ){
        let url = NSURL(string: "\("https://maps.googleapis.com/maps/api/directions/json")?origin=\(sourceLat),\(sourceLng)&destination=\(destinationLat),\(destinationLng)&mode=driving&key=\(Constants.aPIKEY)")
        let task = URLSession.shared.dataTask(with: url! as URL) { (data, response, error) -> Void in
            do {
                if data != nil {
                    let dic = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableLeaves) as!  [String:AnyObject]
                    //                        print(dic)
                    let status = dic["status"] as! String
                    var routesArray:String!
                    if status == "OK" {
                        routesArray = ((((dic["routes"]!as! [Any])[0] as! [String:Any])["overview_polyline"] as! [String:Any])["points"] as! String)
                        DispatchQueue.main.async {
                            if routesArray != nil{
                                let path = GMSPath.init(fromEncodedPath: routesArray!)
                                let singleLine = GMSPolyline.init(path: path)
                                singleLine.strokeWidth = 6.0
                                singleLine.strokeColor = #colorLiteral(red: 0.0390000008, green: 0.0120000001, blue: 0.2820000052, alpha: 1)
                                singleLine.map = mapView
                            }
                        }
                    }
                }
            } catch let error {
                print(error.localizedDescription)
            }
        }
        task.resume()
    }
}
