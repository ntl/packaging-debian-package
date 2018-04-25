module Packaging
  module Debian
    class Package
      include Log::Dependency

      attr_writer :root_dir
      def root_dir
        @root_dir ||= Dir.mktmpdir('packaging-debian-package')
      end

      initializer :tarball, :package_name, :package_version

      setting :package_definition_root

      def configure(root_dir: nil, settings: nil, namespace: nil)
        settings ||= Settings.build
        namespace = Array(namespace)

        settings.set(self, *namespace)

        unless root_dir.nil?
          root_dir = File.absolute_path(root_dir)

          self.root_dir = root_dir
        end
      end

      def self.build(tarball, root_dir: nil, settings: nil, namespace: nil)
        package_name, package_version = parse_tarball_filename(tarball)

        instance = new(tarball, package_name, package_version)
        instance.configure(root_dir: root_dir, settings: settings, namespace: namespace)
        instance
      end

      def self.call(tarball, root_dir: nil, settings: nil, namespace: nil)
        instance = build(tarball, root_dir: root_dir, settings: settings, namespace: namespace)
        instance.()
      end

      def call
        logger.trace { "Preparing package (#{LogText.attributes(self)})" }

        Tarball::Extract.(tarball, root_dir)

        package = nil

        Dir.mkdir(deb_dir)
        Dir.mkdir(stage_dir)
        Dir.mkdir(File.join(stage_dir, 'DEBIAN'))

        success, exit_status = nil, nil

        Dir.chdir(package_definition_dir) do
          metadata_text = File.read('metadata')

          package = Transform::Read.(metadata_text, :rfc822, Schemas::Package)

          success, exit_status = ShellCommand::Execute.(
            [ 'sh', '-e', 'prepare.sh', source_dir, stage_dir],
            include: :exit_status,
            logger: logger
          )
        end

        unless success
          error_message = "Package preparation failed (#{LogText.attributes(self)}, Exit Status: #{exit_status})"
          logger.error { error_message }
          return
        end

        package.package ||= package_name
        package.version ||= package_version

        control_file_text = Transform::Write.(package, :rfc822)

        File.write(
          File.join(stage_dir, 'DEBIAN', 'control'),
          control_file_text
        )

        logger.info { "Package prepared (#{LogText.attributes(self)})" }
      end

      def source_dir
        @source_dir ||= File.join(root_dir, "#{package_name}-#{package_version}")
      end

      def stage_dir
        @stage_dir ||= File.join(root_dir, 'deb', "#{package_name}-#{package_version}")
      end

      def deb_dir
        @deb_dir ||= File.join(root_dir, 'deb')
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
