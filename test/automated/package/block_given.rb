require_relative '../automated_init'

context "Package" do
  context "Block Given" do
    name = Controls::Package.name
    version = Controls::Package.version

    control_metadata = Controls::Package::Metadata::Alternate.example

    contents = Controls::Package::Contents.example

    tarball_io = Controls::Tarball.example

    package = Package.build(tarball_io, name, version)

    package.output_dir = Dir.mktmpdir

    package.() do |metadata|
      SetAttributes.(metadata, control_metadata)
    end

    test "Metadata set in block is written to package" do
      deb_file_path = package.output_file

      metadata = Controls::Package::Queries::GetMetadata.(deb_file_path)

      assert(metadata == control_metadata)
    end
  end
end
