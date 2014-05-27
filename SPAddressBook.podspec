Pod::Spec.new do |s|
  s.name         = "SPAddressBook"
  s.version      = "0.0.1"
  s.summary      = "iOS 7 Address Book Utility"
  s.homepage     = "https://github.com/kevinj04/SPAddressBook"
  s.license      = { :type => 'Unlicense', :file => 'LICENSE' }
  s.author       = { "Kevin Jenkins" => "kevinj04@gmail.com" }
  s.source       = { :git => "https://github.com/kevinj04/SPAddressBook.git",
		                 :tag => s.version.to_s }
  s.source_files = 'Classes/**/*.{h,m}'
  s.ios.deployment_target = "7.0"
  s.requires_arc = true
  s.frameworks   = 'AddressBook'
end