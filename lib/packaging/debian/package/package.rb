module Packaging
  module Debian
    class Package
      include Log::Dependency

      attr_writer :root_dir
      def root_dir
        @root_dir ||= Dir.mktmpdir('prepare-package')
      end

      dependency :execute_shell_command, ShellCommand::Execute
      dependency :extract_tarball, Tarball::Extract

      initializer :tarball

      setting :packages_directory

      def configure(root_dir: nil, settings: nil, namespace: nil)
        settings ||= Settings.build
        namespace = Array(namespace)

        settings.set(self, *namespace)

        self.root_dir = root_dir unless root_dir.nil?

        ShellCommand::Execute.configure(self, logger: logger)
        Tarball::Extract.configure(self, tarball, self.root_dir)
      end

      def self.build(tarball, root_dir: nil, settings: nil, namespace: nil)
        instance = new(tarball)
        instance.configure(root_dir: root_dir, settings: settings, namespace: namespace)
        instance
      end

      def self.call(tarball, root_dir: nil, settings: nil, namespace: nil)
        instance = build(tarball, root_dir: root_dir, settings: settings, namespace: namespace)
        instance.()
      end

      def call
        logger.trace { "Preparing package (#{LogText.attributes(self)})" }

        extract_tarball.()

        package = nil

        Dir.mkdir(deb_dir)
        Dir.mkdir(stage_dir)
        Dir.mkdir(File.join(stage_dir, 'DEBIAN'))

        success, exit_status = nil, nil

        Dir.chdir(package_definition_dir) do
          metadata_text = File.read('metadata')

          package = Transform::Read.(metadata_text, :rfc822, Schemas::Package)

          success, exit_status = execute_shell_command.(
            [ 'sh', '-e', 'prepare.sh', source_dir, stage_dir],
            include: :exit_status
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

      def package_name
        parsed_tarball[0]
      end

      def package_version
        parsed_tarball[1]
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

      def parsed_tarball
        @parsed_tarball ||=
          begin
            basename = File.basename(tarball, '.tar.gz')

            package_name, _ , version = basename.rpartition('-')

            [package_name, version]
          end
      end

      def package_definition_dir
        @package_definition_dir ||= File.join(packages_directory, package_name)
      end

      module LogText
        def self.attributes(prepare)
          "Package: #{prepare.package_name}, Version: #{prepare.package_version}"
        end
      end
    end
  end
end
