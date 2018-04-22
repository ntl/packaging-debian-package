module Packaging
  module Debian
    class Package
      class Settings < ::Settings
        def self.data_source
          'settings/debian_packaging.json'
        end
      end
    end
  end
end
