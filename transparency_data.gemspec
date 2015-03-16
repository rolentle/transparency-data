Gem::Specification.new do |s|
  s.name              = "transparency_data"
  s.version           = "1.0.0"
  s.date              = "2010-06-24"
  s.summary           = "Wrapper for the Sunlight Transparency data API"
  s.description       = "Wrapper for the Sunlight Transparency data API"
  s.homepage          = "http://github.com/pengwynn/transparency-data"
  s.email             = ["wynn.netherland@gmail.com", "jeremy@hinegardner.org", "luigi.montanez@gmail.com"]
  s.authors           = [
    "Wynn Netherland",
    "Jeremy Hinegardner",
    "Luigi Montanez",
  ]
  s.has_rdoc          = false
  s.files             = %w[README.md lib/transparency_data.rb lib/transparency_data/client.rb]
  s.add_dependency("faraday")
  s.add_dependency("hashie", ">= 0.2.0")
  s.add_dependency("rake")
  s.add_development_dependency("webmock")
  s.add_development_dependency("mg", ">= 0.0.8")
  s.add_development_dependency("minitest", ">= 0")
  s.add_development_dependency("pry", ">= 0")
  s.add_development_dependency("vcr", ">= 0.4.1")
  s.add_development_dependency("yard", ">= 0")
end
