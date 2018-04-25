module Packaging
  module Debian
    class Package
      module Controls
        module Tarball
          module TarError
            def self.example
              tar_data = "\xde\xad\xbe\xef" * 100

              output_str = String.new

              output_io = StringIO.new(output_str)

              gzip_writer = Zlib::GzipWriter.new(output_io)
              gzip_writer.write(tar_data)
              gzip_writer.close

              output_io.close

              StringIO.new(output_str)
            end
          end
        end
      end
    end
  end
end
