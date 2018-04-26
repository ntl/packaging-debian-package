require_relative '../automated_init'

context "Package" do
  context "Unknown Package" do
    tarball = Controls::Tarball::Alternate.example

    test "Raises error" do
      assert proc { Package.(tarball) } do
        raises_error?(Package::UnknownPackageError)
      end
    end
  end
end
