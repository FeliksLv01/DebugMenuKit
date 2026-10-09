Pod::Spec.new do |s|
  s.name             = 'DebugMenuKit'
  s.version          = '0.0.2'
  pod_macro_flags = '$(inherited) -load-plugin-executable "${PODS_TARGET_SRCROOT}/Prebuilt/DebugMenuKitMacros#DebugMenuKitMacros" -enable-experimental-feature SymbolLinkageMarkers'
  user_macro_flags = '$(inherited) -load-plugin-executable "${PODS_ROOT}/DebugMenuKit/Prebuilt/DebugMenuKitMacros#DebugMenuKitMacros" -enable-experimental-feature SymbolLinkageMarkers'

  s.summary          = 'A lightweight iOS floating debug menu'
  s.homepage         = 'https://github.com/FeliksLv01/DebugMenuKit'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'FeliksLv01' => 'felikslv@163.com' }
  s.source           = { :git => 'https://github.com/FeliksLv01/DebugMenuKit.git', :tag => s.version.to_s }

  s.ios.deployment_target = '15.0'
  s.swift_version = '6.0'
  s.source_files = 'Sources/DebugMenuKit/**/*.swift'
  s.prepare_command = 'ruby Scripts/macro_artifact.rb'
  s.preserve_paths = 'Prebuilt/DebugMenuKitMacros', 'Scripts/macro_artifact.rb', 'MacroArtifact.lock.json', 'ThirdPartyNotices/*'
  s.pod_target_xcconfig = { 'OTHER_SWIFT_FLAGS' => pod_macro_flags }
  s.user_target_xcconfig = { 'OTHER_SWIFT_FLAGS' => user_macro_flags }
end
