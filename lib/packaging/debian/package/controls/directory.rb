module Packaging
  module Debian
    class Package
      module Controls
        module Directory
          def self.example(random: nil)
            name = name(random: random)

            path = File.join('tmp', name)

            unless File.directory?(path)
              Dir.mkdir(path)
            end

            path
          end

          def self.name(random: nil)
            random = Random.unique_text if random == true

            if random
              "some-directory-#{random}"
            else
              "some-directory"
            end
          end

          def self.random
            example(random: true)
          end

          module Clear
            def self.call
              glob = "#{Directory.example}*"

              Dir[glob].each do |dir|
                FileUtils.rm_rf(dir, verbose: false)
              end
            end
          end
        end
      end
    end
  end
end
