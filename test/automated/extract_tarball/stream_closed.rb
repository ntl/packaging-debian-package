require_relative '../automated_init'

context "Extract Tarball" do
  context "Data Stream is Closed" do
    contents = Controls::Contents.example
    output_dir = Controls::Directory.example

    data_stream = Controls::Tarball.stream
    data_stream.close

    test "Raises error" do
      assert proc { Package::Tarball::Extract.(data_stream, output_dir) } do
        raises_error?(Package::Tarball::Extract::ClosedError)
      end
    end
  end
end
