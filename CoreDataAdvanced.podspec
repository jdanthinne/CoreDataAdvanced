Pod::Spec.new do |s|
  s.name                      = "CoreDataAdvanced"
  s.version                   = "1.1.0"
  s.summary                   = "CoreDataAdvanced"
  s.homepage                  = "https://github.com/JérômeDanthinne/CoreDataAdvanced"
  s.license                   = { :type => "MIT", :file => "LICENSE" }
  s.author                    = { "Jérôme Danthinne" => "jerome@grincheux.be" }
  s.source                    = { :git => "https://github.com/JérômeDanthinne/CoreDataAdvanced.git", :tag => s.version.to_s }
  s.ios.deployment_target     = "10.0"
  s.tvos.deployment_target    = "10.0"
  s.watchos.deployment_target = "3.0"
  s.osx.deployment_target     = "10.12"
  s.source_files              = "Sources/**/*"
  s.frameworks                = "Foundation"
end
