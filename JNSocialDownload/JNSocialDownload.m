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



#pragma mark - RequestConfiguration

@interface RequestConfiguration : NSObject

@property (nonatomic) JNSocialDownloadNetwork network;

@property (nonatomic, readonly, copy) SocialDownloadUserInfoBlock infoBlock;
@property (nonatomic, readonly, copy) SocialDownloadImageBlock imageBlock;


+ (instancetype)requestConfigurationWithInfoBlock:(SocialDownloadUserInfoBlock)block andNetwork:(JNSocialDownloadNetwork)network;
+ (instancetype)requestConfigurationWithImageBlock:(SocialDownloadImageBlock)block andNetwork:(JNSocialDownloadNetwork)network;


- (instancetype)initWithInfoBlock:(SocialDownloadUserInfoBlock)block andNetwork:(JNSocialDownloadNetwork)network;
- (instancetype)initWithImageBlock:(SocialDownloadImageBlock)block andNetwork:(JNSocialDownloadNetwork)network;

@end





@implementation RequestConfiguration

- (instancetype)initWithInfoBlock:(SocialDownloadUserInfoBlock)block andNetwork:(JNSocialDownloadNetwork)network
{
    self = [super init];
    if (self) {
        _network = network;
        _infoBlock = block;
    }
    return self;
}

- (instancetype)initWithImageBlock:(SocialDownloadImageBlock)block andNetwork:(JNSocialDownloadNetwork)network
{
    self = [super init];
    if (self) {
        _network = network;
        _imageBlock = block;
    }
    return self;
}

+ (instancetype)requestConfigurationWithInfoBlock:(SocialDownloadUserInfoBlock)block andNetwork:(JNSocialDownloadNetwork)network
{
    return [[RequestConfiguration alloc] initWithInfoBlock:block andNetwork:network];
}
+ (instancetype)requestConfigurationWithImageBlock:(SocialDownloadImageBlock)block andNetwork:(JNSocialDownloadNetwork)network
{
    return [[RequestConfiguration alloc] initWithImageBlock:block andNetwork:network];
}

@end








#pragma mark - JNSocialDownload

typedef NS_ENUM(NSInteger, SocialDownloadType) {
    SocialDownloadTypeAvatar = 0,
    SocialDownloadTypeCover,
    SocialDownloadTypeInformation
};


const NSInteger JNSocialDownloadNoAPPID = 1;
const NSInteger JNSocialDownloadNoPermissions = 2;
const NSInteger JNSocialDownloadNoAccount = 3;



@interface JNSocialDownload ()

@property (nonatomic) ACAccountStore * accountsStore;

@end


@implementation JNSocialDownload


- (instancetype)initWithAppID:(NSString *)appid
{
    self = [self init];
    if (self) {
        _appID = appid;
    }
    return self;
}

#pragma mark Accessors

- (ACAccountStore *)accountsStore
{
    if (!_accountsStore)
        _accountsStore = [[ACAccountStore alloc]init];
    
    return _accountsStore;
}



#pragma mark - Public API

- (void)downloadAvatar:(SocialDownloadImageBlock)completion forNetwork:(JNSocialDownloadNetwork)network
{
    
    RequestConfiguration * request = [RequestConfiguration requestConfigurationWithImageBlock:completion andNetwork:network];
    
    [self selectSocialIOS:SocialDownloadTypeAvatar request:request];
}
- (void)downloadCover:(SocialDownloadImageBlock)completion forNetwork:(JNSocialDownloadNetwork)network
{
    
    RequestConfiguration * request = [RequestConfiguration requestConfigurationWithImageBlock:completion andNetwork:network];
    
    [self selectSocialIOS:SocialDownloadTypeCover request:request];
}
- (void)downloadInformation:(SocialDownloadUserInfoBlock)completion forNetwork:(JNSocialDownloadNetwork)network
{
    
    RequestConfiguration * request = [RequestConfiguration requestConfigurationWithInfoBlock:completion andNetwork:network];
    
    [self selectSocialIOS:SocialDownloadTypeInformation request:request];
}




#pragma mark - Social Logic

