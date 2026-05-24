Pod::Spec.new do |s|
  s.name             = 'TKDebugMenu'
  s.version          = '0.0.1'
  s.summary          = 'Debug menu definitions for TokenTeam iOS app'
  s.homepage         = 'https://github.com/TokenTeamiOS/TKDebugMenu'
  s.license          = { :type => 'MIT' }
  s.author           = { 'TokenTeam' => 'tokenteamios@163.com' }
  s.source           = { :git => 'https://github.com/TokenTeamiOS/TKDebugMenu.git', :tag => s.version.to_s }

  s.ios.deployment_target = '15.0'
  s.swift_version = '5.9'
  s.source_files = 'Sources/**/*.swift'
  s.dependency 'TKMacros'
end
