module Packaging
  module Debian
    class Package
      module Controls
        module Contents
          def self.example
            [
              { 'some-path/some-file.txt' => "Example debian package\n" },
              'other-path'
            ]
          end

          module Staged
            def self.example
              control_file = Package::ControlFile.example

              [
                {
                  'some-path/some-file.txt' => "Example debian package\n",
                  'example-asset' => "Example asset contents\n",
                  'DEBIAN/control' => control_file,
                },
                'other-path'
              ]
            end
          end

          module Alternate
            def self.example
              [
                { 'some-path/other-file.txt' => "Example debian package (Alternate)\n" }
              ]
            end
          end
        end
      end
    end
  end
end
