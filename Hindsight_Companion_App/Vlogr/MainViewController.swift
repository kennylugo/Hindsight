//
//  ViewController.swift
//  VideoCamera
//
//  Created by Kenny Batista on 2/10/17.
//  Copyright © 2017 kennybatista. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import Firebase
import MobileCoreServices
import FirebaseStorage
import FirebaseDatabase



class MainViewController: UIViewController, AVCaptureFileOutputRecordingDelegate {

    @IBOutlet weak var screenView: UIView!
    
    @IBOutlet weak var cameraButton: UIButton!
    
     @IBOutlet weak var switchCamOutlet: UIButton!
    
    
    // Start/stop recording. use the preset to change output quality
    let captureSession = AVCaptureSession()
    
    // find the camera devices
    var currentDevice: AVCaptureDevice?
    
    
    var videoFileOutput: AVCaptureMovieFileOutput?
    
    var cameraPreviewLayer: AVCaptureVideoPreviewLayer?
    
    var isRecording = false
    
    // Set up AVPlayer
    fileprivate var videoURL: URL!
    
    
    @IBOutlet weak var flashButtonOutlet: UIButton!
    @IBAction func flash(_ sender: Any) {
        let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        if (device?.hasTorch)! {
            do {
                try device?.lockForConfiguration()
                if device?.torchMode == AVCaptureTorchMode.on {
                    device?.torchMode = AVCaptureTorchMode.off
                } else {
                    do {
                        try device?.setTorchModeOnWithLevel(1.0)
                    } catch {
                        print(error)
                    }
                }
                device?.unlockForConfiguration()
            } catch {
                print(error)
            }
        }
    }
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setUpVideoPreview()
//        cameraButton.layer.cornerRadius = 10
        
        
                
    }
    
    
    
    
    func setUpVideoPreview(){
        // Do any additional setup after loading the view, typically from a nib.
        captureSession.sessionPreset = AVCaptureSessionPresetHigh
        
        // get default camera
        
        if #available(iOS 10.2, *) {
            if let device: AVCaptureDevice = AVCaptureDevice.defaultDevice(withDeviceType: .builtInWideAngleCamera, mediaType: AVMediaTypeVideo, position: .front) {
                currentDevice = device
            } else if let device = AVCaptureDevice.defaultDevice(withDeviceType: .builtInDualCamera, mediaType: AVMediaTypeVideo, position: .front) {
                currentDevice = device
            }
        } else {
            // Fallback on earlier versions
        }
        
        
        // get input data source
        guard let captureDeviceInput = try? AVCaptureDeviceInput(device: currentDevice)
            else {
                return
        }
        
        //[]
        
        
        videoFileOutput = AVCaptureMovieFileOutput()
        
        // now that we've set up the input and the output,  will flow the data from pointA to pointB
        captureSession.addInput(captureDeviceInput)
        captureSession.addOutput(videoFileOutput)
        
        //configure the session with the output for capture video - we can also use the output to record how long we want the video to be
        
        //[]
        
        //provide a camera preview
        cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        view.layer.addSublayer(cameraPreviewLayer!)
        cameraPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspect
        cameraPreviewLayer?.frame = screenView.layer.bounds
        
        //Bring the camera button to front
        view.bringSubview(toFront: cameraButton)
        view.bringSubview(toFront: switchCamOutlet)
        view.bringSubview(toFront: flashButtonOutlet)
        
        
        captureSession.startRunning()
        
        
        captureSession.beginConfiguration()
        
        // Add audio device to the recording
        let audioDevice: AVCaptureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeAudio)
        do {
            let audioInput: AVCaptureDeviceInput = try AVCaptureDeviceInput(device: audioDevice)
            self.captureSession.addInput(audioInput)
            
        } catch {
            print("Unable to add audio device to the recording.")
        }
        
        captureSession.commitConfiguration()
        
        
        
        
        
        // Set up swipe to dismiss gesture
        let swipeToDismiss = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(sender:)))
        swipeToDismiss.direction = [.down, .up]
        self.view.addGestureRecognizer(swipeToDismiss)
        
    }
    
    
    // Swipe to dismiss
    func handleSwipe(sender: UISwipeGestureRecognizer) {
        print(sender.direction)
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    
    func cameraWith(position: AVCaptureDevicePosition) -> AVCaptureDevice! {
        if #available(iOS 10.2, *) {
            let discovery = AVCaptureDeviceDiscoverySession(deviceTypes: [AVCaptureDeviceType.builtInWideAngleCamera, AVCaptureDeviceType.builtInDualCamera], mediaType: AVMediaTypeVideo, position: .unspecified) as AVCaptureDeviceDiscoverySession
            
            
            for device in discovery.devices as [AVCaptureDevice] {
                if device.position == position {
                    return device
                }
            }
            
        } else {
            // Fallback on earlier versions
        }
        
        
        
        return nil
    }
    
    
    
    
    
    
    func toggleCameraInput() {
        self.captureSession.beginConfiguration()
        
        var existingConnection: AVCaptureDeviceInput!
        
        for connection in self.captureSession.inputs {
            let input = connection as! AVCaptureDeviceInput
            
            if input.device.hasMediaType(AVMediaTypeVideo) {
                existingConnection = input
            }
        }
        
        
        self.captureSession.removeInput(existingConnection)
        
        
        var newCamera: AVCaptureDevice!
        
        if let oldCamera = existingConnection {
            if oldCamera.device.position == .front {
                newCamera = self.cameraWith(position: .back)
            } else {
                newCamera = self.cameraWith(position: .front)
            }
        }
        
        do {
            let newInput = try AVCaptureDeviceInput(device: newCamera)
            self.captureSession.addInput(newInput)
        } catch {
            print(error)
        }
        
        self.captureSession.commitConfiguration()
        
        
        
        
    }
    
    
    
    @IBAction func capture(_ sender: Any) {
        
        
        
        
        if !isRecording {
            isRecording = true
            
            // disable camera outlet
            switchCamOutlet.isEnabled = false
            flashButtonOutlet.isEnabled = false
            
           
            
            let outputPath = NSTemporaryDirectory() + "output.mov"
            let outputFileURL = URL(fileURLWithPath: outputPath)
            videoFileOutput?.startRecording(toOutputFileURL: outputFileURL, recordingDelegate: self)
        } else {
            // enable toggle camera
            switchCamOutlet.isEnabled = true
            flashButtonOutlet.isEnabled = true
            
            isRecording = false
            
            videoFileOutput?.stopRecording()
            
            
        }
    }
   
    func capture(_ captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAt fileURL: URL!, fromConnections connections: [Any]!, error: Error!) {
        
        // Dismiss view when capturing is finished
        self.dismiss(animated: true, completion: nil)
        
        
        if error != nil {
            print(error)
            return
        } else {
            
            let currentDateTime = NSDate()
            
            let videoStorageReference = FIRStorage.storage().reference().child("Videos/\(currentDateTime).MOV")
            //[Start of: Upload to Firebase storage]
            videoStorageReference.putFile(fileURL, metadata: nil, completion: { (videoMeta, error) in
                //[Start of: Check for errors]
                if error != nil {
                    print("Here is the localized error: \(String(describing: error?.localizedDescription))")
                }
                    //[End of: check for errors]
                    
                    //[Start of: Successful Video Upload, now let's play with the metadata]
                else {
                    print("Video upload was successful")
                    
                    //Upload thumbnail to firebase storage
                    let asset = AVAsset(url: fileURL as URL)
                    let imageGenerator = AVAssetImageGenerator(asset: asset)
                    imageGenerator.appliesPreferredTrackTransform = true
                    
                    var time = asset.duration
                    //If possible - take not the first frame (it could be completely black or white on camara's videos)
                    time.value = min(time.value, 3)
                    
                    do {
                        let imageRef = try imageGenerator.copyCGImage(at: time, actualTime: nil)
                        let image = UIImage(cgImage: imageRef)
                        let imageData = UIImagePNGRepresentation(image)!
                        
                        let thumbnailStorageReference = FIRStorage.storage().reference().child("Thumbnails/\(currentDateTime).png")
                        
                        thumbnailStorageReference.put(imageData, metadata: nil, completion: { (thumbnailMeta, error) in
                            if error != nil {
                                print("Error")
                            } else {
                                //thumbnail upload was succssful
                                
                                //Upload thumbanil and video to database
                                let databaseReference = FIRDatabase.database().reference()
                                //                                let downloadURL = thumbnailMeta!.downloadURL()!.absoluteString
                                databaseReference.child("/videos").childByAutoId().setValue(["videodownloadlink": "\(videoMeta!.downloadURL()!.absoluteString)","thumbnail":"\(thumbnailMeta!.downloadURL()!.absoluteString)"])
                                print("Upload to Database Successful")
                            }
                        })
                        
                        //Alert the user that the video was uploaded successfuly
                        let alert = UIAlertController(title: "Success!", message: "Video upload was successful", preferredStyle: .alert)
                        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alert.addAction(action)
                        self.present(alert, animated: true, completion: nil)
                        
                    } catch {
                        print("Error")
                    }
                    
                    
                    
                    
                    
                    
                    
                    // When finished recording, pass the file url to our modular video component and play it
                    let videoPlayer = KBVideoPlayerViewController(urlToPlayMediaFrom: fileURL!)
                    
                    
                    self.present(videoPlayer, animated: true, completion: nil)
                    
                    
                }
            })
        }
    }
    
    

    // Toggle camera
    @IBAction func switchCam(_ sender: Any) {
        print(#function)
        toggleCameraInput()
    }
    
    
   
}
