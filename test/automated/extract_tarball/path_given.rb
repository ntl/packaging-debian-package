require_relative '../automated_init'

context "Extract Tarball" do
  context "Path Given" do
    contents = Controls::Contents.example

    tarball = Controls::Tarball.example(contents: contents)

    filename = File.basename(tarball)

    output_dir = Package::Tarball::Extract.(tarball)

    context "Contents" do
      prefix_directory = File.basename(filename, '.tar.gz')

      tarball_root = File.join(output_dir, prefix_directory)

      Fixtures::Contents.(tarball_root, contents)
    end
  end
end
