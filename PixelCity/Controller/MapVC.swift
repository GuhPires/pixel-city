//
//  MapVC.swift
//  PixelCity
//
//  Created by Gustavo Mac Mini on 20/05/20.
//  Copyright © 2020 DEVX. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Alamofire
import AlamofireImage

class MapVC: UIViewController, UIGestureRecognizerDelegate {
    
    // MARK: - Outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var pullUpViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var pullUpView: UIView!
    
    // MARK: - Global variables/constants
    var locationManager = CLLocationManager()
    let authStatus = CLLocationManager.authorizationStatus()
    let regionRadius: Double = 1000
    
    let screenSize = UIScreen.main.bounds
    var spinner: UIActivityIndicatorView?
    var progressLbl: UILabel?
    
    var flowLayout = UICollectionViewFlowLayout()
    var collectionView: UICollectionView?
    
    var imgURLArray = [String]()
    var imgArray = [UIImage]()
    
    // MARK: - Init methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        locationManager.delegate = self
        
        configureLocationServices()
        addDoubleTap()
        
        setupCollectionView()
    }
    
    
    func setupCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: flowLayout)
        collectionView?.register(PhotoCell.self, forCellWithReuseIdentifier: "photoCell")
        collectionView?.delegate = self
        collectionView?.dataSource = self
        collectionView?.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        pullUpView.addSubview(collectionView!)
    }
    
    // MARK: - Custom methods
    func addDoubleTap() {
        let dbTap = UITapGestureRecognizer(target: self, action: #selector(dropPin(sender:)))
        dbTap.numberOfTapsRequired = 2
        dbTap.delegate = self
        mapView.addGestureRecognizer(dbTap)
    }
    
    func addSwipe() {
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(animateViewDown))
        swipe.direction = .down
        pullUpView.addGestureRecognizer(swipe)
    }
    
    func animateViewUp() {
        pullUpViewHeightConstraint.constant = 300
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func animateViewDown() {
        cancelAllSessions()
        pullUpViewHeightConstraint.constant = 1
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    func addSpinner() {
        spinner = UIActivityIndicatorView()
        spinner?.center = CGPoint(x: (screenSize.width / 2) - ((spinner?.frame.width)! / 2), y: 120)
        spinner?.style = .large
        spinner?.color = #colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1)
        spinner?.startAnimating()
        collectionView?.addSubview(spinner!)
    }
    
    func removeSpinner() {
        if spinner != nil {
            spinner?.removeFromSuperview()
        }
    }
    
    func addProgressLabel() {
        progressLbl = UILabel()
        progressLbl?.frame = CGRect(x: (screenSize.width / 2) - 125, y: 135, width: 250, height: 40)
        progressLbl?.font = UIFont(name: "Avenir Next", size: 14)
        progressLbl?.textColor = #colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1)
        progressLbl?.textAlignment = .center
        collectionView?.addSubview(progressLbl!)
    }
    
    func removeProgressLabel() {
        if progressLbl != nil {
            progressLbl?.removeFromSuperview()
        }
    }

    // MARK: - Actions
    @IBAction func onCenterMapPressed(_ sender: Any) {
        if authStatus == .authorizedAlways || authStatus == .authorizedWhenInUse {
            centerMapOnUserLocation()
        }
    }
    
}

// MARK: - Map View methods
extension MapVC: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if !(annotation is MKUserLocation) {
            let pinAnnotation = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "droppablePin")
            pinAnnotation.pinTintColor = #colorLiteral(red: 0.9771530032, green: 0.7062081099, blue: 0.1748393774, alpha: 1)
            pinAnnotation.animatesDrop = true
            return pinAnnotation
        } else {
            return nil
        }
    }
    
    func centerMapOnUserLocation() {
        guard let coord = locationManager.location?.coordinate else { return }
        let coordRegion = MKCoordinateRegion(center: coord, latitudinalMeters: regionRadius * 2.0, longitudinalMeters: regionRadius * 2.0)
        mapView.setRegion(coordRegion, animated: true)
    }
    
    @objc func dropPin(sender: UIGestureRecognizer) {
        removePin()
        removeSpinner()
        removeProgressLabel()
        cancelAllSessions()
        
        imgURLArray = []
        imgArray = []
        collectionView?.reloadData()
        
        let touchPoint = sender.location(in: mapView)
        let touchCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        
        let annotation = DroppablePin(coordinate: touchCoordinate, identifier: "droppablePin")
        mapView.addAnnotation(annotation)
        
        let coordinateRegion = MKCoordinateRegion(center: touchCoordinate, latitudinalMeters: regionRadius * 2.0, longitudinalMeters: regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
        
        retrieveUrls(forAnnotation: annotation) { (urls) in
            if urls {
                self.retrieveImages { (images) in
                    if images {
                        self.removeSpinner()
                        self.removeProgressLabel()
                        self.collectionView?.reloadData()
                    }
                }
            }
        }
        
        animateViewUp()
        addSwipe()
        addSpinner()
        addProgressLabel()
    }
    
    func removePin() {
        for annotation in mapView.annotations {
            mapView.removeAnnotation(annotation)
        }
    }
    
    func retrieveUrls(forAnnotation annotation: DroppablePin, handler: @escaping (_ status: Bool) -> ()) {
        AF.request(flickrURL(withAnnotation: annotation, numberOfPhotos: 40)).responseJSON { (response) in
            
            if response.error == nil {
                guard let json = response.value as? Dictionary<String, AnyObject> else { return }
                let photosDict = json["photos"] as! Dictionary<String, AnyObject>
                let photosArr = photosDict["photo"] as! [Dictionary<String, AnyObject>]
                for photo in photosArr {
                    let postUrl = "https://farm\(photo["farm"]!).staticflickr.com/\(photo["server"]!)/\(photo["id"]!)_\(photo["secret"]!)_z_d.jpg"
                    self.imgURLArray.append(postUrl)
                }
                handler(true)
            } else {
                debugPrint(response.error as Any)
                handler(false)
            }
        }
    }
    
    func retrieveImages(handler: @escaping (_ status: Bool) -> ()) {
        for url in imgURLArray {
            AF.request(url).responseImage { (response) in
                
                if case .success(let image) = response.result {
                    self.imgArray.append(image)
                    self.progressLbl?.text = "\(self.imgArray.count)/\(self.imgURLArray.count) IMAGES DOWNLOADED"
                    
                    if self.imgArray.count == self.imgURLArray.count {
                        handler(true)
                    }
                } else {
                    debugPrint(response.error as Any)
                    handler(false)
                }
            }
        }
    }
    
    func cancelAllSessions() {
        Alamofire.Session.default.session.getTasksWithCompletionHandler { (sessionDataTask, uploadData, downloadData) in
            sessionDataTask.forEach({ $0.cancel() })
            downloadData.forEach({ $0.cancel() })
        }
    }
}

// MARK: - Core Location methods
extension MapVC: CLLocationManagerDelegate {
    func configureLocationServices() {
        if authStatus == .notDetermined {
            locationManager.requestAlwaysAuthorization()
        } else {
            return
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        centerMapOnUserLocation()
    }
}

// MARK: - Collection View methods
extension MapVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imgArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as? PhotoCell {
            let imgFromIdx = imgArray[indexPath.item]
            let imgView = UIImageView(image: imgFromIdx)
            cell.addSubview(imgView)
            return cell
        } else {
            return PhotoCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let popVC = storyboard?.instantiateViewController(withIdentifier: "PopVC") as? PopVC else { return }
        popVC.initData(forImage: imgArray[indexPath.item])
        present(popVC, animated: true, completion: nil)
    }
}
