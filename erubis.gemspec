#require File.expand_path("../lib/erubis", __FILE__)
# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'erubis'

Gem::Specification.new do |s|
  s.name              = "erubis"
  s.version           = Erubis::VERSION.dup
  s.summary           = "Fast implementation of eRuby"
  s.authors           = ["kuwata-lab.com"]
  s.homepage          = "https://github.com/jeremyevans/erubis"
  s.license           = "MIT"
  s.files = %w'README.txt MIT-LICENSE CHANGES.txt setup.rb' + Dir['{lib,test}/**/*.rb']
  s.require_paths = ["lib"]

  puts "only including files #{Dir['{lib,test}/**/*.rb'].inspect}"

  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec'
end
