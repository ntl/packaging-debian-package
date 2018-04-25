module Fixtures
  class Contents
    include TestBench::Fixture

    initializer :directory, :control_contents

    def self.call(directory, control_contents)
      instance = new(directory, control_contents)
      instance.()
    end

    def call
      comment "Directory: #{directory}"

      control_contents.each do |relative_path, control_data|
        absolute_path = File.join(directory, relative_path)

        context "#{relative_path}" do
          if control_data == Dir
            test "Is directory" do
              assert(File.directory?(absolute_path))
            end
          else
            test "Is file" do
              assert(File.exist?(absolute_path))
            end

            test "Data" do
              read_data = File.read(absolute_path)

              comment "Read data: #{read_data.inspect}"
              comment "Control data: #{control_data.inspect}"

              assert(read_data == control_data)
            end
          end
        end
      end
    end
  end
end
