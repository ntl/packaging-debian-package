# -*- encoding: utf-8 -*-
Gem::Specification.new do |s|
  s.name = 'packaging-debian-package'
  s.version = '0.1.1.0'
  s.summary = 'Generate Debian packages (.deb) from tarballs'
  s.description = ' '

  s.authors = ['BTC Labs']
  s.email = ' '
  s.homepage = 'https://github.com/btc-labs/packaging-debian-package'
  s.licenses = ['Proprietary']

  s.require_paths = ['lib']
  s.files = Dir.glob('{lib}/**/*')
  s.platform = Gem::Platform::RUBY
  s.required_ruby_version = '>= 2.4.0'

  s.add_runtime_dependency 'evt-settings'

  s.add_runtime_dependency 'shell_command-execute'
  s.add_runtime_dependency 'packaging-debian-schemas'

  s.add_development_dependency 'test_bench'
end
