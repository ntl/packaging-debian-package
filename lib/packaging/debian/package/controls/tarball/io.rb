module Packaging
  module Debian
    class Package
      module Controls
        module Tarball
          module IO
            def self.example(package_name: nil, version: nil, contents: nil)
              contents ||= Package::Contents.example

              prefix_directory = PrefixDirectory.example(
                package_name: package_name,
                version: version
              )

              uncompressed_io = StringIO.new

              Gem::Package::TarWriter.new(uncompressed_io) do |tar_writer|
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

            module GZipError
              def self.example
                stringio = IO.example

                bad_data = "\xde\xad\xbe\xef"
                bad_data.force_encoding('ASCII-8BIT')

                str = stringio.string

                str.insert(str.length / 2, bad_data)

                stringio
              end
            end

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
end
