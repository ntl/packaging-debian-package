module Packaging
  module Debian
    class Package
      module Controls
        module Package
          module ControlFile
            extend Packaging::Debian::Schemas::Controls::Package::Data

            def self.example(**attributes)
              package = Packaging::Debian::Schemas::Controls::Package.example(**attributes)

              ::Transform::Write.(package, :rfc822)
            end
          end
        end
      end
    end
  end
end
