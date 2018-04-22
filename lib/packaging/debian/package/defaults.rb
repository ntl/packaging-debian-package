module Packaging
  module Debian
    class Package
      module Defaults
        def self.architecture
          'amd64'
        end

        def self.description
          '(No description)'
        end
      end
    end
  end
end
