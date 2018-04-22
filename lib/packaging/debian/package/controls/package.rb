module Packaging
  module Debian
    class Package
      module Controls
        module Package
          extend Packaging::Debian::Schemas::Controls::Package::Data

          def self.example(name: nil, version: nil, contents: nil, **attributes)
            name ||= self.name
            version ||= self.version
            contents ||= Contents.example

            tmp_dir = ::Dir.mktmpdir('package-control')

            stage_dir = ::File.join(tmp_dir, "#{name}-#{version}")

            debian_dir = ::File.join(stage_dir, 'DEBIAN')

            Dir.mkdir(stage_dir)
            Dir.mkdir(debian_dir)

            control_file = ControlFile.example(
              package: name,
              version: version,
              **attributes
            )

            ::File.write(
              ::File.join(debian_dir, 'control'),
              control_file
            )

            contents.each do |file, data|
              path = ::File.join(stage_dir, file)

              dir = ::File.dirname(path)

              ::FileUtils.mkdir_p(dir)

              ::File.write(path, data)
            end

            `dpkg-deb -v --build #{stage_dir}`

            ::File.join(tmp_dir, "#{name}-#{version}.deb")
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
