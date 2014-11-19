//
//  ViewController.m
//  JNSocialDownloadDemo
//
//  Created by Joao Nunes on 14/11/14.
//  Copyright (c) 2014 joao. All rights reserved.
//

#import "ViewController.h"
#import "JNSocialDownload.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;



@property (nonatomic) JNSocialDownload * SocialDownload;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.SocialDownload = [[JNSocialDownload alloc] initWithAppID:@"307221439470401" network:JNSocialDownloadNetworkTwitter];
}


- (IBAction)donwloadBasicInfo:(id)sender {
    
    [self.SocialDownload downloadInformation:^(NSDictionary *userInfo, NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (error)
            {
                if (error.code == JNSocialDownloadNoAccount)
                    NSLog(@"No account");
                else if (error.code == JNSocialDownloadNoPermissions)
                    NSLog(@"No permissions");
                else if (error.code == JNSocialDownloadNoAPPID)
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
    
    [self.SocialDownload downloadAvatar:^(UIImage *image, NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (error)
            {
                if (error.code == JNSocialDownloadNoAccount)
                    NSLog(@"No account");
                else if (error.code == JNSocialDownloadNoPermissions)
                    NSLog(@"No permissions");
                else if (error.code == JNSocialDownloadNoAPPID)
                    NSLog(@"No APP ID Configured");}
            else
            {
                self.imageView.image = image;
            }
            
        });
        
        
    }];
    
}
- (IBAction)downloadCover:(id)sender {
    
    [self.SocialDownload downloadCover:^(UIImage *image, NSError *error) {
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            
            if (error)
            {
                if (error.code == JNSocialDownloadNoAccount)
                    NSLog(@"No account");
                else if (error.code == JNSocialDownloadNoPermissions)
                    NSLog(@"No permissions");
                else if (error.code == JNSocialDownloadNoAPPID)
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
