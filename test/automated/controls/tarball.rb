require_relative '../automated_init'

context "Controls" do
  context "Tarball" do
    contents = Controls::Contents.example
    package_name = Controls::Package.name
    version = Controls::Package.version

    tarball = Controls::Tarball.example(
      package_name: package_name,
      version: version,
      contents: contents
    )

    test "Is path" do
      assert(tarball.is_a?(String))
    end

    context "Extract" do
      dir = Dir.mktmpdir('tarball-control-test')

      filename = Controls::Tarball::Filename.example

      untar_command = %[tar -C #{dir} -v -x -f #{tarball}]

      comment("Command: #{untar_command}")

      Open3.popen2e(untar_command) do |_, output|
        until output.eof?
          comment("(output) #{output.gets.chomp}")
        end
      end

      context "Contents" do
        prefix_directory = Controls::Tarball::PrefixDirectory.example(
          package_name: package_name,
          version: version
        )

        untar_root = File.join(dir, prefix_directory)

        Fixtures::Contents.(untar_root, contents)
      end
    end
  end
end
