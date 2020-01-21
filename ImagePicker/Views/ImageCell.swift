//
//  ImageCell.swift
//  ImagePicker
//
//  Created by Alex Paul on 1/20/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import UIKit

// step 1: creating custom delegation -
protocol ImageCellDelegate: AnyObject {   // AnyObject requires ImageCellDelegate to only works with class types
  // list required functions, initializers, variables
  func didLongPress(_ imageCell: ImageCell)
}

class ImageCell: UICollectionViewCell {
  
  @IBOutlet weak var imageView: UIImageView!
  
  // step 2:  creating custom delegation - define optional delegate variable
  weak var delegate: ImageCellDelegate?    // assigning the delegate - not yet ___.delegate = self
  
  // step 1: long press setup
  // set up long press gesture recognizer
  private lazy var longPressGesture: UILongPressGestureRecognizer = {
    let gesture = UILongPressGestureRecognizer()
    gesture.addTarget(self, action: #selector(longPressAction(gesture:)))
    return gesture
  }()
  
  override func layoutSubviews() {
    super.layoutSubviews()
    layer.cornerRadius = 20.0    // round the layer of the cell - 
    backgroundColor = .purple
    // step 3: long press set up - added gesture to view
    addGestureRecognizer(longPressGesture)
  }
  
  // step 2 : lomg press setup
  // func gets called when long press is activated
  @objc
  private func longPressAction(gesture: UILongPressGestureRecognizer) {
    if gesture.state == .began { // if gesture is active
      gesture.state = .cancelled
      return
    }
    // step 3:  creating custom delegation - explicitly use delegate object to notify of any update e.g
    //        notifying ImagesViewController when the user long presses the cell
    delegate?.didLongPress(self)
    // imageViewController.didLongPress(:)
  }
  
  public func configureCell(imageObject: ImageObject){
    guard let image = UIImage(data: imageObject.imageData) else {
      return
    }
    imageView.image = image
  }
  
}


//=================================================================================================================
//                                                Today in Wrap up
//=================================================================================================================
/*
 
 * Used UIAlertController to present and action sheet
 * access users photo liubrary
 * access users camera
 * add th eNSCameraUsageDescription key to the info.plist
 * E=Resized the UIImage using UIGraphicsImageRenderer
 * Implemented UILongGestureRecognizer() to present an action sheet for deletion
 * maintained the aspect ratio of the image using AVRect(AVFoundation framework)
 * Create custom delegate to notify the ImageViewController about long opress from ImageCell
 * Persisted image objects to the documents directory(create, read, delete
 
 OTHER FEATURE TO ADD
 *Share an image along with text to a user via SMS
 

 */
