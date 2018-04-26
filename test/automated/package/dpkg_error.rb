require_relative '../automated_init'

context "Package" do
  context "Dpkg Error" do
    package_name = 'malformed_package_name'

    package_definition_dir = Controls::PackageDefinition.example(package_name: package_name)
    package_definition_root = File.expand_path('..', package_definition_dir)

    tarball = Controls::Tarball.example(package_name: package_name)

    package = Package.build(tarball)

    package.package_definition_root = package_definition_root

    test "Raises Exception" do
      assert proc { package.() } do
        raises_error?(Package::PackageFailure)
      end
    end
  end
end
