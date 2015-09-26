source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'
use_frameworks!

pod 'Realm', :git => 'https://github.com/realm/realm-cocoa.git', :branch => 'swift-2.0'
pod 'RealmSwift', :git => 'https://github.com/realm/realm-cocoa.git', :branch => 'swift-2.0'
pod 'Alamofire', '~> 2.0'
pod 'SwiftyJSON', '~> 2.3'
pod 'OAuthSwift', '~> 0.4'
pod 'SDWebImage'
pod 'SVProgressHUD'
pod 'M2DWebViewController'
pod 'JDStatusBarNotification'

target 'AlcatrazTourTests' do
    pod 'Alamofire', '~> 2.0'
    pod 'SwiftyJSON', '~> 2.3'
    pod 'SDWebImage'
    pod 'SVProgressHUD'
    pod 'JDStatusBarNotification'
end

post_install do | installer |
    require 'fileutils'
    FileUtils.cp_r('Pods/Target Support Files/Pods/Pods-acknowledgements.plist', 'AlcatrazTour/Settings.bundle/Acknowledgements.plist', :remove_destination => true)
end
