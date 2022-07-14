//
//  PlaceAnnotation.swift
//  testar
//
//  Created by diego on 5/29/20.
//  Copyright © 2020 diego. All rights reserved.
//

import Foundation
import MapKit

class PlaceAnnotation: NSObject, MKAnnotation
{
    let coordinate: CLLocationCoordinate2D
    let title: String?
    
    init(location: CLLocationCoordinate2D, title: String)
    {
        self.coordinate = location
        self.title = title
    }
}
