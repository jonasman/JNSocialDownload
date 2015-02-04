//
//  SocialDownload.m
//
//
//  Created by Joao Nunes on 31/10/14.
//
//

#import "JNSocialDownload.h"

@import Social;
@import Accounts;

typedef NS_ENUM(NSInteger, SocialDownloadType) {
    SocialDownloadTypeAvatar = 0,
    SocialDownloadTypeCover,
    SocialDownloadTypeInformation
};


const NSInteger JNSocialDownloadNoAPPID = 1;
const NSInteger JNSocialDownloadNoPermissions = 2;
const NSInteger JNSocialDownloadNoAccount = 3;

static NSString * const JNimageCompletion = @"JNimageCompletion";
static NSString * const JNinfoCompletion = @"JNinfoCompletion";



@interface JNSocialDownload ()

@property (nonatomic) ACAccountStore * accountsStore;
@property (nonatomic) NSMutableDictionary * requests;
@property (nonatomic) NSInteger lastRequestID;
@property (nonatomic) JNSocialDownloadNetwork network;



@end


@implementation JNSocialDownload


- (instancetype)init
{
    self = [super init];
    if (self) {
        _requests = [NSMutableDictionary new];
        _lastRequestID = 0;
    }
    return self;
}

- (instancetype)initWithAppID:(NSString *)appid network:(JNSocialDownloadNetwork)network
{
    self = [self init];
    if (self) {
        _appID = appid;
        _network= network;
    }
    return self;
}

- (ACAccountStore *)accountsStore
{
    if (!_accountsStore)
        _accountsStore = [[ACAccountStore alloc]init];
    
    return _accountsStore;
}



#pragma mark Public API

- (void)downloadAvatar:(SocialDownloadImageBlock)completion
{
    
    NSNumber * requestID = @(self.lastRequestID++);
    
    self.requests[requestID] =
    @{
      JNimageCompletion:(completion?completion:(^(UIImage *image, NSError *error) {}))
      };
    
    
    [self selectSocialIOS:SocialDownloadTypeAvatar requestID:requestID];
}
- (void)downloadCover:(SocialDownloadImageBlock)completion
{
    NSNumber * requestID = @(self.lastRequestID++);
    
    self.requests[requestID] =
    @{
      JNimageCompletion:(completion?completion:(^(UIImage *image, NSError *error) {}))
      };
    
    [self selectSocialIOS:SocialDownloadTypeCover requestID:requestID];
}
- (void)downloadInformation:(SocialDownloadUserInfoBlock)completion
{
    NSNumber * requestID = @(self.lastRequestID++);
    
    self.requests[requestID] =
    @{
      JNinfoCompletion:(completion?completion:(^(NSDictionary *userInfo, NSError *error) {}))
      };
    
    [self selectSocialIOS:SocialDownloadTypeInformation requestID:requestID];
}




#pragma mark Social Logic