- (void)selectSocialIOS:(SocialDownloadType)downloadType request:(RequestConfiguration *)request
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
            downloadType == SocialDownloadTypeCover)
        {
            
            SocialDownloadImageBlock block = request.imageBlock;
            
            block(nil,[NSError errorWithDomain:@"JNSocialDownload" code:JNSocialDownloadNoAPPID userInfo:@{NSLocalizedDescriptionKey:@"No app ID configured"}]);
            
        }
        else if (downloadType == SocialDownloadTypeInformation)
        {
            SocialDownloadUserInfoBlock block = request.infoBlock;
            
            block(nil,[NSError errorWithDomain:@"JNSocialDownload" code:JNSocialDownloadNoAPPID userInfo:@{NSLocalizedDescriptionKey:@"No app ID configured"}]);
        }
        
        return;
    }
    
    
    ACAccountType * accountType;
    NSDictionary * socialOptions;
    
    if (request.network==JNSocialDownloadNetworkFacebook)
    {
            accountType = [self.accountsStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
            socialOptions = @{ACFacebookAppIdKey:SocialAPPID,
                              ACFacebookPermissionsKey:@[@"user_birthday"]};
        
    }
    else if (request.network == JNSocialDownloadNetworkTwitter)
    {
            accountType = [self.accountsStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    }
    
    
    
    [self.accountsStore requestAccessToAccountsWithType:accountType options:socialOptions completion:^(BOOL granted, NSError *error) {
        
        if (error){
            
         
            if (downloadType == SocialDownloadTypeAvatar ||
                downloadType == SocialDownloadTypeCover)
            {
                
                SocialDownloadImageBlock block = request.imageBlock;
                
                block(nil,[NSError errorWithDomain:@"JNSocialDownload" code:JNSocialDownloadNoAccount userInfo:@{NSLocalizedDescriptionKey:@"No Social Account configured"}]);
                
            }
            else if (downloadType == SocialDownloadTypeInformation)
            {
                SocialDownloadUserInfoBlock block = request.infoBlock;
                
                block(nil,[NSError errorWithDomain:@"JNSocialDownload" code:JNSocialDownloadNoAccount userInfo:@{NSLocalizedDescriptionKey:@"No Social Account configured"}]);
            }
            
                
            return ;
        }
        
        if (granted)
        {
            
            [self requestMe:downloadType request:request];
            
        }
        else
        {
            
            if (downloadType == SocialDownloadTypeAvatar ||
                downloadType == SocialDownloadTypeCover)
            {
                
                SocialDownloadImageBlock block =request.imageBlock;
                
                block(nil,[NSError errorWithDomain:@"JNSocialDownload" code:JNSocialDownloadNoPermissions userInfo:@{NSLocalizedDescriptionKey:@"Social permission not granted"}]);
                
            }
            else if (downloadType == SocialDownloadTypeInformation)
            {
                SocialDownloadUserInfoBlock block = request.infoBlock;
                
                block(nil,[NSError errorWithDomain:@"JNSocialDownload" code:JNSocialDownloadNoPermissions userInfo:@{NSLocalizedDescriptionKey:@"Social permission not granted"}]);
            }
            
        }
        
 
 }];
 
 }

- (void)requestMe:(SocialDownloadType)downloadType request:(RequestConfiguration *)request
{
    
    
    SLRequest *merequest = [self requestForNetwork:request.network
                                          dataType:SocialDownloadTypeInformation
                                          userData:nil];
    
    
    __weak typeof(self)weakSelf = self;
    
    [merequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        
        
        if (!error){
            
            NSError *jsonParsingError = nil;
            NSDictionary * userData = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&jsonParsingError];
            
            
            if (downloadType == SocialDownloadTypeAvatar)
            {
                [weakSelf requestAvatarFromUser:userData request:request];
            }
            else if (downloadType == SocialDownloadTypeCover)
            {
                [weakSelf requestCoverFromUser:userData request:request];
            }
            else if (downloadType == SocialDownloadTypeInformation)
            {
                SocialDownloadUserInfoBlock block =request.infoBlock;
                
                block(userData,nil);
            }
            
            
            
        }
        
    }];

}

- (void)requestAvatarFromUser:(NSDictionary *)userData request:(RequestConfiguration *)request
{
    
    SLRequest * avatarRequest  = [self requestForNetwork:request.network
                                          dataType:SocialDownloadTypeAvatar
                                          userData:userData];
    
    
    __weak typeof(self)weakSelf = self;


    [avatarRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        
         [weakSelf processImageData:responseData request:request];
        
    }];
}


