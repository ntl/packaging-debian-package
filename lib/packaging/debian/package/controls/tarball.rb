module Packaging
  module Debian
    class Package
      module Controls
        module Tarball
          def self.example(filename=nil, package_name: nil, version: nil, contents: nil)
            filename ||= Filename.example(package_name: package_name, version: version)

            tarball_io = IO.example(package_name: package_name, version: version, contents: contents)

            dir = Dir.mktmpdir

            absolute_path = File.join(dir, filename)

            File.open(absolute_path, 'w') do |io|
              io.write(tarball_io.read) until tarball_io.eof?
            end

            absolute_path
          end

          module PrefixDirectory
            def self.example(package_name: nil, version: nil)
              package_name ||= self.package_name
              version ||= self.version

              "#{package_name}-#{version}"
            end

            def self.package_name
              Package.name
            end

            def self.version
              Package.version
            end
          end

          module Filename
            def self.example(package_name: nil, version: nil)
              prefix_directory = PrefixDirectory.example(package_name: package_name, version: version)

              "#{prefix_directory}.tar.gz"
            end
          end
        end
      end
    end
  end
end
