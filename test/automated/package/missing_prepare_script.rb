require_relative '../automated_init'

context "Package" do
  context "Missing Prepare Script" do
    package_name = Controls::Package.name

    package_definition_dir = Controls::PackageDefinition.example(prepare_script: :none)
    package_definition_root = File.expand_path('..', package_definition_dir)

    prepare_script = File.join(package_definition_dir, 'prepare.sh')
    refute(File.exist?(prepare_script))

    tarball = Controls::Tarball.example(package_name: package_name)

    package = Package.build(tarball)

    package.package_definition_root = package_definition_root

    test "Raises error" do
      assert proc { package.() } do
        raises_error?(Package::PackageFailure)
      end
    end
  end
end