- (void)requestCoverFromUser:(NSDictionary *)userData request:(RequestConfiguration *)request
{
    
    SLRequest * coverRequest  = [self requestForNetwork:request.network
                                          dataType:SocialDownloadTypeCover
                                          userData:userData];
    
    
    __weak typeof(self)weakSelf = self;

    
    [coverRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        
        if (request.network == JNSocialDownloadNetworkFacebook)
        {
            
            NSDictionary * response = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil];
            
            BOOL anyError = NO;
            
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
                        
                         [weakSelf processImageData:responseData request:request];
                        
                        
                    }];
                    
                }
                else
                {
                    anyError = YES;
                }
            }
            else
            {
                anyError = YES;
            }
            
            if (anyError)
            {
                ////TODO: throw an error
            }
            
            
        }
        
        else if (request.network == JNSocialDownloadNetworkTwitter)
        {
            [weakSelf processImageData:responseData request:request];
        }
        
        
    }];

}

- (void)processImageData:(NSData *)imageData request:(RequestConfiguration *)request
{
    if (imageData.length > 100)
    {
        UIImage * image = [UIImage imageWithData:imageData];
        
        SocialDownloadImageBlock block = request.imageBlock;
        
        block(image,nil);
    }
}

#pragma mark Request preparation
- (SLRequest *)requestForNetwork:(JNSocialDownloadNetwork)network
                        dataType:(SocialDownloadType)type
                        userData:(NSDictionary *)userData
{
    
    if (network == JNSocialDownloadNetworkFacebook)
    {

        SLRequest * request;
        
        
        if (type == SocialDownloadTypeInformation)
        {
            
            NSURL * meurl = [NSURL URLWithString:@"https://graph.facebook.com/me"];
            
            
            request = [SLRequest requestForServiceType:SLServiceTypeFacebook
                                         requestMethod:SLRequestMethodGET
                                                   URL:meurl
                                            parameters:nil];
            
            
        }
        else if (type == SocialDownloadTypeAvatar)
        {
            
            NSString * SocialID = userData[@"id"];
            NSString * imageURL = [NSString stringWithFormat:@"https://graph.facebook.com/v2.1/%@/picture",SocialID];
            
            
            request = [SLRequest requestForServiceType:SLServiceTypeFacebook
                                         requestMethod:SLRequestMethodGET
                                                   URL:[NSURL URLWithString:imageURL]
                                            parameters:@{@"height":@"512",
                                                         @"width":@"512"}];
            
        }
        else if (type == SocialDownloadTypeCover)
        {
            
            NSString * SocialID = userData[@"id"];
            NSString * coverURL = [NSString stringWithFormat:@"https://graph.facebook.com/v2.1/%@",SocialID];
            
            
            
            request = [SLRequest requestForServiceType:SLServiceTypeFacebook
                                         requestMethod:SLRequestMethodGET
                                                   URL:[NSURL URLWithString:coverURL]
                                            parameters:@{@"fields":@"cover"}];
            
        }
        
        ACAccountType * accountType = [self.accountsStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
        ACAccount * account = [[self.accountsStore accountsWithAccountType:accountType] lastObject];
        request.account = account;
        
        
        return request;
        
    }
    
    
    else if (network == JNSocialDownloadNetworkTwitter)
    {
        
        SLRequest * request;
        
        
        if (type == SocialDownloadTypeInformation)
        {
            
            NSURL * meurl = [NSURL URLWithString:@"https://api.twitter.com/1.1/account/verify_credentials.json"];
            
            
            request = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                         requestMethod:SLRequestMethodGET
                                                   URL:meurl
                                            parameters:nil];
            
        }
        else if (type == SocialDownloadTypeAvatar)
        {
            NSString * imageURL = userData[@"profile_image_url"];
            
            
            request = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                         requestMethod:SLRequestMethodGET
                                                   URL:[NSURL URLWithString:imageURL]
                                            parameters:nil];
        }
        else if (type == SocialDownloadTypeCover)
        {
            
            NSString * imageURL = userData[@"profile_background_image_url"];
            
            request = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                         requestMethod:SLRequestMethodGET
                                                   URL:[NSURL URLWithString:imageURL]
                                            parameters:nil];

            
        }
        
        ACAccountType * accountType = [self.accountsStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
        ACAccount * account = [[self.accountsStore accountsWithAccountType:accountType] lastObject];
        request.account = account;
        
        
        return request;
    }
    
    return nil;
}


@end
