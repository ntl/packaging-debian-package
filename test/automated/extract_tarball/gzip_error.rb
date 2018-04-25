require_relative '../automated_init'

context "Extract Tarball" do
  context "GZip Error" do
    contents = Controls::Contents.example

    context "Empty String" do
      tarball_io = StringIO.new

      test "Raises error" do
        assert proc { Package::Tarball::Extract.(tarball_io) } do
          raises_error?(Package::Tarball::Extract::GZipError)
        end
      end
    end

    context "Format Error" do
      tarball_io = Controls::Tarball::IO::GZipError.example

      test "Raises error" do
        assert proc { Package::Tarball::Extract.(tarball_io) } do
          raises_error?(Package::Tarball::Extract::GZipError)
        end
      end
    end
  end
end
