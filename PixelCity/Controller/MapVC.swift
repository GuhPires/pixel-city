//
//  MapVC.swift
//  PixelCity
//
//  Created by Gustavo Mac Mini on 20/05/20.
//  Copyright © 2020 DEVX. All rights reserved.
//

import UIKit
import MapKit

class MapVC: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
    }

    // MARK: - Actions
    @IBAction func onCenterMapPressed(_ sender: Any) {
    }
    
}

// MARK: - Map View methods
extension MapVC: MKMapViewDelegate {
    
}
