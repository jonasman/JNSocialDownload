//
//  SocialDownload.h
//  
//
//  Created by Joao Nunes on 31/10/14.
//
//

#import <Foundation/Foundation.h>
#import <UIKIt/UIKit.h>


typedef enum{
    JNSocialDownloadNetworkFacebook,
    JNSocialDownloadNetworkTwitter
    
}JNSocialDownloadNetwork;


typedef void(^SocialDownloadImageBlock)(UIImage * image,NSError * error);
typedef void(^SocialDownloadUserInfoBlock)(NSDictionary * userInfo,NSError * error);


const NSInteger JNSocialDownloadNoAPPID;
const NSInteger JNSocialDownloadNoPermissions;
const NSInteger JNSocialDownloadNoAccount;

@interface JNSocialDownload : NSObject

@property (nonatomic) NSString * appID;


- (instancetype)initWithAppID:(NSString *)appid network:(JNSocialDownloadNetwork)network;




- (void)downloadAvatar:(SocialDownloadImageBlock)completion;
- (void)downloadCover:(SocialDownloadImageBlock)completion;
- (void)downloadInformation:(SocialDownloadUserInfoBlock)completion;


@end
