module Packaging
  module Debian
    class Package
      include Log::Dependency

      setting :maintainer

      attr_writer :output_dir
      def output_dir
        @output_dir ||= File.join('tmp', "package-#{SecureRandom.alphanumeric}")
      end

      initializer :tarball_io, :name, :version

      def configure(settings=nil, namespace: nil)
        settings ||= Settings.build
        namespace = Array(namespace)

        settings.set(self, *namespace)
      end

      def self.build(tarball, name, version, settings=nil, namespace: nil)
        instance = new(tarball, name, version)
        instance.configure(settings, namespace: nil)
        instance
      end

      def call
        untar

        write_control_file

        generate_deb
      end

      def untar
        gzip_reader = Zlib::GzipReader.new(tarball_io)

        begin
          Gem::Package::TarReader.new(gzip_reader) do |tar_reader|
            tar_reader.each do |entry|
              destination_path = File.join(stage_dir, entry.full_name)

              if entry.directory?
                fail "Not yet covered"
              else
                destination_dir = File.dirname(destination_path)

                FileUtils.mkdir_p(destination_dir)

                File.open(destination_path, 'wb') do |io|
                  io.write(entry.read) until entry.eof?
                end
              end
            end
          end

        ensure
          gzip_reader.close
        end
      end

      def write_control_file
        package = Schemas::Package.new
        package.package = name
        package.version = version

        package.description ||= Defaults.description
        package.architecture ||= Defaults.architecture
        package.maintainer ||= self.maintainer

        Dir.mkdir(File.dirname(control_file))

        text = Transform::Write.(package, :rfc822)

        File.write(control_file, text)
      end

      def generate_deb
        command = %W[
          dpkg-deb -v --build #{stage_dir}
        ]

        logger.trace { "Generating debian package (File: #{output_file})" }
        logger.trace(tag: :command) { command * ' ' }

        Open3.popen3(*command) do |_, stdout, stderr, wait_thr|
          until stdout.eof? && stderr.eof? && !wait_thr.alive?
            read_available_output(stderr) do |stderr_line|
              logger.warn { stderr_line } 
            end

            read_available_output(stdout) do |stdout_line|
              logger.debug { stdout_line } 
            end

            wait_thr.join(0.001)
          end

          exit_status = wait_thr.value

          #fail "Not handled yet" unless exit_status.success?
        end

        output_file
      end

      def read_available_output(io, &block)
        data = String.new

        loop do
          read_data = io.read_nonblock(1024, exception: false)

          break if read_data == :wait_readable

          break if read_data.nil?

          data.concat(read_data)
        end

        return if data.empty?

        stringio = StringIO.new(data)

        until stringio.eof?
          line = stringio.gets

          line.chomp!

          block.(line)
        end

        data
      end

      def output_file
        @output_file ||= File.join(output_dir, "#{name}-#{version}.deb")
      end

      def stage_dir
        @stage_dir ||= File.join(output_dir, "#{name}-#{version}")
      end

      def control_file
        @control_file ||= File.join(stage_dir, 'DEBIAN', 'control')
      end
    end
  end
end
