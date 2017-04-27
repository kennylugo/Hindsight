//
//  ProfileViewController.swift
//  Vlogr
//
//  Created by Kenny Batista on 1/17/17.
//  Copyright © 2017 kennybatista. All rights reserved.
//
import UIKit
import Firebase
import MobileCoreServices
import FirebaseStorage
import FirebaseDatabase
import AVFoundation
import AVKit
import MessageUI
import AlamofireImage


class ViewController: UIViewController, MFMessageComposeViewControllerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    //[START - Properties]
    // Top information section
    
    @IBOutlet weak var vloggies: UILabel!
    
    // Bottom CollectionView section
    @IBOutlet weak var collectionView: UICollectionView!
    
    var videoDownloadLinks = [String]()
    var videoThumbnailLinks = [String]()
    
    var avPlayerViewController = AVPlayerViewController()
    var avPlayer: AVPlayer?
    
    var vloggiesNumber = 0
    @IBOutlet weak var bannerOutlet: UIView!
    
    
    //[END - Properties]
    
    
    //[START Methods]
    override func viewDidLoad() {
        super.viewDidLoad()
        
               
        
        
        
        
        
        
        
        
        
        
        
        
//         Retrive data from FirebaseDatabase
                let databaseReference = FIRDatabase.database().reference().child("videos")
        
                databaseReference.observe(.childAdded, with: {
                    snapshot in
        
                    let postDict = snapshot.value as? [String : AnyObject] ?? [:]
                    print(postDict)
                    
                    let videoDownloadURL = postDict["videodownloadlink"]!
                    let videoThumbnail = postDict["thumbnail"]!
                    
                    
                    for index in postDict {
                        print(index)
                        print("------------------------")
                    }
                    

                        self.videoDownloadLinks.insert(videoDownloadURL as! String, at: 0)
                        self.videoThumbnailLinks.insert(videoThumbnail as! String, at: 0)
                        
                        self.collectionView.reloadData()
                        print(self.videoDownloadLinks.count)
                        print(self.videoThumbnailLinks.count)
        
                        self.vloggiesNumber += 1
        
                    self.vloggies.text = String(describing: self.vloggiesNumber)
                })
   
    }
    

    
    @IBAction func recordButton(_ sender: UIButton) {
        
        //        //Shadows
                sender.layer.shadowColor = UIColor.black.cgColor
                sender.layer.shadowOpacity = 0.7
                sender.layer.shadowOffset = CGSize.zero
                sender.layer.shadowRadius = 5
        
        let vc = MainViewController(nibName: "cameraViewController", bundle: nil)
        self.present(vc, animated: true, completion: nil)
        
//     Defaul Camera
//        if UIImagePickerController.isSourceTypeAvailable(.camera) == true {
//            print(#function)
//            let cameraController = UIImagePickerController()
//            cameraController.sourceType = .camera
//            cameraController.mediaTypes = [kUTTypeMovie as String]
//            cameraController.allowsEditing = false
//            cameraController.delegate = self
//            
//            present(cameraController, animated: true, completion: nil)
        
//        } else {
//            print("There is no camera")
//            let alertController = UIAlertController(title: "Error!", message: "There is no camera on your device", preferredStyle: .alert)
//            let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
//            alertController.addAction(alertAction)
//            present(alertController, animated: true, completion: nil)
//        }
        
    }
    
    //Button that opens up the camera that will be saved to the Camera Rolls, which we then tap on the upload to firebase button and upload the selected image from the picker controller
    
    
    
    @IBAction func contactButton(_ sender: Any) {
                if (MFMessageComposeViewController.canSendText()) {
                    let controller = MFMessageComposeViewController()
                    controller.body = "Hello Team Vlogr! I have some feedback for your app: "
                    controller.recipients = ["13477920858"]
                    controller.messageComposeDelegate = self
                    self.present(controller, animated: true, completion: nil)
                }
        }

    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        //... handle sms screen actions
        self.dismiss(animated: true, completion: nil)
    }
    
    
    //[END Interface builder methods]
    
    

    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    //[END of low level class methods]

}


extension ViewController: UICollectionViewDelegate {
    // What to do when selecting a cell
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let linkToDownload = videoDownloadLinks[indexPath.row]
        let url = NSURL(string: linkToDownload)
        
        
        let videoPlayer = KBVideoPlayerViewController(urlToPlayMediaFrom: url! as URL)
        present(videoPlayer, animated: true, completion: nil)
        
    }
}


extension ViewController: UICollectionViewDataSource {
    // How many cells to display
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return videoDownloadLinks.count
    }
    
    
    // What to display on each cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellIdentifier", for: indexPath) as! MainCollectionViewCell
//        cell.layer.cornerRadius = 90/2
        cell.layer.borderWidth = 1
        cell.layer.borderColor = UIColor.black.cgColor
        
        let photoURL = URL(string: videoThumbnailLinks[indexPath.row])
        cell.thumbnailImageView.af_setImage(withURL: photoURL!)
        
        return cell
    }
}
