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


NSInteger JNFacebookDownloadNoAPPID = 1;
NSInteger FacebookDownloadNoPermissions = 2;
NSInteger FacebookDownloadNoAccount = 3;



@interface JNFacebookDownload ()

@property (nonatomic, copy) FacebookDownloadImageBlock avatarCompletion;
@property (nonatomic, copy) FacebookDownloadImageBlock coverCompletion;
@property (nonatomic, copy) FacebookDownloadUserInfoBlock informationCompletion;


@property (nonatomic) ACAccountStore * fbStore;

@end


@implementation JNFacebookDownload



- (void)downloadAvatar:(FacebookDownloadImageBlock)completion
{
    self.avatarCompletion = completion;
    [self selectFacebookIOS:FacebookDownloadTypeAvatar];
}
- (void)downloadCover:(FacebookDownloadImageBlock)completion
{
    self.coverCompletion = completion;
    [self selectFacebookIOS:FacebookDownloadTypeCover];
}
- (void)downloadInformation:(FacebookDownloadUserInfoBlock)completion
{
    self.informationCompletion = completion;
    [self selectFacebookIOS:FacebookDownloadTypeInformation];
}

#pragma mark Facebook

- (void)selectFacebookIOS:(FacebookDownloadType)downloadType
{
    // Facebook Logic:
    
    // Get ME
    // Get picture with my userID
    
    
    if (!self.fbStore)
        self.fbStore = [[ACAccountStore alloc]init];
    ACAccountType * accountType = [self.fbStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
    
    NSString * facebookAPPID;
    
    if (self.appID)
        facebookAPPID = self.appID;
    else
        facebookAPPID = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"FacebookAppID"];
    if (!facebookAPPID)
    {
        if (self.avatarCompletion)
            self.avatarCompletion(nil,[NSError errorWithDomain:@"JNFacebookDownload" code:JNFacebookDownloadNoAPPID userInfo:@{NSLocalizedDescriptionKey:@"No app ID configured"}]);
        if (self.coverCompletion)
            self.coverCompletion(nil,[NSError errorWithDomain:@"JNFacebookDownload" code:JNFacebookDownloadNoAPPID userInfo:@{NSLocalizedDescriptionKey:@"No app ID configured"}]);
        else if (self.informationCompletion)
            self.informationCompletion(nil,[NSError errorWithDomain:@"JNFacebookDownload" code:JNFacebookDownloadNoAPPID userInfo:@{NSLocalizedDescriptionKey:@"No app ID configured"}]);
        
        
        return;
    }
    
    
    
    NSDictionary * facebookOptions = @{ACFacebookAppIdKey:facebookAPPID,
                                       ACFacebookPermissionsKey:@[@"user_birthday"]};
    
    [self.fbStore requestAccessToAccountsWithType:accountType options:facebookOptions completion:^(BOOL granted, NSError *error) {
        
        if (error){
            NSLog(@"Error: %@",error);
         
            if (self.avatarCompletion)
                self.avatarCompletion(nil,[NSError errorWithDomain:@"JNFacebookDownload" code:FacebookDownloadNoAccount userInfo:@{NSLocalizedDescriptionKey:@"No Facebook Account configured"}]);
            if (self.coverCompletion)
                self.coverCompletion(nil,[NSError errorWithDomain:@"JNFacebookDownload" code:FacebookDownloadNoAccount userInfo:@{NSLocalizedDescriptionKey:@"No Facebook Account configured"}]);
            else if (self.informationCompletion)
                self.informationCompletion(nil,[NSError errorWithDomain:@"JNFacebookDownload" code:FacebookDownloadNoAccount userInfo:@{NSLocalizedDescriptionKey:@"No Facebook Account configured"}]);
                
            return ;
        }
        
        if (granted)
        {
            
            [self requestMe:downloadType];
            
        }
        else
        {   
            if (self.avatarCompletion)
                self.avatarCompletion(nil,[NSError errorWithDomain:@"JNFacebookDownload" code:FacebookDownloadNoPermissions userInfo:@{NSLocalizedDescriptionKey:@"Facebook permission not granted"}]);
            else if (self.coverCompletion)
                self.coverCompletion(nil,[NSError errorWithDomain:@"JNFacebookDownload" code:FacebookDownloadNoPermissions userInfo:@{NSLocalizedDescriptionKey:@"Facebook permission not granted"}]);
            else if (self.informationCompletion)
                self.informationCompletion(nil,[NSError errorWithDomain:@"JNFacebookDownload" code:FacebookDownloadNoPermissions userInfo:@{NSLocalizedDescriptionKey:@"Facebook permission not granted"}]);
            
        }
        
 
 }];
 
 }

- (void)requestMe:(FacebookDownloadType)downloadType
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
            
            NSLog(@"%@", userData);
            
            NSString * facebookID = userData[@"id"];
            
            
            if (downloadType == FacebookDownloadTypeAvatar)
            {
                NSString * imageURL = [NSString stringWithFormat:@"https://graph.facebook.com/v2.1/%@/picture",facebookID];
                
                
                SLRequest * request =
                [SLRequest requestForServiceType:SLServiceTypeFacebook
                                   requestMethod:SLRequestMethodGET
                                             URL:[NSURL URLWithString:imageURL]
                                      parameters:@{@"height":@"512",
                                                   @"width":@"512"}];
                
                request.account = account;
                [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                    
                    
                    if (responseData.length > 100)
                    {
                        UIImage * image = [UIImage imageWithData:responseData];
                        
                        if (self.avatarCompletion)
                            self.avatarCompletion(image,nil);
                    }
                    
                }];
                
            }
            else if (downloadType == FacebookDownloadTypeCover)
            {
                
                NSString * coverURL = [NSString stringWithFormat:@"https://graph.facebook.com/v2.1/%@",facebookID];
                
                SLRequest * request =
                [SLRequest requestForServiceType:SLServiceTypeFacebook
                                   requestMethod:SLRequestMethodGET
                                             URL:[NSURL URLWithString:coverURL]
                                      parameters:@{@"fields":@"cover"}];
                
                request.account = account;
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
                                
                                if (self.coverCompletion)
                                    self.coverCompletion(image,nil);

                                
                            }];
                            
                        }
                        
                        
                    }
                }];
                
            }
            else if (downloadType == FacebookDownloadTypeInformation)
            {
                if (self.informationCompletion)
                    self.informationCompletion(userData,nil);
            }
            
            
            
        }
        
    }];

}

@end