- (void)selectSocialIOS:(SocialDownloadType)downloadType requestID:(NSNumber *)requestID
{
    // Social Logic:
    
    // Get ME
    // Get picture with my userID
    
    NSString * SocialAPPID;
    
    if (self.appID)
        SocialAPPID = self.appID;
    else
        SocialAPPID = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"SocialAppID"];
    
    if (!SocialAPPID)
    {
        if (downloadType == SocialDownloadTypeAvatar ||
            downloadType == SocialDownloadTypeCover){
            
            SocialDownloadImageBlock block = self.requests[requestID][JNimageCompletion];
            
            block(nil,[NSError errorWithDomain:@"JNSocialDownload" code:JNSocialDownloadNoAPPID userInfo:@{NSLocalizedDescriptionKey:@"No app ID configured"}]);
            
        }
        else if (downloadType == SocialDownloadTypeInformation)
        {
            SocialDownloadUserInfoBlock block = self.requests[requestID][JNinfoCompletion];
            
            block(nil,[NSError errorWithDomain:@"JNSocialDownload" code:JNSocialDownloadNoAPPID userInfo:@{NSLocalizedDescriptionKey:@"No app ID configured"}]);
        }
        
        return;
    }
    
    
    ACAccountType * accountType =nil;
    NSDictionary * socialOptions =nil;
    
    if(self.network==JNSocialDownloadNetworkFacebook){
            accountType = [self.accountsStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
            socialOptions = @{ACFacebookAppIdKey:SocialAPPID,
                                         ACFacebookPermissionsKey:@[@"user_birthday"]};
        
    }else{
            accountType = [self.accountsStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    }
    
    
    
    
    
    
    [self.accountsStore requestAccessToAccountsWithType:accountType options:socialOptions completion:^(BOOL granted, NSError *error) {
        
        if (error){
            
         
            if (downloadType == SocialDownloadTypeAvatar ||
                downloadType == SocialDownloadTypeCover){
                
                SocialDownloadImageBlock block = self.requests[requestID][JNimageCompletion];
                
                block(nil,[NSError errorWithDomain:@"JNSocialDownload" code:JNSocialDownloadNoAccount userInfo:@{NSLocalizedDescriptionKey:@"No Social Account configured"}]);
                
            }
            else if (downloadType == SocialDownloadTypeInformation)
            {
                SocialDownloadUserInfoBlock block = self.requests[requestID][JNinfoCompletion];
                
                block(nil,[NSError errorWithDomain:@"JNSocialDownload" code:JNSocialDownloadNoAccount userInfo:@{NSLocalizedDescriptionKey:@"No Social Account configured"}]);
            }
            
                
            return ;
        }
        
        if (granted)
        {
            
            [self requestMe:downloadType requestID:requestID];
            
        }
        else
        {
            
            if (downloadType == SocialDownloadTypeAvatar ||
                downloadType == SocialDownloadTypeCover){
                
                SocialDownloadImageBlock block = self.requests[requestID][JNimageCompletion];
                
                block(nil,[NSError errorWithDomain:@"JNSocialDownload" code:JNSocialDownloadNoPermissions userInfo:@{NSLocalizedDescriptionKey:@"Social permission not granted"}]);
                
            }
            else if (downloadType == SocialDownloadTypeInformation)
            {
                SocialDownloadUserInfoBlock block = self.requests[requestID][JNinfoCompletion];
                
                block(nil,[NSError errorWithDomain:@"JNSocialDownload" code:JNSocialDownloadNoPermissions userInfo:@{NSLocalizedDescriptionKey:@"Social permission not granted"}]);
            }
            
        }
        
 
 }];
 
 }

- (void)requestMe:(SocialDownloadType)downloadType requestID:(NSNumber *)requestID {
    
    
    ACAccountType * accountType =nil;
    NSURL *meurl= nil;
    SLRequest *merequest =nil;
    
    
    if(self.network==JNSocialDownloadNetworkFacebook){
        accountType = [self.accountsStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
        meurl = [NSURL URLWithString:@"https://graph.facebook.com/me"];
        
        
        merequest = [SLRequest requestForServiceType:SLServiceTypeFacebook
                                       requestMethod:SLRequestMethodGET
                                                 URL:meurl
                                          parameters:nil];
        
    }else{
        accountType = [self.accountsStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
        meurl = [NSURL URLWithString:@"https://api.twitter.com/1.1/account/verify_credentials.json"];
        
        
        merequest = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                       requestMethod:SLRequestMethodGET
                                                 URL:meurl
                                          parameters:nil];
    }
    
    
    
    
    
    
    ACAccount * account = [[self.accountsStore accountsWithAccountType:accountType] lastObject];
    merequest.account = account;
    
    [merequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        
        
        if (!error){
            
            NSError *jsonParsingError = nil;
            NSDictionary * userData = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&jsonParsingError];
            NSString * SocialID = userData[@"id"];
            
            
            if (downloadType == SocialDownloadTypeAvatar)
            {
                [self requestAvatarFromUser:SocialID requestID:requestID];
            }
            else if (downloadType == SocialDownloadTypeCover)
            {
                [self requestCoverFromUser:SocialID requestID:requestID];
            }
            else if (downloadType == SocialDownloadTypeInformation)
            {
                SocialDownloadUserInfoBlock block = self.requests[requestID][JNinfoCompletion];
                
                block(userData,nil);
            }
            
            
            
        }
        
    }];

}

- (void)requestAvatarFromUser:(NSString *)SocialID requestID:(NSNumber *)requestID
{
    NSString * imageURL = [NSString stringWithFormat:@"https://graph.facebook.com/v2.1/%@/picture",SocialID];
    
    
    SLRequest * request =
    [SLRequest requestForServiceType:SLServiceTypeFacebook
                       requestMethod:SLRequestMethodGET
                                 URL:[NSURL URLWithString:imageURL]
                          parameters:@{@"height":@"512",
                                       @"width":@"512"}];
    
    ACAccountType * accountType = [self.accountsStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
    request.account = [[self.accountsStore accountsWithAccountType:accountType] lastObject];
    
    
    [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        
        
        if (responseData.length > 100)
        {
            UIImage * image = [UIImage imageWithData:responseData];
            
            SocialDownloadImageBlock block = self.requests[requestID][JNimageCompletion];
            
            block(image,nil);
        }
        
    }];
}


- (void)requestCoverFromUser:(NSString *)SocialID requestID:(NSNumber *)requestID
{
    NSString * coverURL = [NSString stringWithFormat:@"https://graph.facebook.com/v2.1/%@",SocialID];
    
    
    
    SLRequest * request =
    [SLRequest requestForServiceType:SLServiceTypeFacebook
                       requestMethod:SLRequestMethodGET
                                 URL:[NSURL URLWithString:coverURL]
                          parameters:@{@"fields":@"cover"}];
    
    ACAccountType * accountType = [self.accountsStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
    request.account = [[self.accountsStore accountsWithAccountType:accountType] lastObject];
    
    
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
                    
                    SocialDownloadImageBlock block = self.requests[requestID][JNimageCompletion];
                    
                    block(image,nil);
                    
                    
                }];
                
            }
            
            
        }
    }];

}


@end
