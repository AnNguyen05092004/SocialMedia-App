# Uncomment the next line to define a global platform for your project
platform :ios, '13.0'

target 'PtitSocialMedia' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

pod 'Appirater'
pod 'SDWebImage'

# Firebase
pod 'Firebase/Core'
pod 'Firebase/Auth'
pod 'Firebase/Database'
pod 'Firebase/Analytics'
pod 'Firebase/Crashlytics'
pod 'Firebase/Storage'
pod 'Firebase/Firestore'


post_install do |installer|
    installer.generated_projects.each do |project|
        project.targets.each do |target|
            target.build_configurations.each do |config|
                config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
            end
        end
    end
end

end
