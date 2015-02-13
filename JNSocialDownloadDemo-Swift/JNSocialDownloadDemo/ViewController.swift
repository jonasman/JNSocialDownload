//
//  ViewController.swift
//  JNSocialDownloadDemo
//
//  Created by Joao Nunes on 04/02/15.
//  Copyright (c) 2015 joao. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    /* UI outlets */
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var socialNetwork: UISegmentedControl!
    
    /* iVars */
    
    var socialDownload: JNSocialDownload = JNSocialDownload()
    
    
    /* Logic */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.socialDownload.appID = "380637545425915"
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    
    

    @IBAction func downloadBasicInfo(sender: UIButton) {
        
        var network = JNSocialDownloadNetwork.Facebook
        
        if (self.socialNetwork.selectedSegmentIndex == 1)
        {
            network = .Twitter
        }
        
        
        self.socialDownload.downloadInformation({ (userInfo, error) -> () in
            
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                if let error_ = error
                {
                    if (error_.code == JNSocialDownloadNoAccount)
                    {
                        NSLog("No account")
                    }
                    else if (error_.code == JNSocialDownloadNoPermissions)
                    {
                        NSLog("No permissions")
                    }
                    else if (error_.code == JNSocialDownloadNoAPPID)
                    {
                        NSLog("No APP ID Configured")
                    }
                }
                else
                {
                    self.textView.text = userInfo?.description
                }
                
            })
            
            }, network: network)
        
        
        
    }
    @IBAction func downloadAvatar(sender: UIButton) {
        var network = JNSocialDownloadNetwork.Facebook
        
        if (self.socialNetwork.selectedSegmentIndex == 1)
        {
            network = .Twitter
        }
        
        self.socialDownload.downloadAvatar({ (image, error) -> () in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                if let error_ = error
                {
                    if (error_.code == JNSocialDownloadNoAccount)
                    {
                        NSLog("No account")
                    }
                    else if (error_.code == JNSocialDownloadNoPermissions)
                    {
                        NSLog("No permissions")
                    }
                    else if (error_.code == JNSocialDownloadNoAPPID)
                    {
                        NSLog("No APP ID Configured")
                    }
                }
                else
                {
                    self.imageView.image = image
                }
                
            })

        }, network: network)
        
    }
    @IBAction func downloadCover(sender: UIButton) {
        
        var network = JNSocialDownloadNetwork.Facebook
        
        if (self.socialNetwork.selectedSegmentIndex == 1)
        {
            network = .Twitter
        }
        
        self.socialDownload.downloadCover({ (image, error) -> () in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                if let error_ = error
                {
                    if (error_.code == JNSocialDownloadNoAccount)
                    {
                        NSLog("No account")
                    }
                    else if (error_.code == JNSocialDownloadNoPermissions)
                    {
                        NSLog("No permissions")
                    }
                    else if (error_.code == JNSocialDownloadNoAPPID)
                    {
                        NSLog("No APP ID Configured")
                    }
                }
                else
                {
                    self.imageView.image = image
                }
                
            })
            
            }, network: network)
    }
}

