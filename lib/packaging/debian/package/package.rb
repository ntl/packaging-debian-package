module Packaging
  module Debian
    class Package
      include Log::Dependency

      setting :maintainer

      dependency :extract_tarball, Tarball::Extract
      dependency :execute_shell_command, ShellCommand::Execute

      attr_writer :output_dir
      def output_dir
        @output_dir ||= File.join('tmp', "package-#{SecureRandom.alphanumeric}")
      end

      initializer :tarball_io, :name, :version

      def configure(settings=nil, namespace: nil)
        settings ||= Settings.build
        namespace = Array(namespace)

        settings.set(self, *namespace)

        Tarball::Extract.configure(self, tarball_io, output_dir)
        ShellCommand::Execute.configure(self, logger: logger)
      end

      def self.build(tarball, name, version, settings=nil, namespace: nil)
        instance = new(tarball, name, version)
        instance.configure(settings, namespace: nil)
        instance
      end

      def self.call(tarball, name, version, settings=nil, namespace: nil, &modify_metadata)
        instance = build(tarball, name, version, settings, namespace: namespace)
        instance.(&modify_metadata)
      end

      def call(&modify_metadata)
        logger.trace { "Building debian package (#{LogText.attributes(self)})" }

        extract_tarball.()

        write_control_file(&modify_metadata)

        file = generate_deb

        logger.info { "Debian package built (#{LogText.attributes(self)}, File: #{file.inspect})" }

        file
      end

      def write_control_file(&modify_metadata)
        metadata = Schemas::Package.new
        metadata.package = name
        metadata.version = version

        modify_metadata.(metadata) unless modify_metadata.nil?

        metadata.description ||= Defaults.description
        metadata.architecture ||= Defaults.architecture
        metadata.maintainer ||= self.maintainer

        Dir.mkdir(File.dirname(control_file))

        text = Transform::Write.(metadata, :rfc822)

        File.write(control_file, text)
      end

      def generate_deb
        command = %W[
          dpkg-deb -v --build #{stage_dir}
        ]

        logger.trace { "Generating debian package (File: #{output_file})" }
        logger.trace(tag: :command) { command * ' ' }

        success, exit_status = execute_shell_command.(command, include: :exit_status)

        unless success
          error_message = "Packaging failed; dpkg returned nonzero status (#{LogText.attributes(self)}, Value: #{exit_status})"
          logger.error { error_message }
          raise PackagingError, error_message
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

      module LogText
        def self.attributes(package)
          "Name: #{package.name}, Version: #{package.version}"
        end
      end

      PackagingError = Class.new(StandardError)
    end
  end
end
