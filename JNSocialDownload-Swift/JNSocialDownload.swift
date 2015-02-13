//
//  JNSocialDownload.swift
//  JNSocialDownloadDemo
//
//  Created by Joao Nunes on 04/02/15.
//  Copyright (c) 2015 joao. All rights reserved.
//

import UIKit
import Accounts
import Social
import Foundation


private enum SocialDownloadType
{
    case Avatar
    case Cover
    case Information
}

enum JNSocialDownloadNetwork
{
    case Facebook
    case Twitter
}

let JNSocialDownloadNoAPPID = 1
let JNSocialDownloadNoPermissions = 2
let JNSocialDownloadNoAccount = 3



typealias SocialDownloadImageClosure = (image : UIImage?, error: NSError?) -> ()
typealias SocialDownloadInformationClosure = (userInfo : NSDictionary?, error: NSError?) -> ()


private class RequestConfiguration
{
    let network:JNSocialDownloadNetwork
    
    let imageClosure:SocialDownloadImageClosure?
    let infoClosure:SocialDownloadInformationClosure?

    
    init(infoClosure:SocialDownloadInformationClosure, network:JNSocialDownloadNetwork)
    {
        self.network = network
        self.infoClosure = infoClosure
    }
    init(imageClosure:SocialDownloadImageClosure, network:JNSocialDownloadNetwork)
    {
        self.network = network
        self.imageClosure = imageClosure
    }
}


class JNSocialDownload: NSObject {
   
    
    var appID:NSString?

    lazy var accountStore: ACAccountStore =
    {
        var tempAccountStore: ACAccountStore = ACAccountStore()
        
        return tempAccountStore
    }()
    

    convenience init(appID:NSString)
    {
        self.init()
        self.appID = appID
    }
    
    
    
    func downloadInformation(completionHandler: SocialDownloadInformationClosure, network:JNSocialDownloadNetwork) -> Void
    {
        let request = RequestConfiguration(infoClosure: completionHandler,network: network)
        
        self.selectSocialIOS(.Information, request: request)
    }
    func downloadAvatar(completionHandler: SocialDownloadImageClosure, network:JNSocialDownloadNetwork) -> Void
    {
        let request = RequestConfiguration(imageClosure: completionHandler,network: network)
        
        self.selectSocialIOS(.Avatar, request: request)
    }
    
    func downloadCover(completionHandler: SocialDownloadImageClosure, network:JNSocialDownloadNetwork) -> Void
    {
        let request = RequestConfiguration(imageClosure: completionHandler,network: network)
        
        self.selectSocialIOS(.Cover, request: request)
    }
    
}

// MARK: Logic
extension JNSocialDownload
{
    
