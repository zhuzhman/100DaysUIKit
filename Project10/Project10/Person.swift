//
//  Person.swift
//  Project10
//
//  Created by Mikhail Zhuzhman on 02.06.2024.
//

import UIKit

class Person: NSObject {
    var name: String
    var image: String
    var imagePath: URL
    
    init(name: String, image: String, imagePath: URL) {
        self.name = name
        self.image = image
        self.imagePath = imagePath
    }
}
