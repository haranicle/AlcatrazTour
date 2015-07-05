source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'
use_frameworks!

pod 'Alamofire', '~> 1.2'
pod 'SwiftyJSON', '~> 2.2'
pod 'Realm', '~> 0.90.6'
pod 'OAuthSwift', '~> 0.3.6'
pod 'SDWebImage'
pod 'SVProgressHUD'
pod 'M2DWebViewController'
pod 'JDStatusBarNotification'

target 'AlcatrazTourTests' do
    pod 'Alamofire', '~> 1.2'
    pod 'SwiftyJSON', '~> 2.2'
    pod 'Realm/Headers'
    pod 'SDWebImage'
    pod 'SVProgressHUD'
    pod 'JDStatusBarNotification'
end

post_install do | installer |
    require 'fileutils'
    FileUtils.cp_r('Pods/Target Support Files/Pods/Pods-acknowledgements.plist', 'AlcatrazTour/Settings.bundle/Acknowledgements.plist', :remove_destination => true)
end
