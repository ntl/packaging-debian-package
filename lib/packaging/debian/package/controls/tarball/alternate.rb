module Packaging
  module Debian
    class Package
      module Controls
        module Tarball
          module Alternate
            def self.example
              filename = Filename::Alternate.example
              contents = Contents::Alternate.example

              Tarball.example(filename, contents: contents)
            end
          end
        end
      end
    end
  end
end
