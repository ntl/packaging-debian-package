module Packaging
  module Debian
    class Package
      module Controls
        module Package
          module Queries
            module GetMetadata
              def self.call(deb_file)
                text = `dpkg-deb -f #{deb_file}`

                ::Transform::Read.(text, :rfc822, Schemas::Package)
              end
            end
          end
        end
      end
    end
  end
end
