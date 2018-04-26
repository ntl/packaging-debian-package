module Packaging
  module Debian
    class Package
      module Controls
        module Tarball
          module Filename
            def self.example(package_name: nil, version: nil)
              prefix_directory = PrefixDirectory.example(package_name: package_name, version: version)

              "#{prefix_directory}.tar.gz"
            end

            module Alternate
              def self.example
                package_name = Package::Alternate.package
                version = Package::Alternate.version

                Filename.example(package_name: package_name, version: version)
              end
            end
          end
        end
      end
    end
  end
end
