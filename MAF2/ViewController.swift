//
//  ViewController.swift
//  MAF2
//
//  Created by Admin on 9/29/19.
//  Copyright © 2019 Admin. All rights reserved.
//

import UIKit
import DJISDK
import DJIWidget

class ViewController: UIViewController, DJISDKManagerDelegate, DJIVideoFeedListener,DJICameraDelegate {
    
    
    @IBOutlet var recordBtn: UIButton!
    @IBOutlet var changeWorkModeSegmentControl: UISegmentedControl!
    @IBOutlet var fpvPreviewView: UIView!
    
    @IBAction func captureAction(sender: AnyObject) {
    }
    
    
    @IBAction func recordAction(sender: AnyObject) {
    }
    
    
    @IBAction func changeWorkModeAction(sender: AnyObject) {
    }
    
    // the setUpVideoPreviewer
    func setupVideoPreviewer() {
        // variables
        DJIVideoPreviewer.instance().setView(self.fpvPreviewView)
        guard let product:DJIBaseProduct = DJISDKManager.product() else {return}
        
        if (product.model == DJIAircraftModelNameA3 ||
            product.model == DJIAircraftModelNameN3 ||
            product.model == DJIAircraftModelNameMatrice600 ||
            product.model == DJIAircraftModelNameMatrice600Pro) {
            DJISDKManager.videoFeeder()?.secondaryVideoFeed.add(self, with: nil)
        } else {
            DJISDKManager.videoFeeder()?.primaryVideoFeed.add(self, with: nil)
        }
        
        DJIVideoPreviewer.instance().start()
    }
    
    func resetVideoPreview() {
        DJIVideoPreviewer.instance().unSetView()
        guard let product:DJIBaseProduct = DJISDKManager.product() else {return}
        
        if (product.model == DJIAircraftModelNameA3 ||
            product.model == DJIAircraftModelNameN3 ||
            product.model == DJIAircraftModelNameMatrice600 ||
            product.model == DJIAircraftModelNameMatrice600Pro) {
            DJISDKManager.videoFeeder()?.secondaryVideoFeed.remove(self)
        } else {
            DJISDKManager.videoFeeder()?.primaryVideoFeed.remove(self)
        }
        
    }
    
    // function that fetches the camera. Since we know that well be using the mavic pro, 
    // im gonna skip this function for now. in the productDisconnected method, i've hard coded
    // the type.
    func fetchCamera() -> DJICamera? {
        if (DJISDKManager.product() != nil) {
            return nil
        }
        
        // this is omitting the type cast thats in the objective c tutorial. 
        // since both ifs are returning the same thing this shouldn't work
        // but im gonna leave it for now.
        if (DJISDKManager.product()?.isKind(of: DJIAircraft.self))! {
            return (DJISDKManager.product() as? DJIAircraft)?.camera
        
        } else if (DJISDKManager.product()?.isKind(of: DJIHandheld.self))! {
            //let hand:DJIHandheld = DJISDKManager.product()?.camera
            return (DJISDKManager.product() as? DJIHandheld)?.camera
            
        }
        return nil
    }
    
    
    func productConnected(_ product:DJIBaseProduct?) {
        if let product = product {
            product.delegate = self as? DJIBaseProductDelegate;
            
            let camera:DJICamera! = self.fetchCamera()!
            if (camera != nil) {
                camera.delegate = self
            }
            self.setupVideoPreviewer()
        }
    }
    
    func productDisconnected() {
        guard let camera:DJICamera = self.fetchCamera() else {return}
        if let delegate = camera.delegate, delegate === self {
            camera.delegate = nil;
        }
        self.resetVideoPreview()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let camera:DJICamera! = self.fetchCamera()
        if (camera != nil && (camera.delegate?.isEqual(self))!) {
            camera.delegate = nil
        }
        self.resetVideoPreview()
    }
    
    public func videoFeed(_ videoFeed: DJIVideoFeed, didUpdateVideoData videoData: Data) {
        var data2 = videoData
        data2.withUnsafeMutableBytes({ (data: UnsafeMutablePointer<UInt8>) in
            DJIVideoPreviewer.instance().push(data, length: Int32(videoData.count))

        })
    }
    
    
    func camera(_ camera: DJICamera, didUpdate systemState: DJICameraSystemState) {
    }
    
    
    

    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.registerApp()
    }
    

    func registerApp() {
        // let appKey: String =  "8f40318cb61307382126467b"
        DJISDKManager.registerApp(with : self)
    }
    
    public func didUpdateDatabaseDownloadProgress(_ progress: Progress) {
    }
    
    
    public func appRegisteredWithError(_ error: Error?) {
        var message:NSString = "Register App Successed!"
        if (error != nil) {
            message = "Register App Failed! Please enter your App Key and check the network."
        }
        else {
            NSLog("registerAppSuccess")
            DJISDKManager.startConnectionToProduct()
        }
        self.showAlertViewWIthTitle(title: "Register App", withMessage:message)
    }
    
    func showAlertViewWIthTitle(title:NSString, withMessage message:NSString ) {
        let alert:UIAlertController = UIAlertController(title:title as String, message:message as String, preferredStyle:UIAlertControllerStyle.alert)
        let okAction:UIAlertAction = UIAlertAction(title:"Ok", style:UIAlertActionStyle.`default`, handler:nil)
        alert.addAction(okAction)
        self.present(alert, animated:true, completion:nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // CAMERA APP
    


}

