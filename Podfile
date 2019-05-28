# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'Instacam' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

pod 'Firebase/Core'
pod 'AgoraRtcEngine_iOS'
pod 'IQKeyboardManagerSwift'
pod 'NVActivityIndicatorView'
pod 'Alamofire'
pod 'SwiftyJSON'
pod 'SIAlertView'
pod 'EmptyDataSet-Swift'
pod 'SDWebImage'
pod 'Cosmos'
pod 'ImageSlideshow'
pod 'ImageSlideshow/Alamofire'
pod 'INSPullToRefresh'
pod 'Socket.IO-Client-Swift'
pod 'Toast-Swift'
pod 'GoogleMaps'
pod 'GooglePlaces'
pod 'KWVerificationCodeView'
pod 'SWRevealViewController'
pod 'RNNotificationView'
pod 'Fabric'
pod 'Crashlytics'
pod 'Shimmer'
pod 'VeeContactPicker'
pod 'Stripe'

  # Pods for Instacam

end

post_install do |installer|
    installer.pods_project.build_configurations.each do |config|
        config.build_settings.delete('CODE_SIGNING_ALLOWED')
        config.build_settings.delete('CODE_SIGNING_REQUIRED')
    end
end
