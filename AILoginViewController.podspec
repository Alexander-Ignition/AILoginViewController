
Pod::Spec.new do |s|

  s.name         = "AILoginViewController"
  s.version      = "0.0.1"
  s.summary      = "UILoginViewController for Authorization"
  s.homepage     = "https://github.com/Alexander-Ignition"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "GRADUATION" => "izh.sever@gmail.com" }
  s.platform     = :ios, "7.0"
  s.source       = { :git => "https://github.com/Alexander-Ignition/AILoginViewController.git", :tag => s.version.to_s }
  s.source_files = "AILoginViewController/*.{h,m}"
  s.requires_arc = true

  s.dependency "ReactiveCocoa", "~> 2.0"

end
