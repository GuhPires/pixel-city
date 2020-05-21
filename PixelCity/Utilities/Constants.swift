//
//  Constants.swift
//  PixelCity
//
//  Created by Gustavo Mac Mini on 20/05/20.
//  Copyright © 2020 DEVX. All rights reserved.
//

import Foundation

let API_KEY = FLICKR_KEY

func flickrURL(withAnnotation annotation: DroppablePin, numberOfPhotos number: Int) -> String {
    return "https://www.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(API_KEY)&lat=\(annotation.coordinate.latitude)&lon=\(annotation.coordinate.longitude)&radius=5&radius_units=km&per_page=\(number)&format=json&nojsoncallback=1"
}
