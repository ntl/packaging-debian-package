require_relative '../automated_init'

context "Package" do
  context "Packaged" do
    name = Controls::Package.name
    version = Controls::Package.version
    maintainer = Controls::Package.maintainer

    contents = Controls::Package::Contents.example

    tarball_io = Controls::Tarball.example(package_name: name, version: version, contents: contents)

    package = Package.new(tarball_io, name, version)
    package.maintainer = maintainer

    output_dir = Dir.mktmpdir

    package.output_dir = output_dir

    comment "Output Directory: #{output_dir}"

    package.()

    context "Debian Package" do
      deb_file_path = package.output_file

      test "File exists and contains data" do
        assert(File.size?(deb_file_path))
      end

      context "Metadata" do
        metadata = Controls::Package::Queries::GetMetadata.(deb_file_path)

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
    end
  end
end