    private func selectSocialIOS(downloadType: SocialDownloadType, request:RequestConfiguration)
    {
     
        var socialAPPID :NSString?
        
        if let appID = self.appID {
            socialAPPID = appID
        }
        else
        {
            socialAPPID = NSBundle.mainBundle().objectForInfoDictionaryKey("SocialAppID") as NSString?
        }
        
        
        if (socialAPPID == nil)
        {
            
            if (downloadType == .Avatar ||
                downloadType == .Cover)
            {
                
                
                if let closure = request.imageClosure
                {
                    closure(image: nil, error: NSError(
                        domain: "JNSocialDownload",
                        code: JNSocialDownloadNoAPPID,
                        userInfo: [NSLocalizedDescriptionKey:"No app ID configured"]))
                }
                
                
            }
            else if (downloadType == .Information)
            {
                if let closure = request.infoClosure
                {
                    closure(userInfo: nil, error: NSError(
                        domain: "JNSocialDownload",
                        code: JNSocialDownloadNoAPPID,
                        userInfo: [NSLocalizedDescriptionKey:"No app ID configured"]))
                }
            }
            
            return
        }
        
        var accountType :ACAccountType!
        var socialOptions:Dictionary<String,AnyObject>? = nil
        
        if (request.network == .Facebook)
        {
            accountType = self.accountStore.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierFacebook)
            socialOptions = [ACFacebookAppIdKey:socialAPPID!,
                ACFacebookPermissionsKey:["user_birthday"]]
        }
        else if (request.network == .Twitter)
        {
            accountType = self.accountStore.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)
        }
        
        
        
        self.accountStore .requestAccessToAccountsWithType(accountType, options: socialOptions, completion: { (granted, error) -> Void in
            
            if (error != nil)
            {
                
                
                if (downloadType == .Avatar ||
                    downloadType == .Cover)
                {
                    
                    
                    if let closure = request.imageClosure
                    {
                        closure(image: nil, error: NSError(
                            domain: "JNSocialDownload",
                            code: JNSocialDownloadNoAccount,
                            userInfo: [NSLocalizedDescriptionKey:"No Social Account configured"]))
                    }
                    
                    
                }
                else if (downloadType == .Information)
                {
                    if let closure = request.infoClosure
                    {
                        closure(userInfo: nil, error: NSError(
                            domain: "JNSocialDownload",
                            code: JNSocialDownloadNoAccount,
                            userInfo: [NSLocalizedDescriptionKey:"No Social Account configured"]))
                    }
                }
                
                
                return
            }
            
            
            if (granted)
            {
                self.requestMe(downloadType, request: request)
            }
            else
                
            {
                if (downloadType == .Avatar ||
                    downloadType == .Cover)
                {
                    
                    
                    if let closure = request.imageClosure
                    {
                        closure(image: nil, error: NSError(
                            domain: "JNSocialDownload",
                            code: JNSocialDownloadNoPermissions,
                            userInfo: [NSLocalizedDescriptionKey:"Social permission not granted"]))
                    }
                    
                    
                }
                else if (downloadType == .Information)
                {
                    if let closure = request.infoClosure
                    {
                        closure(userInfo: nil, error: NSError(
                            domain: "JNSocialDownload",
                            code: JNSocialDownloadNoPermissions,
                            userInfo: [NSLocalizedDescriptionKey:"Social permission not granted"]))
                    }
                }
                
            }
            
            
        })
        

       
    }
    
    
    
    private func requestMe(downloadType: SocialDownloadType, request:RequestConfiguration)
    {
        
        
        let merequest = self.requestFor(
            request.network,
            dataType: .Information,
            userData: nil)
        
        
        merequest?.performRequestWithHandler( { [weak self,request] (responseData, urlResponse, error) -> Void in
            
            let userData = NSJSONSerialization.JSONObjectWithData(responseData!, options: NSJSONReadingOptions.allZeros, error: nil) as Dictionary<String,AnyObject>
            
            if (downloadType == .Avatar)
            {
                self?.requestAvatarFrom(userData, request: request)
            }
            else if (downloadType == .Cover)
            {
                self?.requestCoverFrom(userData, request: request)
            }
            else if (downloadType == .Information)
            {
                let closure = request.infoClosure!
                
                closure(userInfo: userData , error: nil)
                
            }
            
        })
        
        
        
    }
    
    
    private func requestAvatarFrom(userData:Dictionary<String,AnyObject>, request:RequestConfiguration)
    {
        
        let avatarRequest = self.requestFor(
            request.network,
            dataType: .Avatar,
            userData: userData)

        // (NSData!, NSHTTPURLResponse!, NSError!) -> Void
        avatarRequest?.performRequestWithHandler( { (responseData: NSData!, urlResponse:NSHTTPURLResponse!, error:NSError!) -> Void in
            
            self.processImage(responseData, request: request)
            
        })
        
    }
    private func requestCoverFrom(userData:Dictionary<String,AnyObject>, request:RequestConfiguration)
    {
        let coverRequest = self.requestFor(
            request.network,
            dataType: .Cover,
            userData: userData)
        
        
        coverRequest?.performRequestWithHandler( {( responseData, urlResponse, error) -> Void in
            
            if (request.network == .Facebook)
            {
                let response = NSJSONSerialization.JSONObjectWithData(responseData, options: NSJSONReadingOptions.allZeros, error: nil) as Dictionary<String,AnyObject>?
                
                let anyError = false
                
                if (response != nil)
                {
                    let cover = response!["cover"] as Dictionary<String,AnyObject>?
                    if (cover != nil)
                    {
                        
                        let url = cover!["source"] as String
                        
                        let request3 = SLRequest(forServiceType: SLServiceTypeFacebook, requestMethod: .GET, URL: NSURL(string: url), parameters: nil)
                        
                        
                        request3.performRequestWithHandler( {(responseData, urlResponse, error) -> Void in
                            
                            self.processImage(responseData, request: request)
                            
                        })

                        
                    }
                }
                
                
            }
            else if (request.network == .Twitter)
            {
                self.processImage(responseData, request: request)
            }
            
        })
        
    }
    
    
    
    private func processImage(data:NSData, request:RequestConfiguration)
    {
        if (data.length > 100)
        {
            let image = UIImage(data: data)
            
            let closure = request.imageClosure!
            
            closure(image: image,error: nil)
        }
    }
    
   // MARK: Request preparation
    private func requestFor(
        network: JNSocialDownloadNetwork,
        dataType:SocialDownloadType,
        userData:Dictionary<String,AnyObject>?) -> SLRequest?
    {
        if (network == .Facebook)
        {
            var request:SLRequest?
            
            if (dataType == .Information)
            {
                let meurl = NSURL(string: "https://graph.facebook.com/me")
                
                request = SLRequest(
                    forServiceType: SLServiceTypeFacebook,
                    requestMethod: .GET,
                    URL: meurl,
                    parameters: nil)
                
            }
            else if (dataType == .Avatar)
            {
                let socialID = userData!["id"] as String
                let imageURL = "https://graph.facebook.com/v2.1/\(socialID)/picture"
                
                request = SLRequest(
                    forServiceType: SLServiceTypeFacebook,
                    requestMethod: .GET,
                    URL: NSURL(string: imageURL),
                    parameters: ["height":"512","width":"512"])
                
            }
            else if (dataType == .Cover)
            {
                let socialID = userData!["id"] as String
                let coverURL = "https://graph.facebook.com/v2.1/\(socialID)"
                
                request = SLRequest(
                    forServiceType: SLServiceTypeFacebook,
                    requestMethod: .GET,
                    URL: NSURL(string: coverURL),
                    parameters: ["fields":"cover"])
            }
            
            let accountType = self.accountStore.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierFacebook)
            let account = self.accountStore.accountsWithAccountType(accountType).last! as ACAccount
            
            if (request != nil){
                request!.account = account
            }
            
            return request
            
        }
        else if (network == .Twitter)
        {
            
            var request:SLRequest?
            
            if (dataType == .Information)
            {
                let meurl = NSURL(string: "https://api.twitter.com/1.1/account/verify_credentials.json")
                
                request = SLRequest(
                    forServiceType: SLServiceTypeTwitter,
                    requestMethod: .GET,
                    URL: meurl,
                    parameters: nil)
                
            }
            else if (dataType == .Avatar)
            {
                let imageURL = userData!["profile_image_url"] as String
                
                request = SLRequest(
                    forServiceType: SLServiceTypeTwitter,
                    requestMethod: .GET,
                    URL: NSURL(string: imageURL),
                    parameters: nil)
                
            }
            else if (dataType == .Cover)
            {
                let imageURL = userData!["profile_background_image_url"] as String
                
                request = SLRequest(
                    forServiceType: SLServiceTypeTwitter,
                    requestMethod: .GET,
                    URL: NSURL(string: imageURL),
                    parameters: nil)
            }
            
            let accountType = self.accountStore.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)
            let account = self.accountStore.accountsWithAccountType(accountType).last! as ACAccount
            
            if (request != nil){
                request!.account = account
            }
            
            return request

        }
        
        return nil
        
    }
    

}
