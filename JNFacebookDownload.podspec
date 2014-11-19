#
# Be sure to run `pod lib lint JNFacebookDownload.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "JNFacebookDownload"
  s.version          = "0.1.0"
  s.summary          = "A Dead simple facebook data downloader."
  s.description      = <<-DESC
                       "This component is a drop in component if you want access user profile information without going to through the facebook sdk integration hassel. It does the job well!
                        Next we need to add twitter to it and refacetor the code to be more generic"
                       DESC
  s.homepage         = "https://github.com/ijameelkhan/JNFacebookDownload"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "Jameel" => "i.jameelkhan@gmail.com" }
  s.source           = { :git => "https://github.com/ijameelkhan/JNFacebookDownload.git", :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'JNSocialDownload/*.{m,h}'
  s.resource_bundles = {
    'JNFacebookDownload' => ['Pod/Assets/*.png']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
    s.frameworks = 'UIKit', 'MapKit', 'Social', 'Accounts'
  # s.dependency 'AFNetworking', '~> 2.3'
end
