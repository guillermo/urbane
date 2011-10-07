# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "urbane/version"

Gem::Specification.new do |s|
  s.name        = "urbane"
  s.version     = Urbane::VERSION
  s.authors     = ["Patrick Huesler"]
  s.email       = ["patrick.huesler@gmail.com"]
  s.homepage    = "https://github.com/phuesler/urbane"
  s.summary     = %q{Read google spreadsheet and generate translation files out of it}
  s.description = %q{Read google spreadsheet and generate translation files out of it}

  s.rubyforge_project = "urbane"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  s.add_development_dependency "mocha"
  s.add_development_dependency "shoulda-context"
  s.add_development_dependency "fakeweb"
  s.add_development_dependency "rake"

  s.add_runtime_dependency "json", "1.6.1"
  s.add_runtime_dependency "nokogiri", "1.5.0"
end
