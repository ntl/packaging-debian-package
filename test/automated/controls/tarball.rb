require_relative '../automated_init'

context "Controls" do
  context "Tarball" do
    contents = Controls::Package::Contents.example
    package_name = Controls::Package.name
    version = Controls::Package.version

    tarball = Controls::Tarball.example(package_name: package_name, version: version, contents: contents)

    test "Is StringIO" do
      assert(tarball.is_a?(StringIO))
    end

    context "Extract" do
      dir = Dir.mktmpdir

      filename = Controls::Tarball::Filename.example

      local_path = File.join(dir, filename)

      File.open(local_path, 'w') do |io|
        io.write(tarball.read) until tarball.eof?
      end

      untar_command = %[tar -C #{dir} -v -x -f #{local_path}]

      comment("Command: #{untar_command}")

      Open3.popen2e(untar_command) do |_, output|
        until output.eof?
          comment("(output) #{output.gets.chomp}")
        end
      end

      context "Contents" do
        package_dir = "#{package_name}-#{version}"

        test "Root package directory (#{package_dir})" do
          full_package_dir = File.join(dir, package_dir)

          assert(File.directory?(full_package_dir))
        end

        contents.each do |path, control_data|
          full_path = File.join(dir, package_dir, path)

          context "#{path}" do
            if control_data == Dir
              test "Is directory" do
                assert(File.directory?(full_path))
              end
            else
              test "Exists and has nonzero size" do
                assert(File.size?(full_path))
              end

              test "Data" do
                data = File.read(full_path)

                assert(data == control_data)
              end
            end
          end
        end
      end
    end
  end
end
