//
//  ViewController.swift
//  ImagePicker
//
//  Created by Alex Paul on 1/20/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import UIKit
import AVFoundation   // we want to AVMakeRect to maintain size ratio

class ImagesViewController: UIViewController {
  
  @IBOutlet weak var collectionView: UICollectionView!
  
  private var imageObjects = [ImageObject]()
  
  private let imagePickerController = UIImagePickerController()
  
  private let dataPersistence = PersistenceHelper(filename: "images.plist")
  
  private var selectedImage : UIImage? {
    didSet {
      // gets called when image is selected
      appendNewPhotoToCollection()
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    collectionView.dataSource = self
    collectionView.delegate = self
    loadImageObjects()
    // set UIImagePickerController delegate as this view controller
    imagePickerController.delegate = self
  }
  private func loadImageObjects() {
    do {
      imageObjects = try dataPersistence.loadEvents()
    } catch {
      print("loading objects error: \(error)")
    }
  }
  
  // MARK: - appendNewPhotoToCollection
  private func appendNewPhotoToCollection() {
    guard let image = selectedImage,
      // jpegData(compressionQuality: 1.0) converts UIImage to Data
      let imageData = image.jpegData(compressionQuality: 1.0) else {
        print("Image is nil")
        return
    }
    print("original image size is \(image.size)")
    
    // resize image
    let size = UIScreen.main.bounds.size
    
    // we will maintain the aspect ratio of the image
    let rect = AVMakeRect(aspectRatio: image.size, insideRect: CGRect(origin: CGPoint.zero, size: size))
    
    // resize image
    let resizeImage = image.resizeImage(to: rect.size.width, height: rect.size.height)
    print("resize image size is \(resizeImage.size)")
    // jpegData(compressionQuality: 1.0) converts UIImage to Data
    guard let resizedImageData = resizeImage.jpegData(compressionQuality: 1.0) else {
      return
      
    }
    
    // create an image object using image
    let thisImageObject = ImageObject(imageData: imageData, date: Date())
    
    // insert new image object in to imageObjects
    imageObjects.insert(thisImageObject, at: 0)
    
    // create an indexPath for insertion into collection view
    let indexPath = IndexPath(row: 0, section: 0)
    
    
    
    // insert new cell into collection view
    collectionView.insertItems(at: [indexPath])
    
    // persist image object to documents directory
    do {
      try dataPersistence.create(item: thisImageObject)
    } catch {
      print("saving error \(error)")
    }
  }
  
  
  @IBAction func addPictureButtonPressed(_ sender: UIBarButtonItem) {
    // presents an action sheet to the user
    // actions: camera, photo library, cancel
    // alert dialog in center \\
    let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    // handler - is what happens after user selects object (camera)
    let cameraAction = UIAlertAction(title: "Camera", style: .default) { [weak self] alertAction in
      self?.showImageController(isCameraSelected: true)
    }
    
    // if source type is photoLibrary - closure is handled
    let photoLibraryAction = UIAlertAction(title: "Photo Library", style: .default) { [weak self] alertAction in
      self?.showImageController(isCameraSelected: false)
    }
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
    
    // check i fcamera is available, if camera is not available
    // the app will crash
    if UIImagePickerController.isSourceTypeAvailable(.camera) {
      alertController.addAction(cameraAction)
    }
    
    alertController.addAction(photoLibraryAction)
    alertController.addAction(cancelAction)
    
    present(alertController, animated: true)
  }
  
  private func showImageController(isCameraSelected: Bool) {
    // source type default will be .photoLibrary
    imagePickerController.sourceType = .photoLibrary
    
    if isCameraSelected {
      imagePickerController.sourceType = .camera
    }
    present(imagePickerController, animated: true)
  }
  
}

// MARK: - UICollectionViewDataSource
extension ImagesViewController: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return imageObjects.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as? ImageCell else {
      fatalError("could not downcast to an ImageCell")
    }
    let imageObject = imageObjects[indexPath.row]
    cell.configureCell(imageObject: imageObject)
    
    // step 4 - creating custom delegation - set delegate object
    // similar to tableView.delegate = self
    cell.delegate = self
    return cell
  }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension ImagesViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let maxWidth: CGFloat = UIScreen.main.bounds.size.width
    let itemWidth: CGFloat = maxWidth * 0.80
    return CGSize(width: itemWidth, height: itemWidth)  }
}

extension ImagesViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    imagePickerController.dismiss(animated: true)
    
  }
  public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    // we need to acess the UIImagePickerController.InfoKey.orginalImage key to gety the
    // UIImage that we selected
    guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
      print("image selected not found")
      return      // no need for fatal error = app doesnt need to crsh kif no image loaded
    }
    selectedImage = image
    imagePickerController.dismiss(animated: true)
  }
}

// step 6: creating custom delegation - conform to delegate
extension ImagesViewController : ImageCellDelegate {
  func didLongPress(_ imageCell: ImageCell) {
    print("cell was selected")
    
    guard let indexPath = collectionView.indexPath(for: imageCell) else {
      return
    }
    // present an action sheet
    
    // actions: delete, cancel
    let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [weak self] alertAction in
      self?.deleteImageObject(indexPath: indexPath)
    }
    
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
    alertController.addAction(deleteAction)
    alertController.addAction(cancelAction)
    present(alertController, animated: true)
  }
  
  private func deleteImageObject(indexPath: IndexPath) {
    // delete image object from documents library
    do {
      try dataPersistence.delete(event: indexPath.row)
      

    } catch {
      print("Delete Error: \(error)")
    }
    imageObjects.remove(at: indexPath.row)
    
    collectionView.deleteItems(at: [indexPath])
  
}
}

// more about resizin images - recommended watch
// more here: https://nshipster.com/image-resizing/
// MARK: - UIImage extension
extension UIImage {
  func resizeImage(to width: CGFloat, height: CGFloat) -> UIImage {
    let size = CGSize(width: width, height: height)
    let renderer = UIGraphicsImageRenderer(size: size)
    return renderer.image { (context) in
      self.draw(in: CGRect(origin: .zero, size: size))
    }
  }
}





