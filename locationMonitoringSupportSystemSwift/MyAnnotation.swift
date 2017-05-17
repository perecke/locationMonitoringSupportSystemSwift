//
//  MyAnnotation.swift
//  locationMonitoringSupportSystemSwift
//
//  Created by Kubota Naoyuki on 2017/05/04.
//  Copyright © 2017年 Kubota Naoyuki. All rights reserved.
//

import UIKit
import MapKit

class MyAnnotation: NSObject {
    
    //Create the properties
    var pinTitle : String = "";
    var pinComment : String = "";
    var pinLat : Double;
    var pinLong : Double;
    var beingInRange : Bool;
    
    
    //Create initializer
    init(title: String, comment: String, latitude: Double, longtitude: Double) {
        self.pinTitle = title;
        self.pinComment = comment;
        self.pinLat = latitude;
        self.pinLong = longtitude;
        self.beingInRange = false;
        
    }
    

}
