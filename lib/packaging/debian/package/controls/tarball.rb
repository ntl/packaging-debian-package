module Packaging
  module Debian
    class Package
      module Controls
        module Tarball
          def self.example(filename=nil, data_stream: nil, package_name: nil, version: nil, contents: nil)
            filename ||= Filename.example(package_name: package_name, version: version)
            data_stream ||= stream(package_name: package_name, version: version, contents: contents)

            dir = Directory.random

            absolute_path = File.join(dir, filename)

            File.open(absolute_path, 'w') do |io|
              io.write(data_stream.read) until data_stream.eof?
            end

            absolute_path
          end

          def self.stream(package_name: nil, version: nil, contents: nil)
            DataStream.example(
              package_name: package_name,
              version: version,
              contents: contents
            )
          end

          def self.data(package_name: nil, version: nil, contents: nil)
            DataStream.data(
              package_name: package_name,
              version: version,
              contents: contents
            )
          end
        end
      end
    end
  end
end
