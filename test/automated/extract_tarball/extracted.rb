require_relative '../automated_init'

context "Extract Tarball" do
  context "Extracted" do
    contents = Controls::Contents.example
    tarball = Controls::Tarball.example(contents: contents)

    control_output_dir = Controls::Directory.random

    output_dir = Package::Tarball::Extract.(tarball, control_output_dir)

    test "Output directory is returned" do
      assert(output_dir == control_output_dir)
    end

    context "Contents" do
      prefix_directory = Controls::Tarball::PrefixDirectory.example

      tarball_root = File.join(output_dir, prefix_directory)

      Fixtures::Contents.(tarball_root, contents)
    end
  end
end
