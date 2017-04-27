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
import Photos


class ViewController: UIViewController, MFMessageComposeViewControllerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    //[START - Properties]
    // Top information section
    
    
    
    // Bottom CollectionView section
    @IBOutlet weak var collectionView: UICollectionView!
    
    var videoDownloadLinks = [String]()
    var newItems = false
    
    
    var avPlayerViewController = AVPlayerViewController()
    var avPlayer: AVPlayer?
    
    
    @IBOutlet weak var bannerOutlet: UIView!
    
    
    var activityIndicator: UIActivityIndicatorView!
    
    var numberOfCells = [Int]()
    
    //[END - Properties]
    
    
    //[START Methods]
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
 //         Retrive data from FirebaseDatabase
            let databaseReference = FIRDatabase.database().reference().child("videos")
        
        
            databaseReference.observe(.childAdded, with: { (snapshot) in
            
            let postDict = snapshot.value as? [String : AnyObject] ?? [:]
            
            print(postDict)
            
            let videoDownloadURL = postDict["videodownloadlink"]!
            
            
            
            
            
            for index in postDict {
                print(index)
                print("------------------------")
                
                
            }
            
            
            
            self.videoDownloadLinks.insert(videoDownloadURL as! String, at: 0)
            
            self.numberOfCells.insert(self.videoDownloadLinks.count, at: 0)
                
            self.collectionView.reloadData()
                
            
                
            print(self.videoDownloadLinks.count)
            
            
            
            
            // activity indicator 
            self.activityIndicator = UIActivityIndicatorView()
            self.activityIndicator.center = self.view.center
            self.view.addSubview(self.activityIndicator)
            
            
        })
        
        
        
        
        
        
 
        
        
    }

    
    
    
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
    
    

    
   
    //[END of low level class methods]

}


extension ViewController: UICollectionViewDelegate {
    // What to do when selecting a cell
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let linkToDownload = videoDownloadLinks[indexPath.row]
        let url = NSURL(string: linkToDownload)
        
        
        self.avPlayer = AVPlayer(url: (url as URL?)!)
        self.avPlayerViewController.player = self.avPlayer
        self.present(avPlayerViewController, animated: true, completion: {
            self.avPlayerViewController.player?.play()
        })
        
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

         
        // Cell's layer
        cell.layer.cornerRadius = 10
        //Shadows
        cell.layer.shadowColor = UIColor.black.cgColor
        cell.layer.shadowOpacity = 0.7
        cell.layer.shadowOffset = CGSize.zero
        cell.layer.shadowRadius = 5
//        cell.layer.cornerRadius = 90/2
        
   
        
        
        cell.downloadButton.addTarget(self, action: #selector(downloadButtonTapped(sender:)), for: .touchUpInside)
        
        
        cell.linkLabel.text = String(describing: numberOfCells[indexPath.row])
        
        cell.linkDownloadLabel.text = videoDownloadLinks[indexPath.row]
        
        
        
        
     
        return cell
    }
    
    
   
    func downloadButtonTapped(sender: AnyObject){
       
        let alertController = UIAlertController(title: "Save Video to Camera Roll? 📱", message: "Press yes to download, cancel to quit.", preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Yes! ✅", style: .default, handler: { action in
            
            self.activityIndicator.startAnimating()
            
            
            // the method was runned from a uibutton
            if let button = sender as? UIButton {
                // the uibutton has a superview, which is
                if let superView = button.superview {
                    if let cell = superView.superview as? MainCollectionViewCell {
                        
                        let downloadLinkString = cell.linkDownloadLabel.text!
                        print("This is the url: ", downloadLinkString)
                        
                        
                        DispatchQueue.global(qos: .background).async {
                            
                            
                            
                            if let url = URL(string: downloadLinkString), let dataInURL = NSData(contentsOf: url) {
                                let documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
                                let filePath = URL(string: "\(documentPath)/tempFile.mp4")
                                
                                
                                
                                DispatchQueue.main.async {
                                    dataInURL.write(to: filePath!, atomically: true)
                                    
                                    
                                    
                                    
                                    PHPhotoLibrary.shared().performChanges({ PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: filePath!)
                                    }, completionHandler: { (completed, error) in
                                        if completed {
                                            print("The video was saved")
                                            
                                            
//
                                            
                                            
                                            DispatchQueue.main.async { [unowned self] in
                                                
                                                self.activityIndicator.stopAnimating()
                                                
                                                let alertController = UIAlertController(title: "Saved ✅", message: "The video was saved! ", preferredStyle: .alert)
                                                
                                                let awesomeAction = UIAlertAction(title: "Awesome 😀", style: .default, handler: nil)
                                                
                                                alertController.addAction(awesomeAction)
                                                self.present(alertController, animated: true, completion: nil)
                                                
                                                
                                            }
                                            
                                            
                                            
                                           
                                            
                                            
                                        } else {
                                            print("The video was not saved")
                                        }
                                        
                                        
                                        
                                        
                                    })
                                    
                                }
                                
                                
                                
                                
                                
                            }
                        }
                        
                        
                        
                        
                    }
                    
                }
            }
            
            
            
            })
            
        let cancelAction = UIAlertAction(title: "No 🛑", style: .cancel, handler: { action in
            print("Cancel pressed")
        })
        
        
        alertController.addAction(cancelAction)
        alertController.addAction(yesAction)
        self.present(alertController, animated: true, completion: nil)

        
       
        }
        

        
    }
    

