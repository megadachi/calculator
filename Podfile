source 'https://github.com/CocoaPods/Specs.git'

# Uncomment the next line to define a global platform for your project
 platform :ios, '9.3'

target 'calculator' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for calculator
pod 'Google-Mobile-Ads-SDK'
pod 'Expression'
pod 'Eureka'
pod 'LicensePlist'
pod 'ImageRow'
pod 'ColorPickerRow'
pod 'ASN1Decoder'
pod 'VerifyStoreReceipt'

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '9.0'
    end
  end
end

end
