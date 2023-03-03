//
//  Activity.swift
//  Hunt and Scavenge
//
//  Created by Abraham on 3/2/23.
//

import Foundation
import UIKit
import CoreLocation

class Activity {
    let title: String
    let description: String
    var image: UIImage?
    var imageLocation: CLLocation?
    var isComplete: Bool {
        image != nil
    }

    init(title: String, description: String) {
        self.title = title
        self.description = description
    }

    func set(_ image: UIImage, with location: CLLocation) {
        self.image = image
        self.imageLocation = location
    }
}

extension Activity {
    static var mockedActivities: [Activity] {
        return [
            Activity(title: "Where do you live?",
                 description: "Attach a picture of your house for funsies."),
            Activity(title: "Where do you buy groceries?",
                 description: "Show your latest purchase from there if you can."),
            Activity(title: "Where do you work?",
                 description: "I won't take advantage of this information, trust me.")
        ]
    }
}

