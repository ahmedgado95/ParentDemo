//
//  HomeVC.swift
//  ParentDemo
//
//  Created by ahmed gado on 10/5/20.
//  Copyright © 2020 ahmed gado. All rights reserved.
//

import UIKit
import GoogleMaps
import Firebase
import RxCocoa
import RxSwift
class HomeVC: UIViewController  {
    // MARK: - IBOutlet
    @IBOutlet weak var ChoiceChildButton: CustomButton!
    @IBOutlet weak var logOutButton: UIButton!
    @IBOutlet weak var mapView: GMSMapView!
    // MARK: - varabile
    var locationManager = CLLocationManager()
    var userId = ""
    var latitude = 0.0
    var longitude = 0.0
    var childPickerView = UIPickerView()
    var childArr = [ChildModel]()
    let disposeBag = DisposeBag()
    let rigisterViewModel = RegisterViewModel()
    let homeViewModel = HomeViewModel()
    var appDelegate = UIApplication.shared.delegate as? AppDelegate
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = true
        // Do any additional setup after loading the view.
        mapView.settings.compassButton = true
        // GOOGLE MAPS SDK: USER'S LOCATION
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        //Location Manager code to fetch current location
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        childPickerView.delegate = self
        childPickerView.dataSource = self
        subscribeToChoiceChild()
        subscribeToResponseChild()
        subscribeToLoding()
        subscribeToLogOut()
    }
    // MARK: - subscribeToChoiceChild
    func subscribeToChoiceChild(){
        ChoiceChildButton.rx.tap.throttle(RxTimeInterval.milliseconds(500), scheduler: MainScheduler.instance).subscribe(onNext: {[weak self] (_) in
            guard let self = self else {return}
            self.rigisterViewModel.featchChild { (child) in
                print("finish fetch CHILD data")
                self.ChoiceChildButton.inputAccessoryView = self.accessoryToolbar
                self.ChoiceChildButton.inputView = self.childPickerView
            }
            
        }).disposed(by: disposeBag)
    }
    
    // MARK: - subscribeToResponseChild
    func subscribeToResponseChild() {
        rigisterViewModel.childModelObservable.subscribe(onNext: {(child) in
            self.childArr.removeAll()
            self.childArr = child
        }).disposed(by: disposeBag)
        
    }
    // MARK: - subscribeToLoding
    func subscribeToLoding(){
        rigisterViewModel.loadingBehavior.subscribe(onNext: {[weak self] (isLoading)
            in
            guard let self = self else {return}
            if isLoading {
                self.showIndicator()
            }else{
                self.hideIndicator()
            }
        }).disposed(by: disposeBag)
    }
    // MARK: - accessoryToolbar
    var accessoryToolbar: UIToolbar {
        get {
            let toolbarFrame = CGRect(x: 0, y: 0,width: view.frame.width, height: 44)
            let accessoryToolbar = UIToolbar(frame: toolbarFrame)
            let doneButton = UIBarButtonItem(title: "Choose", style: .plain, target: self, action: #selector(onDoneButtonTapped))
            let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace,target: nil,action: nil)
            let cancelButton = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(cancelPicker))
            accessoryToolbar.setItems([doneButton,flexibleSpace,cancelButton], animated: false)
            accessoryToolbar.barTintColor = UIColor.white
            return accessoryToolbar
        }
    }
    @objc func onDoneButtonTapped() {
        let child = childArr[childPickerView.selectedRow(inComponent: 0)]
        //        ChoiceChildButton.setTitle(child.name ?? "Ahmed", for: .normal)
        let reference = Database.database().reference()
        let user = reference.child(Constants.uSERSPARENT).child(userId)
        let value:[String: Any] = [ Constants.hAVECHILD : child.name! , Constants.lATCHILD : child.lat!, Constants.lANGCHILD : child.lang!]
        user.updateChildValues(value)
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2DMake(child.lat!, child.lang!)
        let markerImage = UIImage(named: "marker")!.withRenderingMode(.alwaysTemplate)
        let markerView = UIImageView(image: markerImage)
        markerView.frame.size = CGSize(width: 30, height: 30)
        marker.iconView = markerView
        marker.map = self.mapView
        homeViewModel.drowRoute(sourceLat:latitude , sourceLng:longitude , destinationLat: child.lat!, destinationLng: child.lang!, mapView: self.mapView)
        let coordinate0 = CLLocation(latitude: child.lat!, longitude: child.lang!)
        let coordinate1 = CLLocation(latitude: latitude, longitude: longitude)
        let distanceInMeters = coordinate0.distance(from: coordinate1)
        print(distanceInMeters)
        if distanceInMeters > 10000 {
            self.appDelegate?.sendNotification(message: "be careful your child is out of safe area")
        }else {
            self.appDelegate?.sendNotification(message: "your child is in safe area")
        }
        ChoiceChildButton.resignFirstResponder()
        self.view.endEditing(true)
        
    }
    
    @objc func cancelPicker() {
        self.view.endEditing(true)
    }
    
    
    // MARK: - subscribeToLogOut
    func subscribeToLogOut(){
        logOutButton.rx.tap.throttle(RxTimeInterval.milliseconds(500), scheduler: MainScheduler.instance).subscribe(onNext: {[weak self] (_) in
            guard let self = self else {return}
            self.homeViewModel.logoutUser {[weak self] (success) in
                guard let self = self else {return}
                self.navigationController?.popViewController(animated: true)
            }
            
        }).disposed(by: disposeBag)
    }
}
extension HomeVC: UIPickerViewDelegate,UIPickerViewDataSource{
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return childArr.count
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let x = childArr[row]
        return x.name
    }
    
}

extension HomeVC : CLLocationManagerDelegate {
    //Location Manager delegates
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        let camera = GMSCameraPosition.camera(withLatitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!, zoom: 6.0)
        self.longitude =  (location?.coordinate.latitude)!
        self.latitude = (location?.coordinate.longitude)!
        self.mapView?.animate(to: camera)
        print("location")
        let reference = Database.database().reference()
        let user = reference.child(Constants.uSERSPARENT).child(userId)
        let value:[String: Any] = [ Constants.lAT: (location?.coordinate.latitude)!  , Constants.lANG : (location?.coordinate.longitude)!]
        user.updateChildValues(value)
        self.locationManager.stopUpdatingLocation()
        
    }
}
