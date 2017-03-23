Pod::Spec.new do |s|
  s.name         = "FXBanner"
  s.version      = "1.0.3"
  s.summary      = "广告"

  s.homepage     = "https://github.com/zqw87699/FXBanner"

  s.license      = { :type => "MIT", :file => "LICENSE" }

  s.author       = {"zhangdazong" => "929013100@qq.com"}

  s.source       = { :git => "https://github.com/zqw87699/FXBanner.git", :tag => "#{s.version}"}

  s.platform     = :ios, "7.0"

  s.frameworks = "Foundation", "UIKit"

  s.module_name = 'FXBanner' 

  s.requires_arc = true

  s.resources = 'Classes/Resources/FXBannerView.xib'

  s.source_files = 'Classes/*'
  s.public_header_files = 'Classes/*.h'

  s.dependency 'Masonry', '1.0.2'
  s.dependency 'ReactiveObjC', '2.1.2'
  s.dependency "FXCommon/Core" 
  s.dependency "FXCommon/Utiles" 
  s.dependency "FXCommon/Base" 

end
