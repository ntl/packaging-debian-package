module Packaging
  module Debian
    class Package
      module Controls
        module Package
          module Extract
            def self.call(deb_file, directory: nil)
              directory ||= Dir.mktmpdir('extract-tarball-control')

              `dpkg-deb -x #{deb_file} #{directory}`

              directory
            end
          end
        end
      end
    end
  end
end
