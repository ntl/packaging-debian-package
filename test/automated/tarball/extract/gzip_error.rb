require_relative '../../automated_init'

context "Tarball" do
  context "Extract" do
    context "GZip Error" do
      contents = Controls::Contents.example

      context "Empty String" do
        tarball = StringIO.new

        test "Raises error" do
          assert proc { Package::Tarball::Extract.(tarball) } do
            raises_error?(Package::Tarball::Extract::GZipError)
          end
        end
      end

      context "Format Error" do
        tarball = Controls::Tarball::GZipError.example

        test "Raises error" do
          assert proc { Package::Tarball::Extract.(tarball) } do
            raises_error?(Package::Tarball::Extract::GZipError)
          end
        end
      end
    end
  end
end
