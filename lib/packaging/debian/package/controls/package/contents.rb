module Packaging
  module Debian
    class Package
      module Controls
        module Package
          module Contents
            def self.example
              {
                'some-path/some-file.txt' => "Example debian package\n"
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
        end
      end
    end
  end
end