require_relative '../test_init'

at_exit do
  unless ENV['PRESERVE_DIRECTORIES']
    Controls::Directory::Clear.()
  end
end
