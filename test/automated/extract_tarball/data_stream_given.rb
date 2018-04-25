require_relative '../automated_init'

context "Extract Tarball" do
  context "Data Stream Given" do
    contents = Controls::Contents.example

    data_stream = Controls::Tarball::DataStream.example(contents: contents)

    output_dir = Package::Tarball::Extract.(data_stream)

    test "Data stream is closed" do
      assert(data_stream.closed?)
    end

    context "Contents" do
      prefix_directory = Controls::Tarball::PrefixDirectory.example

      tarball_root = File.join(output_dir, prefix_directory)

      Fixtures::Contents.(tarball_root, contents)
    end
  end
end
