require_relative '../../automated_init'

context "Tarball" do
  context "Extract" do
    context "IO is Closed" do
      contents = Controls::Contents.example

      tarball = Controls::Tarball.example
      tarball.close

      test "Raises error" do
        assert proc { Package::Tarball::Extract.(tarball) } do
          raises_error?(Package::Tarball::Extract::ClosedError)
        end
      end
    end
  end
end
