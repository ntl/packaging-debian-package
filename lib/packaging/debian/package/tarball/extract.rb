module Packaging
  module Debian
    class Package
      module Tarball
        class Extract
          include Log::Dependency

          configure :extract_tarball

          initializer :data_stream, :output_dir

          def self.build(tarball, output_dir=nil)
            output_dir ||= Dir.mktmpdir('extract-tarball')

            if tarball.is_a?(String)
              data_stream = File.open(tarball, 'r')
            else
              data_stream = tarball
            end

            instance = new(data_stream, output_dir)
            instance
          end

          def self.call(tarball, output_dir=nil)
            instance = build(tarball, output_dir)
            instance.()
          end

          def call
            logger.trace { "Extracting tarball (#{LogText.attributes(self)})" }

            if data_stream.closed?
              error_message = "Could not extract data_stream; IO is closed (#{LogText.attributes(self)})"
              logger.error { error_message }
              raise ClosedError, error_message
            end

            gzip_reader = Zlib::GzipReader.new(data_stream)

            Gem::Package::TarReader.new(gzip_reader) do |tar_reader|
              extract_tar(tar_reader)
            end

            logger.debug { "Extracted tarball (#{LogText.attributes(self)})" }

            data_stream.close

            output_dir

          rescue Zlib::GzipFile::Error, Zlib::DataError
            error_message = "Could not extract data_stream; not in gzip format (#{LogText.attributes(self)})"
            logger.error { error_message }
            raise GZipError, error_message

          ensure
            gzip_reader&.close
          end

          def extract_tar(tar_reader)
            tar_reader.each do |entry|
              destination_path = File.join(output_dir, entry.full_name)

              if entry.directory?
                FileUtils.mkdir_p(destination_path)
              else
                destination_dir = File.dirname(destination_path)

                FileUtils.mkdir_p(destination_dir)

                File.open(destination_path, 'wb') do |io|
                  io.write(entry.read) until entry.eof?
                end
              end
            end

          rescue ArgumentError => error
            error_message = "Could not extract data_stream; not in tar format (#{LogText.attributes(self)})"
            logger.error { error_message }
            raise TarError, error_message
          end

          ClosedError = Class.new(StandardError)
          GZipError = Class.new(StandardError)
          TarError = Class.new(StandardError)

          module LogText
            def self.attributes(extract)
              %{Input: #{extract.data_stream.inspect}, Output Directory: #{extract.output_dir.inspect}}
            end
          end
        end
      end
    end
  end
end
