module Packaging
  module Debian
    module Package
      module Controls
        module Tarball
          def self.example(package_name: nil, version: nil, contents: nil)
            contents ||= Package::Contents.example

            filename = Filename.example(package_name: package_name, version: version)

            package_root = File.basename(filename, '.tar.gz')

            uncompressed_io = StringIO.new

            Gem::Package::TarWriter.new(uncompressed_io) do |tar_writer|
              contents.each do |path, data|
                full_path = File.join(package_root, path)

                tar_writer.add_file(full_path, 0644) do |file|
                  file.write(data)
                end
              end
            end

            compressed_tarball = String.new

            compressed_io = StringIO.new(compressed_tarball, 'w')

            gzip_writer = Zlib::GzipWriter.new(compressed_io)

            begin
              uncompressed_io.rewind

              until uncompressed_io.eof?
                gzip_writer.write(uncompressed_io.read)
              end
            ensure
              gzip_writer.close

              compressed_io.close
            end

            StringIO.new(compressed_tarball)
          end

          module Filename
            def self.example(package_name: nil, version: nil)
              package_name ||= self.package_name
              version ||= self.version

              "#{package_name}-#{version}.tar.gz"
            end

            def self.package_name
              Package.name
            end

            def self.version
              Package.version
            end
          end
        end
      end
    end
  end
end
