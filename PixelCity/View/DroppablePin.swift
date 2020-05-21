//
//  DroppablePin.swift
//  PixelCity
//
//  Created by Gustavo Mac Mini on 20/05/20.
//  Copyright © 2020 DEVX. All rights reserved.
//

import UIKit
import MapKit

class DroppablePin: NSObject, MKAnnotation {
    dynamic var coordinate: CLLocationCoordinate2D
    var identifier: String
    
    init(coordinate: CLLocationCoordinate2D, identifier: String) {
        self.coordinate = coordinate
        self.identifier = identifier
        super.init()
    }
}
