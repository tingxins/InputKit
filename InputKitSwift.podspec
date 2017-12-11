Pod::Spec.new do |s|
  s.name         = "InputKitSwift"
  s.version      = "1.1.17"
  s.summary      = "InputKit is an Elegant Kit to limits your input text in Swift, inspired by BlocksKit."
  s.homepage     = "https://github.com/tingxins/InputKit"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "tingxins" => "tingxins@sina.com" }
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/tingxins/InputKit.git", :tag => 'v1.1.17' }
  s.source_files  = 'InputKitSwift/**/*.{swift}'
  s.requires_arc = true
  end