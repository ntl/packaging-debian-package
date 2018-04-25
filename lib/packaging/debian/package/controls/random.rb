module Packaging
  module Debian
    class Package
      module Controls
        module Random
          def self.unique_text
            hex = SecureRandom.hex(7)
            hex.to_i(16).to_s(36)
          end
        end
      end
    end
  end
end
