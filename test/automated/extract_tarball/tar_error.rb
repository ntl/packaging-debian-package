require_relative '../automated_init'

context "Extract Tarball" do
  context "Tar Format Error" do
    contents = Controls::Contents.example

    tarball = Controls::Tarball::Malformed::Tar.example

    test "Raises error" do
      assert proc { Package::Tarball::Extract.(tarball) } do
        raises_error?(Package::Tarball::Extract::TarError)
      end
    end
  end
end
