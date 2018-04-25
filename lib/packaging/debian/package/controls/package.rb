module Packaging
  module Debian
    class Package
      module Controls
        module Package
          extend Packaging::Debian::Schemas::Controls::Package::Data

          def self.example(name: nil, version: nil, contents: nil, **attributes)
            name ||= self.name
            version ||= self.version

            tarball = Tarball.example(package_name: name, version: version, contents: contents)

            output_dir = Directory.random

            package = Packaging::Debian::Package.new(tarball, name, version)
            package.maintainer = self.maintainer
            package.output_dir = output_dir

            control_metadata = Metadata.example(package: name, version: version)

            package.() do |metadata|
              SetAttributes.(metadata, control_metadata)
            end

            package.output_file
          end

          def self.filename(package: nil, version: nil, directory: nil)
            package ||= self.name
            version ||= self.version

            basename = "#{package}-#{version}.deb"

            if directory.nil?
              basename
            else
              File.join(directory, basename)
            end
          end

          def self.name
            package
          end
        end
      end
    end
  end
end
