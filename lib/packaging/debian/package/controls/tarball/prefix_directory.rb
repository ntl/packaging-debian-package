module Packaging
  module Debian
    class Package
      module Controls
        module Tarball
          module PrefixDirectory
            def self.example(package_name: nil, version: nil)
              package_name ||= Package.name
              version ||= Package.version

              "#{package_name}-#{version}"
            end
          end
        end
      end
    end
  end
end
