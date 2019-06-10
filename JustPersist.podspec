#
# Be sure to run `pod lib lint JustPersist.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'JustPersist'
  s.version          = '2.5.1'
  s.summary          = 'JustPersist is the easiest and safest way to do persistence on iOS with Core Data support out of the box. It also allows you to migrate to any other persistence framework with minimal effort.'

  s.description      = "<<-DESC
JustPersist aims to be the easiest and safest way to do persistence on iOS. It supports Core Data out of the box and can be extended to transparently support other frameworks.
You can use JustPersist to migrate from one persistence layer to another with minimal effort. Since we moved from MagicalRecord to Skopelos, we provide available wrappers for these two frameworks.
At it's core, JustPersist is a persistence layer with a clear and simple interface to do transactional readings and writings, taking inspirations from Skopelos where readings and writings are separated by design.
                        DESC"

  s.homepage         = 'https://github.com/justeat/JustPersist'
  s.license          = { :type => 'Apache 2.0', :file => 'LICENSE' }
  s.authors          = { 'Alberto De Bortoli' => 'alberto.debortoli@just-eat.com', 'Keith Moon' => 'keith.moon@just-eat.com', 'Luigi Parpinel' => 'luigi.parpinel@just-eat.com' }

  s.source           = { :git => 'https://github.com/justeat/JustPersist.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/justeat_tech'

  s.ios.deployment_target = '10.0'
  s.swift_version = '5.0'

  s.frameworks = 'Foundation', 'CoreData'

  s.default_subspecs = 'Core'

  s.subspec 'Core' do |ss|
    ss.source_files = 'JustPersist/Classes/Core/**/*'
  end

  s.subspec 'Skopelos' do |ss|
    ss.dependency 'JustPersist/Core'
    ss.dependency 'Skopelos', '~> 2.4.1'
    ss.source_files = 'JustPersist/Classes/Wrappers/Skopelos/*'
  end

  s.subspec 'MagicalRecord' do |ss|
    ss.dependency 'JustPersist/Core'
    ss.dependency 'MagicalRecord', '~> 2.3.2'
    ss.source_files = 'JustPersist/Classes/Wrappers/MagicalRecord/*'
  end

end
