//
//  FacebookDownload.m
//
//
//  Created by Joao Nunes on 31/10/14.
//
//

#import "JNFacebookDownload.h"

@import Social;
@import Accounts;

typedef NS_ENUM(NSInteger, FacebookDownloadType) {
    FacebookDownloadTypeAvatar = 0,
    FacebookDownloadTypeCover,
    FacebookDownloadTypeInformation
};


const NSInteger JNFacebookDownloadNoAPPID = 1;
const NSInteger JNFacebookDownloadNoPermissions = 2;
const NSInteger JNFacebookDownloadNoAccount = 3;

static NSString * const JNimageCompletion = @"JNimageCompletion";
static NSString * const JNinfoCompletion = @"JNinfoCompletion";



@interface JNFacebookDownload ()

@property (nonatomic) ACAccountStore * fbStore;

@property (nonatomic) NSMutableDictionary * requests;
@property (nonatomic) NSInteger lastRequestID;



@end


@implementation JNFacebookDownload


- (instancetype)init
{
    self = [super init];
    if (self) {
        _requests = [NSMutableDictionary new];
        _lastRequestID = 0;
    }
    return self;
}

- (instancetype)initWithAppID:(NSString *)appid
{
    self = [self init];
    if (self) {
        _appID = appid;
    }
    return self;
}

- (ACAccountStore *)fbStore
{
    if (!_fbStore)
        _fbStore = [[ACAccountStore alloc]init];
    
    return _fbStore;
}


#pragma mark Public API

- (void)downloadAvatar:(FacebookDownloadImageBlock)completion
{
    
    NSNumber * requestID = @(self.lastRequestID++);
    
    self.requests[requestID] =
    @{
      JNimageCompletion:(completion?completion:(^(UIImage *image, NSError *error) {}))
      };
    
    
    [self selectFacebookIOS:FacebookDownloadTypeAvatar requestID:requestID];
}
- (void)downloadCover:(FacebookDownloadImageBlock)completion
{
    NSNumber * requestID = @(self.lastRequestID++);
    
    self.requests[requestID] =
    @{
      JNimageCompletion:(completion?completion:(^(UIImage *image, NSError *error) {}))
      };
    
    [self selectFacebookIOS:FacebookDownloadTypeCover requestID:requestID];
}
- (void)downloadInformation:(FacebookDownloadUserInfoBlock)completion
{
    NSNumber * requestID = @(self.lastRequestID++);
    
    self.requests[requestID] =
    @{
      JNinfoCompletion:(completion?completion:(^(NSDictionary *userInfo, NSError *error) {}))
      };
    
    [self selectFacebookIOS:FacebookDownloadTypeInformation requestID:requestID];
}




#pragma mark Facebook Logic

- (void)selectFacebookIOS:(FacebookDownloadType)downloadType requestID:(NSNumber *)requestID
{
    // Facebook Logic:
    
    // Get ME
    // Get picture with my userID
    
    NSString * facebookAPPID;
    
    if (self.appID)
        facebookAPPID = self.appID;
    else
        facebookAPPID = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"FacebookAppID"];
    
    if (!facebookAPPID)
    {
        if (downloadType == FacebookDownloadTypeAvatar ||
            downloadType == FacebookDownloadTypeCover){
            
            FacebookDownloadImageBlock block = self.requests[requestID][JNimageCompletion];
            
            block(nil,[NSError errorWithDomain:@"JNFacebookDownload" code:JNFacebookDownloadNoAPPID userInfo:@{NSLocalizedDescriptionKey:@"No app ID configured"}]);
            
        }
        else if (downloadType == FacebookDownloadTypeInformation)
        {
            FacebookDownloadUserInfoBlock block = self.requests[requestID][JNinfoCompletion];
            
            block(nil,[NSError errorWithDomain:@"JNFacebookDownload" code:JNFacebookDownloadNoAPPID userInfo:@{NSLocalizedDescriptionKey:@"No app ID configured"}]);
        }
        
        return;
    }
    
    
    ACAccountType * accountType = [self.fbStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
    
    
    
    NSDictionary * facebookOptions = @{ACFacebookAppIdKey:facebookAPPID,
                                       ACFacebookPermissionsKey:@[@"user_birthday"]};
    
    
    
    
    [self.fbStore requestAccessToAccountsWithType:accountType options:facebookOptions completion:^(BOOL granted, NSError *error) {
        
        if (error){
            
         
            if (downloadType == FacebookDownloadTypeAvatar ||
                downloadType == FacebookDownloadTypeCover){
                
                FacebookDownloadImageBlock block = self.requests[requestID][JNimageCompletion];
                
                block(nil,[NSError errorWithDomain:@"JNFacebookDownload" code:JNFacebookDownloadNoAccount userInfo:@{NSLocalizedDescriptionKey:@"No Facebook Account configured"}]);
                
            }
            else if (downloadType == FacebookDownloadTypeInformation)
            {
                FacebookDownloadUserInfoBlock block = self.requests[requestID][JNinfoCompletion];
                
                block(nil,[NSError errorWithDomain:@"JNFacebookDownload" code:JNFacebookDownloadNoAccount userInfo:@{NSLocalizedDescriptionKey:@"No Facebook Account configured"}]);
            }
            
                
            return ;
        }
        
        if (granted)
        {
            
            [self requestMe:downloadType requestID:requestID];
            
        }
        else
        {
            
            if (downloadType == FacebookDownloadTypeAvatar ||
                downloadType == FacebookDownloadTypeCover){
                
                FacebookDownloadImageBlock block = self.requests[requestID][JNimageCompletion];
                
                block(nil,[NSError errorWithDomain:@"JNFacebookDownload" code:JNFacebookDownloadNoPermissions userInfo:@{NSLocalizedDescriptionKey:@"Facebook permission not granted"}]);
                
            }
            else if (downloadType == FacebookDownloadTypeInformation)
            {
                FacebookDownloadUserInfoBlock block = self.requests[requestID][JNinfoCompletion];
                
                block(nil,[NSError errorWithDomain:@"JNFacebookDownload" code:JNFacebookDownloadNoPermissions userInfo:@{NSLocalizedDescriptionKey:@"Facebook permission not granted"}]);
            }
            
        }
        
 
 }];
 
 }

