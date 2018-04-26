module Packaging
  module Debian
    class Package
      module Controls
        module PackageDefinition
          def self.example(package_name: nil, prepare_script: nil, metadata: nil)
            if prepare_script == :none
              prepare_script = nil
            else
              prepare_script ||= PrepareScript.example
            end

            if metadata == :none
              metadata = nil
            else
              metadata ||= Metadata.example
            end

            package_name ||= Controls::Package.name

            package_definition_root = Controls::Directory.random
            package_definition_dir = File.join(package_definition_root, package_name)

            Dir.mkdir(package_definition_dir)

            unless prepare_script.nil?
              prepare_script_file = File.join(package_definition_dir, 'prepare.sh')

              File.write(prepare_script_file, prepare_script)
            end

            unless metadata.nil?
              metadata_file = File.join(package_definition_dir, 'metadata')

              File.write(metadata_file, metadata)
            end

            package_definition_dir
          end

          module PrepareScript
            def self.example
              %{cp -a -v $1/* $2}
            end
          end

          module Metadata
            def self.example
              metadata = Package::Metadata.example
              metadata.package = nil
              metadata.version = nil

              Transform::Write.(metadata, :rfc822)
            end
          end
        end
      end
    end
  end
end
