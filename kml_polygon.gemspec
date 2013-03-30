# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require './lib/kml_polygon/version'

Gem::Specification.new do |gem|
  gem.name          = "kml_polygon"
  gem.version       = KmlPolygon::VERSION
  gem.authors       = ["Nick Galbreath", "Matthew Brookes"]
  gem.email         = ["kml_polygon@nospam.33m.co"]
  gem.description   = %q{Generate KML polygons (circle, star etc.) from lat/long and radius
                         A port of http://blog.client9.com/2007/09/drawing-circles-and-stars-on-google.html}
  gem.summary       = %q{Output a KML fragment defining a polygon (eg. a circle or star) about a point}
  gem.homepage      = "https://github.com/mbrookes/kml_polygon"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
  gem.license       = "MIT"
end
