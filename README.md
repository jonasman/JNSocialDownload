JNSocialDownload
======================

A Dead simple Facebook and Twitter avatar and cover downloader


#Getting Started
##Objc-c
============

1. Copy JNSocialDownload class into your project.
2. `socialDownload = [[JNSocialDownload alloc] init];`
3. `socialDownload.appID = YOUR_FACEBOOK_APP_ID` . If you have used FacebookSDK and you set the app id in the info.plist then this library is also able to get it from there
4. Download some data with `- (void)downloadAvatarForNetwork:(JNSocialDownloadNetwork)network completionHandler:(SocialDownloadImageBlock)completion ;` 


##Swift
============
1. Copy JNSocialDownload class into your project.
2. `var socialDownload = JNSocialDownload()`
3. `socialDownload.appID = YOUR_FACEBOOK_APP_ID` . If you have used FacebookSDK and you set the app id in the info.plist then this library is also able to get it from there
4. Download some data with `func downloadAvatar(ForNetwork network:JNSocialDownloadNetwork, completionHandler: SocialDownloadImageClosure) -> Void` 


Facebook APP ID
============
To use the native iOS facebook integration you need to create a facebok app id. 
The app id can be created here: https://developers.facebook.com , select "new app" and an ID will be created.



Considerations
============

The completion handler will be called in a background thread if you need to go back to the Main thread just call:
`
  dispatch_async(dispatch_get_main_queue(), ^{
    // DO SOMETHING WITH RESULT DATA
  });
        `
        
Licence
============
        
The MIT License (MIT)

Copyright (c) 2014 João Nunes

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
