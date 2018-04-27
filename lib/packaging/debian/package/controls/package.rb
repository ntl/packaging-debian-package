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

            stage_dir = Directory.random

            control_metadata = Metadata.example(package: name, version: version)

            package = Packaging::Debian::Package.new(tarball, name, version)

            package.maintainer = self.maintainer

            package_definition_dir = PackageDefinition.example(
              package_name: name,
              metadata: control_metadata
            )
            package.package_definition_root = File.dirname(package_definition_dir)

            package.stage_dir = stage_dir

            package.() do |metadata|
              SetAttributes.(metadata, control_metadata)
            end
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
