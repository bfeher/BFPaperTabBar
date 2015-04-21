Pod::Spec.new do |s|
  s.name         = "BFPaperTabBar"
  s.version      = "1.0.6"
  s.summary      = "iOS UITabBar inspired by Google's Paper Material Design."
  s.homepage     = "https://github.com/bfeher/BFPaperTabBar"
  s.license      = { :type => 'MIT', :file => 'LICENSE.md' }
  s.author       = { "Bence Feher" => "ben.feher@gmail.com" }
  s.source       = { :git => "https://github.com/bfeher/BFPaperTabBar.git", :tag => "1.0.6" }
  s.platform     = :ios, '7.0'
  s.dependency   'UIColor+BFPaperColors'
 
  
  s.source_files = 'Classes/*.{h,m}'
  s.requires_arc = true

end
