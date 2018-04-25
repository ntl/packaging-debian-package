require_relative '../automated_init'

context "Extract Tarball" do
  context "GZip Error" do
    contents = Controls::Contents.example

    context "Empty String" do
      data_stream = StringIO.new

      test "Raises error" do
        assert proc { Package::Tarball::Extract.(data_stream) } do
          raises_error?(Package::Tarball::Extract::GZipError)
        end
      end
    end

    context "Format Error" do
      tarball = Controls::Tarball::Malformed::GZip.example

      test "Raises error" do
        assert proc { Package::Tarball::Extract.(tarball) } do
          raises_error?(Package::Tarball::Extract::GZipError)
        end
      end
    end
  end
end