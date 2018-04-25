require_relative '../automated_init'

context "Package" do
  context "Block Given" do
    name = Controls::Package.name
    version = Controls::Package.upstream_version

    control_metadata = Controls::Package::Metadata::Alternate.example

    contents = Controls::Contents.example

    tarball = Controls::Tarball.example

    package = Package.build(tarball, name, version)

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
