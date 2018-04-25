module Packaging
  module Debian
    class Package
      module Controls
        module Tarball
          module GZipError
            def self.example
              stringio = Tarball.example

              bad_data = "\xde\xad\xbe\xef"
              bad_data.force_encoding('ASCII-8BIT')

              str = stringio.string

              str.insert(str.length / 2, bad_data)

              stringio
            end
          end
        end
      end
    end
  end
end
