//
//  SocialDownload.h
//  
//
//  Created by Joao Nunes on 31/10/14.
//
//

#import <Foundation/Foundation.h>
#import <UIKIt/UIKit.h>


typedef NS_ENUM(NSInteger, JNSocialDownloadNetwork){
    JNSocialDownloadNetworkFacebook,
    JNSocialDownloadNetworkTwitter
    
};


typedef void(^SocialDownloadImageBlock)(UIImage * image,NSError * error);
typedef void(^SocialDownloadUserInfoBlock)(NSDictionary * userInfo,NSError * error);


const NSInteger JNSocialDownloadNoAPPID;
const NSInteger JNSocialDownloadNoPermissions;
const NSInteger JNSocialDownloadNoAccount;




@interface JNSocialDownload : NSObject

@property (nonatomic) NSString * appID;


- (instancetype)initWithAppID:(NSString *)appid;



- (void)downloadAvatar:(SocialDownloadImageBlock)completion forNetwork:(JNSocialDownloadNetwork)network;
- (void)downloadCover:(SocialDownloadImageBlock)completion forNetwork:(JNSocialDownloadNetwork)network;
- (void)downloadInformation:(SocialDownloadUserInfoBlock)completion forNetwork:(JNSocialDownloadNetwork)network;


@end
