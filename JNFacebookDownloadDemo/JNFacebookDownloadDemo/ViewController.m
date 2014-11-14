//
//  ViewController.m
//  JNFacebookDownloadDemo
//
//  Created by Joao Nunes on 14/11/14.
//  Copyright (c) 2014 joao. All rights reserved.
//

#import "ViewController.h"
#import "JNFacebookDownload.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;



@property (nonatomic) JNFacebookDownload * facebookDownload;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.facebookDownload = [[JNFacebookDownload alloc] initWithAppID:@"380637545425915"];
}


- (IBAction)donwloadBasicInfo:(id)sender {
    
    [self.facebookDownload downloadInformation:^(NSDictionary *userInfo, NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (error)
            {
                if (error.code == JNFacebookDownloadNoAccount)
                    NSLog(@"No account");
                else if (error.code == JNFacebookDownloadNoPermissions)
                    NSLog(@"No permissions");
                else if (error.code == JNFacebookDownloadNoAPPID)
                    NSLog(@"No APP ID Configured");
            }
            else
            {
                self.textView.text = [userInfo description];
            }
        });
        
    }];
}
- (IBAction)downloadAvatar:(id)sender {
    
    [self.facebookDownload downloadAvatar:^(UIImage *image, NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (error)
            {
                if (error.code == JNFacebookDownloadNoAccount)
                    NSLog(@"No account");
                else if (error.code == JNFacebookDownloadNoPermissions)
                    NSLog(@"No permissions");
                else if (error.code == JNFacebookDownloadNoAPPID)
                    NSLog(@"No APP ID Configured");}
            else
            {
                self.imageView.image = image;
            }
            
        });
        
        
    }];
    
}
- (IBAction)downloadCover:(id)sender {
    
    [self.facebookDownload downloadCover:^(UIImage *image, NSError *error) {
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            
            if (error)
            {
                if (error.code == JNFacebookDownloadNoAccount)
                    NSLog(@"No account");
                else if (error.code == JNFacebookDownloadNoPermissions)
                    NSLog(@"No permissions");
                else if (error.code == JNFacebookDownloadNoAPPID)
                    NSLog(@"No APP ID Configured");
            }
            else
            {
                self.imageView.image = image;
            }
            
        });
        
        
    }];
}

@end
