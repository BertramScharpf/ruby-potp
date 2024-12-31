#
#  potp.gemspec  --  Gem Specification
#

require "./lib/potp/version"


Gem::Specification.new do |s|
  s.name        = "potp"
  s.version     = POTP::VERSION
  s.platform    = Gem::Platform::RUBY
  s.required_ruby_version = ">= 3.1"
  s.summary     = "Plain One Time Password Tool"
  s.description = <<~EOT
    A Ruby library for generating and verifying one time passwords,
    both HOTP and TOTP, and includes QR Code provisioning.
  EOT
  s.license     = "LicenseRef-LICENSE"
  s.authors     = ["Bertram Scharpf"]
  s.email       = ["<software@bertram-scharpf.de>"]
  s.homepage    = "https://github.com/BertramScharpf/ruby-potp"

  s.requirements      = "Just Ruby and some more if you like"
  unless :full_dependecies then
    s.add_dependency      "supplement", "~>2", ">=2.10"
    s.add_dependency      "appl", "~>1"
  end

  s.require_paths = %w(lib)
  s.extensions    = %w()
  s.files         = Dir[ "lib/**/*.rb", "bin/*", ]
  s.executables   = %w(potp)
  s.extra_rdoc_files  = %w(LICENSE README.md potp.gemspec)
end

