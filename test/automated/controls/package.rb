require_relative '../automated_init'

context "Controls" do
  context "Package" do
    contents = Controls::Contents.example
    package_name = Controls::Package.name
    version = Controls::Package.version

    package = Controls::Package.example(
      package_name: package_name,
      version: version,
      contents: contents
    )

    test "Is path" do
      assert(package.is_a?(String))
    end

    context "Extract" do
      dir = Controls::Directory.random

      Controls::Package::Extract.(package, directory: dir)

      context "Contents" do
        Fixtures::Contents.(dir, contents)
      end
    end
  end
end
