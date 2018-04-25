require_relative '../automated_init'

context "Package" do
  context "Packaged" do
    name = Controls::Package.name
    version = Controls::Package.upstream_version
    maintainer = Controls::Package.maintainer

    contents = Controls::Contents.example

    tarball = Controls::Tarball.example(
      package_name: name,
      version: version,
      contents: contents
    )

    package = Package.build(tarball, name, version)
    package.maintainer = maintainer

    output_dir = package.output_dir

    comment "Output Directory: #{output_dir}"

    package.()

    context "Debian Package" do
      deb_file = File.join(output_dir, "#{name}-#{version}.deb")

      test "File exists and contains data" do
        assert(File.size?(deb_file))
      end

      context "Metadata" do
        metadata = Controls::Package::Queries::GetMetadata.(deb_file)

        refute(metadata.nil?)

        test "Package name" do
          assert(metadata.name == name)
        end

        test "Package version" do
          assert(metadata.version == version)
        end

        test "Description is set to default" do
          assert(metadata.description == Package::Defaults.description)
        end

        test "Architecture is set to default" do
          assert(metadata.architecture == Package::Defaults.architecture)
        end
      end

      context "Contents" do
        contents_dir = Controls::Package::Extract.(deb_file)

        Fixtures::Contents.(contents_dir, contents)
      end
    end
  end
end
