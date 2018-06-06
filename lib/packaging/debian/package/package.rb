module Packaging
  module Debian
    class Package
      include Log::Dependency

      configure :package

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
      setting :default_description
      setting :default_architecture
      setting :maintainer

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

        unless File.directory?(package_definition_dir)
          error_message = "Cannot find package definition (#{LogText.attributes(self)}, Directory: #{package_definition_dir})"
          logger.error { error_message }
          raise UnknownPackageError, error_message
        end

        Tarball::Extract.(tarball, stage_dir)

        package = nil

        Dir.mkdir(output_dir)
        Dir.mkdir(package_root)
        Dir.mkdir(File.join(package_root, 'DEBIAN'))

        relative_source_dir = relative_path(source_dir, package_definition_dir)
        relative_package_root = relative_path(package_root, package_definition_dir)

        Dir.chdir(package_definition_dir) do
          success, exit_status = ShellCommand::Execute.(
            [ 'sh', '-e', 'prepare.sh', relative_source_dir, relative_package_root],
            include: :exit_status,
            logger: logger
          )

          unless success
            error_message = "Package preparation failed (#{LogText.attributes(self)}, Exit Status: #{exit_status})"
            logger.error { error_message }
            raise PackageFailure, error_message
          end

          if File.size?('metadata')
            metadata_text = File.read('metadata')

            package = Transform::Read.(metadata_text, :rfc822, Schemas::Package)
          else
            package = Schemas::Package.new
          end
        end

        package.package ||= debian_package_name
        package.version ||= package_version
        package.description ||= default_description
        package.architecture ||= default_architecture
        package.maintainer ||= maintainer

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
          raise PackageFailure, error_message
        end

        package_basename = "#{package_name}-#{package_version}.deb"

        temporary_package_file = File.join(output_dir, package_basename)

        package_file = File.join(stage_dir, package_basename)

        FileUtils.mv(temporary_package_file, package_file)

        unless preserve
          FileUtils.rm_rf(source_dir)
          FileUtils.rm_rf(output_dir)
        end

        logger.info { "Package built (#{LogText.attributes(self)}, File: #{package_file})" }

        package_file
      end

      def relative_path(target, source)
        source_path = Pathname(source)
        source_path = source_path.expand_path unless source_path.absolute?

        target_path = Pathname(target)
        target_path = target_path.expand_path unless target_path.absolute?

        relative_path = target_path.relative_path_from(source_path)

        relative_path.to_s
      end

      def debian_package_name
        @debian_package_name ||= package_name.gsub('_', '-')
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
        @package_definition_dir ||= File.join(package_definition_root, debian_package_name)
      end

      def self.parse_tarball_filename(filename)
        unless filename.end_with?('.tar.gz')
          error_message = "Specified file name does not have .tar.gz extension (Filename: #{filename.inspect})"
          logger.error { error_message }
          raise MalformedFilenameError, error_message
        end

        basename = File.basename(filename, '.tar.gz')

        package_name, _ , package_version = basename.rpartition('-')

        if package_name.empty? || !package_version.match?(/[[:digit:]]/)
          error_message = "Specified file name does not include a version (Filename: #{filename.inspect})"
          logger.error { error_message }
          raise MalformedFilenameError, error_message
        end

        return package_name, package_version
      end

      def self.logger
        @logger ||= Log.get(self)
      end

      MalformedFilenameError = Class.new(StandardError)
      PackageFailure = Class.new(StandardError)
      UnknownPackageError = Class.new(StandardError)

      module LogText
        def self.attributes(prepare)
          "Package: #{prepare.debian_package_name.inspect}, Version: #{prepare.package_version.inspect}"
        end
      end
    end
  end
end
