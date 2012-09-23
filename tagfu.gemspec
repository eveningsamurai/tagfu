require 'tagfu/version'

Gem::Specification.new do |s|
  s.name        = 'tagfu'
  s.version     = Tagfu::VERSION
  s.date        = '2012-09-22'
  s.summary     = "tagfu"
  s.description = "A gem to manipulate tags in cucumber feature files"
  s.authors     = ["Avinash Padmanabhan"]
  s.email       = ['avinashpadmanabhan@gmail.com']
  s.files       = ["bin/tagfu",
									 "lib/tagfu.rb",
	                 "lib/tagfu/tagger.rb",
                   "tagfu.gemspec"
									]
  s.homepage    = "https://github.com/eveningsamurai/tagfu"

	s.add_development_dependency "optparse"
	s.add_development_dependency "rspec"

	s.executables << 'tagfu'
end
