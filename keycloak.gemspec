require_relative 'lib/keycloak/version'

Gem::Specification.new do |spec|
  spec.name = 'keycloak'
  spec.version = Keycloak::VERSION
  spec.authors = ['Greg Woods']
  spec.email = ['greg.woods@moserit.com']
  spec.summary = 'Library for exchanging access tokens with keycloak'
  spec.homepage = 'https://bitbucket.org/moser-inc/keycloak-rb'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3.1'
  spec.files = Dir['{lib}/**/*', 'LICENSE.txt', 'Rakefile', 'README.md']
  spec.add_dependency 'jwt'
  spec.require_paths = ['lib']
  spec.metadata['rubygems_mfa_required'] = 'true'
end