- (void)requestMe:(FacebookDownloadType)downloadType requestID:(NSNumber *)requestID
{
    ACAccountType * accountType = [self.fbStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
    ACAccount * account = [[self.fbStore accountsWithAccountType:accountType] lastObject];
    
    NSURL *meurl = [NSURL URLWithString:@"https://graph.facebook.com/me"];
    
    SLRequest *merequest = [SLRequest requestForServiceType:SLServiceTypeFacebook
                                              requestMethod:SLRequestMethodGET
                                                        URL:meurl
                                                 parameters:nil];
    
    merequest.account = account;
    
    [merequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        
        
        if (!error){
            NSDictionary * userData = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil];
            
            NSString * facebookID = userData[@"id"];
            
            
            if (downloadType == FacebookDownloadTypeAvatar)
            {
                [self requestAvatarFromUser:facebookID requestID:requestID];
            }
            else if (downloadType == FacebookDownloadTypeCover)
            {
                [self requestCoverFromUser:facebookID requestID:requestID];
            }
            else if (downloadType == FacebookDownloadTypeInformation)
            {
                FacebookDownloadUserInfoBlock block = self.requests[requestID][JNinfoCompletion];
                
                block(userData,nil);
            }
            
            
            
        }
        
    }];

}

- (void)requestAvatarFromUser:(NSString *)facebookID requestID:(NSNumber *)requestID
{
    NSString * imageURL = [NSString stringWithFormat:@"https://graph.facebook.com/v2.1/%@/picture",facebookID];
    
    
    SLRequest * request =
    [SLRequest requestForServiceType:SLServiceTypeFacebook
                       requestMethod:SLRequestMethodGET
                                 URL:[NSURL URLWithString:imageURL]
                          parameters:@{@"height":@"512",
                                       @"width":@"512"}];
    
    ACAccountType * accountType = [self.fbStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
    request.account = [[self.fbStore accountsWithAccountType:accountType] lastObject];
    
    
    [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        
        
        if (responseData.length > 100)
        {
            UIImage * image = [UIImage imageWithData:responseData];
            
            FacebookDownloadImageBlock block = self.requests[requestID][JNimageCompletion];
            
            block(image,nil);
        }
        
    }];
}


- (void)requestCoverFromUser:(NSString *)facebookID requestID:(NSNumber *)requestID
{
    NSString * coverURL = [NSString stringWithFormat:@"https://graph.facebook.com/v2.1/%@",facebookID];
    
    
    
    SLRequest * request =
    [SLRequest requestForServiceType:SLServiceTypeFacebook
                       requestMethod:SLRequestMethodGET
                                 URL:[NSURL URLWithString:coverURL]
                          parameters:@{@"fields":@"cover"}];
    
    ACAccountType * accountType = [self.fbStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
    request.account = [[self.fbStore accountsWithAccountType:accountType] lastObject];
    
    
    [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        
        
        NSDictionary * response = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil];
        
        if (response)
        {
            NSDictionary * cover = response[@"cover"];
            if (cover){
                NSString * url = cover[@"source"];
                
                SLRequest * request3 =
                [SLRequest requestForServiceType:SLServiceTypeFacebook
                                   requestMethod:SLRequestMethodGET
                                             URL:[NSURL URLWithString:url]
                                      parameters:nil];
                
                [request3 performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                    UIImage * image = [UIImage imageWithData:responseData];
                    
                    FacebookDownloadImageBlock block = self.requests[requestID][JNimageCompletion];
                    
                    block(image,nil);
                    
                    
                }];
                
            }
            
            
        }
    }];

}


@end
