//
//  ImageObject.swift
//  ImagePicker
//
//  Created by Alex Paul on 1/20/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import Foundation


// always have an object for5 all data - used to sved data
struct ImageObject: Codable {
  let imageData: Data   // UIImage needs to be converted to data - after retrieving - API changes to UIImage
  let date: Date
  let identifier = UUID().uuidString   // crteates a quick ID on any object
}
