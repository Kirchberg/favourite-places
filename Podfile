# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'FavouritePlaces' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for FavouritePlaces
  pod 'RealmSwift'
  pod 'SwiftFormat/CLI'
  #pod 'Hero'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    if target.name == 'SwiftFormat/CLI'
      target.build_configurations.each do |config|
        config.build_settings['SWIFT_VERSION'] = '5.3'
      end
    end
  end
end
