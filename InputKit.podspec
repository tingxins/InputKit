
Pod::Spec.new do |s|
  s.name         = "InputKit"
  s.version      = "1.1.3"
  s.summary      = "InputKit is an Elegant Kit to limits your input text in Objective-C, inspired by BlocksKit."
  s.homepage     = "https://github.com/tingxins/InputKit"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "tingxins" => "tingxins@sina.com" }
  s.platform     = :ios, "8.0"
  s.source     = { :git => "https://github.com/tingxins/InputKit.git", :tag => 'v1.1.3'   }
  s.source_files  = 'InputKit/**/*.{h,m}'
  s.requires_arc = true
end
