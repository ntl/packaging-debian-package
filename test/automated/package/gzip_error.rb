require_relative '../automated_init'

context "Package" do
  context "GZip error" do
    name = Controls::Package.name
    version = Controls::Package.version
    maintainer = Controls::Package.maintainer

    tarball_io = StringIO.new

    package = Package.new(tarball_io, name, version)
    package.maintainer = maintainer

    package.output_dir = Dir.mktmpdir

    test "Raises error" do
      assert proc { package.() } do
        raises_error?(Package::PackagingError)
      end
    end
  end
end
