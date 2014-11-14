//
//  FacebookDownload.h
//  
//
//  Created by Joao Nunes on 31/10/14.
//
//

#import <Foundation/Foundation.h>
#import <UIKIt/UIKit.h>

typedef void(^FacebookDownloadImageBlock)(UIImage * image,NSError * error);
typedef void(^FacebookDownloadUserInfoBlock)(NSDictionary * userInfo,NSError * error);


NSInteger JNFacebookDownloadNoAPPID;
NSInteger JNFacebookDownloadNoPermissions;
NSInteger JNFacebookDownloadNoAccount;

@interface JNFacebookDownload : NSObject

@property (nonatomic) NSString * appID;

- (void)downloadAvatar:(FacebookDownloadImageBlock)completion;
- (void)downloadCover:(FacebookDownloadImageBlock)completion;
- (void)downloadInformation:(FacebookDownloadUserInfoBlock)completion;


@end
