module Packaging
  module Debian
    class Package
      module Controls
        module Tarball
          module UnderscoreDelimited
            def self.example
              Tarball.example(package_name: package_name)
            end

            def self.package_name
              Package.name.gsub('-', '_')
            end
          end
        end
      end
    end
  end
end
