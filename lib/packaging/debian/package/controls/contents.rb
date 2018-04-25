module Packaging
  module Debian
    class Package
      module Controls
        module Contents
          def self.example
            {
              'some-path/some-file.txt' => "Example debian package\n",
              'other-path' => Dir
            }
          end

          module Alternate
            def self.example
              {
                'some-path/other-file.txt' => "Example debian package (Alternate)\n"
              }
            end
          end
        end

        module Package
          Contents = Controls::Contents
        end
      end
    end
  end
end
