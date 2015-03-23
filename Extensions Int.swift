//
//  Extensions Int.swift
//  W24X
//
//  Created by Anil on 21/03/15.
//  Copyright (c) 2015 Variya Soft Solutions. All rights reserved.
//

import UIKit

extension Int {
    var degreesToRadian : CGFloat {
        return CGFloat(self) * CGFloat(M_PI) / 180.0
    }
}

