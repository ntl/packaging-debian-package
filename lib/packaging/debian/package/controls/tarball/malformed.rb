module Packaging
  module Debian
    class Package
      module Controls
        module Tarball
          module Malformed
            module GZip
              def self.example
                Tarball.example(data_stream: stream)
              end

              def self.stream
                StringIO.new(data)
              end

              def self.data
                malformed_data = "\xde\xad\xbe\xef" * 100
                malformed_data.force_encoding('ASCII-8BIT')
              end
            end

            module Tar
              def self.example
                Tarball.example(data_stream: stream)
              end

              def self.stream
                StringIO.new(data)
              end

              def self.data
                tar_data = TarData::Malformed.example

                output = String.new

                output_stream = StringIO.new(output)

                gzip_writer = Zlib::GzipWriter.new(output_stream)
                gzip_writer.write(tar_data)
                gzip_writer.close

                output
              end
            end
          end
        end
      end
    end
  end
end
