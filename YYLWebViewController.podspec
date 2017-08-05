#
# Be sure to run `pod lib lint YYLWebViewController.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'YYLWebViewController'
  s.version          = '0.1.1'
  s.summary          = '网页视图加载控制器'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
网页视图加载控制器，包含无网络和请求出错提示
                       DESC

  s.homepage         = 'https://github.com/yanyulin/YYLWebViewController'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'yanyulin' => '1418220302@qq.com' }
  s.source           = { :git => 'https://github.com/yanyulin/YYLWebViewController.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'
  s.requires_arc = true
  s.ios.frameworks = 'UIKit', 'Foundation', 'CoreGraphics'

    s.resources = 'YYLWebViewController/Assets/*.{png,xib,nib,bundle}'
  s.source_files = 'YYLWebViewController/Classes/**/*'
  
#s.resource_bundles = {
#    'YYLWebViewController' => ['YYLWebViewController/Assets/*']
#}

#s.resource = 'YYLWebViewController/Assets/*'

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
