module Packaging
  module Debian
    class Package
      module Controls
        module Tarball
          module DataStream
            def self.example(package_name: nil, version: nil, contents: nil)
              data = data(
                package_name: package_name,
                version: version,
                contents: contents
              )

              StringIO.new(data)
            end

            def self.data(package_name: nil, version: nil, contents: nil)
              tar_stream = TarData.stream(
                package_name: package_name,
                version: version,
                contents: contents
              )

              data = String.new

              data_stream = StringIO.new(data, 'r+')

              gzip_writer = Zlib::GzipWriter.new(data_stream)

              begin
                until tar_stream.eof?
                  gzip_writer.write(tar_stream.read)
                end

              ensure
                tar_stream.close
                gzip_writer.close
              end

              data
            end
          end
        end
      end
    end
  end
end
