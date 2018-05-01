module Packaging
  module Debian
    class Package
      class Log < ::Log
        def tag!(tags)
          tags << :packaging_debian_package
          tags << :packaging
          tags << :library
          tags << :verbose
        end
      end
    end
  end
end
