#
# Be sure to run `pod lib lint AnnounceKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'AnnounceKit'
  s.version          = '0.10.1'
  s.summary          = 'AnnounceKit is the iOS SDK of AnnounceKit. Find more info on https://announcekit.app'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  AnnounceKit is the iOS SDK of AnnounceKit.
  It lets you display widgets right from your app. You can create native launcher buttons, or use your own UI components to trigger widgets.

  You can also subscribe to unread count changes to update your UI.

  Install via CocoaPods, Carthage and SPM.
                       DESC

  s.homepage         = 'https://announcekit.app/docs/ios-sdk'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Seyfeddin Başsaraç' => 'seyfeddin@wearethread.co' }
  s.source           = { :git => 'https://github.com/announcekitapp/announcekit-ios-sdk.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/announcekit'
  s.pod_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
  s.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
  s.swift_version = '5.0'
  s.ios.deployment_target = '11.0'

  s.source_files = 'Sources/AnnounceKit/Classes/**/*'
  
  # s.resource_bundles = {
  #   'AnnounceKit' => ['AnnounceKit/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'UIKit', 'WebKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
