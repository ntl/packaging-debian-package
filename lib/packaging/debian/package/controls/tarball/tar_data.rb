module Packaging
  module Debian
    class Package
      module Controls
        module Tarball
          module TarData
            def self.example(package_name: nil, version: nil, contents: nil)
              contents ||= Contents.example

              prefix_directory = PrefixDirectory.example(
                package_name: package_name,
                version: version
              )

              prefix_directory ||= PrefixDirectory.example
              contents ||= Contents.example

              data = String.new
              data.force_encoding('ASCII-8BIT')

              tar_stream = StringIO.new(data)

              Gem::Package::TarWriter.new(tar_stream) do |tar_writer|
                contents.each do |path, data|
                  full_path = File.join(prefix_directory, path)

                  if data == Dir
                    tar_writer.mkdir(full_path, 0755)
                  else
                    tar_writer.add_file(full_path, 0644) do |file|
                      file.write(data)
                    end
                  end
                end
              end

              data
            end

            def self.stream(package_name: nil, version: nil, contents: nil)
              data = example(
                package_name: package_name,
                version: version,
                contents: contents
              )

              StringIO.new(data)
            end

            module Malformed
              def self.example
                "\xde\xad\xbe\xef" * 100
              end

              def self.stream
                data = example

                StringIO.new(data)
              end
            end
          end
        end
      end
    end
  end
end
