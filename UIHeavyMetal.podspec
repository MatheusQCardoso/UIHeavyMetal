Pod::Spec.new do |s|
	s.name             = 'UIHeavyMetal'
	s.version          = '0.1.0'
	s.summary          = 'A simple Metal shader development interface integrated to UIKit.'
	s.description      = <<-DESC
	A simple Metal shader development interface integrated to UIKit.
	Provides for a clean, declarative-like way of writing your own Metal shaders and using
	them in new or existing UIKit views.
							DESC
	s.homepage         = 'https://github.com/MatheusQCardoso/UIHeavyMetal'
	s.license          = { :type => 'MIT', :file => 'LICENSE' }
	s.author           = { 'MatheusQCardoso' => 'matheusqcardoso98@gmail.com' }
	s.source           = { :git => 'https://github.com/MatheusQCardoso/UIHeavyMetal.git', :tag => s.version.to_s }
	s.ios.deployment_target = '14.0'
	s.source_files = 'UIHeavyMetal/**/*.{h,m,swift}' # Adjust this path based on your structure
	s.swift_version = '5.0'
end