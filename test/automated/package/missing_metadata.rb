require_relative '../automated_init'

context "Package" do
  context "Missing Metadata File" do
    package_name = Controls::Package.package

    package_definition_dir = Controls::PackageDefinition.example(metadata: :none)
    package_definition_root = File.expand_path('..', package_definition_dir)

    prepare_script = File.join(package_definition_dir, 'prepare.sh')
    assert(File.exist?(prepare_script))

    metadata_file = File.join(package_definition_dir, 'metadata')
    refute(File.exist?(metadata_file))

    tarball = Controls::Tarball.example(package_name: package_name)

    package = Package.build(tarball)

    package.default_architecture = 'i386'
    package.default_description = 'Some default description'
    package.maintainer = 'Some maintainter <some.maintainer@example.com>'

    package.package_definition_root = package_definition_root

    deb_file = nil

    test "Does not raise error" do
      refute proc { deb_file = package.() } do
        raises_error?
      end
    end

    context "Assigned Metadata" do
      metadata = Packaging::Debian::Schemas::Package::Read.(deb_file)

      test "Maintainer" do
        assert(metadata.maintainer == package.maintainer)
      end

      test "Architecture" do
        assert(metadata.architecture == package.default_architecture)
      end

      test "Description" do
        assert(metadata.description == package.default_description)
      end
    end
  end
end
