//
//  ViewController.swift
//  SeeFood2
//
//  Created by verebes on 08/05/2018.
//  Copyright © 2018 A&D Progress. All rights reserved.
//

import UIKit
import VisualRecognitionV3
import SVProgressHUD
import Social

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var topBarImageView: UIImageView!
    @IBOutlet weak var shareButton: UIButton!
    
    let imagePicker = UIImagePickerController()
    let apiKey = "478777b3b9cb8489edb2bfdad3fb1b567b4d4b7e"
    let version = "2018-05-08"
    
    var classificationResults: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        shareButton.isHidden = true
        
    }

    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
        present(imagePicker, animated: true)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        cameraButton.isEnabled = false
        SVProgressHUD.show()
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            imageView.image = image
            imagePicker.dismiss(animated: true, completion: nil)
            
            let imageData = UIImageJPEGRepresentation(image, 0.05)
//            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
//            let fileURL = documentsURL.appendingPathComponent("tempImage.jpg")
//
//            try? imageData?.write(to: fileURL)
            
            
            let visualRecognition = VisualRecognition(apiKey: apiKey, version: version)
            visualRecognition.classify(image: UIImage(data: imageData!)!) { (classifiedImage) in
                //print(classifiedImage)
                let classes = classifiedImage.images.first!.classifiers.first!.classes
                
                self.classificationResults.removeAll()

                for element in classes {
                    self.classificationResults.append(element.className)
                }
//
//                for index in 0..<classes.count {
//                    self.classificationResults.append(classes[index].className)
//                }
                print(self.classificationResults)
                
                DispatchQueue.main.async {
                    self.cameraButton.isEnabled = true
                    SVProgressHUD.dismiss()
                    self.shareButton.isHidden = false
                }
                
                if self.classificationResults.contains("hotdog") {
                    DispatchQueue.main.async {
                        self.navigationItem.title = "Hotdog!"
                        self.navigationController?.navigationBar.barTintColor = UIColor.green
                        self.navigationController?.navigationBar.isTranslucent = false
                        self.topBarImageView.image = UIImage(named: "hotdog")
                    }
                } else {
                    DispatchQueue.main.async {
                        self.navigationItem.title = "NOT Hotdog"
                        self.navigationController?.navigationBar.barTintColor = UIColor.red
                        self.navigationController?.navigationBar.isTranslucent = false
                        self.topBarImageView.image = UIImage(named: "not-hotdog")
                    }
                }
            }
        }
    }
    
    @IBAction func shareTapped(_ sender: UIButton) {
        
        if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeTwitter) {
            let vc = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
            vc?.setInitialText("My food is a \(navigationItem.title!)")
            vc?.add(UIImage(named: "hotdogBackground"))
            present(vc!, animated: true, completion: nil)
            
        } else {
            navigationItem.title = "Please log in to Twitter"
        }
    }
    

}

