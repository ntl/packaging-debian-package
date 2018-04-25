module Packaging
  module Debian
    class Package
      include Log::Dependency

      attr_writer :stage_dir
      def stage_dir
        @stage_dir ||= Dir.mktmpdir('packaging-debian-package')
      end

      attr_writer :preserve
      def preserve
        @preserve = false if @preserve.nil?
        @preserve
      end

      initializer :tarball, :package_name, :package_version

      setting :package_definition_root

      def configure(stage_dir: nil, preserve: nil, settings: nil, namespace: nil)
        settings ||= Settings.build
        namespace = Array(namespace)

        settings.set(self, *namespace)

        self.preserve = preserve unless preserve.nil?

        unless stage_dir.nil?
          stage_dir = File.absolute_path(stage_dir)

          self.stage_dir = stage_dir
        end
      end

      def self.build(tarball, stage_dir: nil, preserve: nil, settings: nil, namespace: nil)
        package_name, package_version = parse_tarball_filename(tarball)

        instance = new(tarball, package_name, package_version)
        instance.configure(stage_dir: stage_dir, preserve: preserve, settings: settings, namespace: namespace)
        instance
      end

      def self.call(tarball, stage_dir: nil, preserve: nil, settings: nil, namespace: nil)
        instance = build(tarball, stage_dir: stage_dir, preserve: preserve, settings: settings, namespace: namespace)
        instance.()
      end

      def call
        logger.trace { "Building package (#{LogText.attributes(self)})" }

        Tarball::Extract.(tarball, stage_dir)

        package = nil

        Dir.mkdir(output_dir)
        Dir.mkdir(package_root)
        Dir.mkdir(File.join(package_root, 'DEBIAN'))

        success, exit_status = nil, nil

        Dir.chdir(package_definition_dir) do
          metadata_text = File.read('metadata')

          package = Transform::Read.(metadata_text, :rfc822, Schemas::Package)

          success, exit_status = ShellCommand::Execute.(
            [ 'sh', '-e', 'prepare.sh', source_dir, package_root],
            include: :exit_status,
            logger: logger
          )
        end

        unless success
          error_message = "Package preparation failed (#{LogText.attributes(self)}, Exit Status: #{exit_status})"
          logger.error { error_message }
          return # XXX
        end

        package.package ||= package_name
        package.version ||= package_version

        control_file_text = Transform::Write.(package, :rfc822)

        File.write(
          File.join(package_root, 'DEBIAN', 'control'),
          control_file_text
        )

        success, exit_status = ShellCommand::Execute.(
          ['dpkg-deb', '-v', '--build', package_root],
          include: :exit_status,
          logger: logger
        )

        unless success
          error_message = "Failed to build .deb file (#{LogText.attributes(self)}, Exit Status: #{exit_status})"
          logger.error { error_message }
          return # XXX
        end

        package_file = File.join(output_dir, "#{package_name}-#{package_version}.deb")

        unless preserve
          FileUtils.rm_rf(source_dir)
          FileUtils.rm_rf(package_root)
        end

        logger.info { "Package built (#{LogText.attributes(self)}, File: #{package_file})" }

        package_file
      end

      def source_dir
        @source_dir ||= File.join(stage_dir, "#{package_name}-#{package_version}")
      end

      def package_root
        @package_root ||= File.join(stage_dir, 'deb', "#{package_name}-#{package_version}")
      end

      def output_dir
        @output_dir ||= File.join(stage_dir, 'deb')
      end

      def package_definition_dir
        @package_definition_dir ||= File.join(package_definition_root, package_name)
      end

      def self.parse_tarball_filename(filename)
        basename = File.basename(filename, '.tar.gz')

        package_name, _ , package_version = basename.rpartition('-')

        return package_name, package_version
      end

      module LogText
        def self.attributes(prepare)
          "Package: #{prepare.package_name}, Version: #{prepare.package_version}"
        end
      end
    end
  end
end
