require "json"

package = JSON.parse(File.read(File.join(__dir__, "package.json")))

folly_compiler_flags = '-DFOLLY_NO_CONFIG -DFOLLY_MOBILE=1 -DFOLLY_USE_LIBCPP=1 -Wno-comma -Wno-shorten-64-to-32'
folly_version = '2018.10.22.00'

Pod::Spec.new do |s|
  s.name         = "RNReanimated"
  s.version      = package["version"]
  s.summary      = package["description"]
  s.description  = <<-DESC
                  RNReanimated
                   DESC
  s.homepage     = "https://github.com/kmagiera/react-native-reanimated"
  s.license      = "MIT"
  # s.license    = { :type => "MIT", :file => "FILE_LICENSE" }
  s.author       = { "author" => "author@domain.cn" }
  s.platforms    = { :ios => "9.0", :tvos => "9.0" }
  s.source       = { :git => "https://github.com/kmagiera/react-native-reanimated.git", :tag => "#{s.version}" }

  s.source_files = "ios/**/*.{h,m,mm}"
  s.requires_arc = true
  s.compiler_flags  = folly_compiler_flags

  s.dependency "React"
  s.dependency "React-jsi"
  s.dependency "React-jsiexecutor"
  s.dependency "React-jsinspector"
  s.dependency "ReactCommon/jscallinvoker"
  s.dependency 'React-cxxreact'
  s.dependency 'Folly'

  s.pod_target_xcconfig = { "HEADER_SEARCH_PATHS" => "\"$(PODS_ROOT)/Folly\"" }

end

