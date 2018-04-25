require_relative '../automated_init'

context "Prepare" do
  context "Package is Prepared" do
    package_name = Controls::Package.name
    version = Controls::Package.upstream_version

    tarball = Controls::Tarball.example(package_name: package_name, version: version)

    root_dir = Dir.mktmpdir('some-stage-dir')

    Package::Package.(tarball, root_dir: root_dir)

    context "Staged Contents" do
      stage_dir = File.join(root_dir, "deb/#{package_name}-#{version}")

      control_contents = Controls::Contents::Staged.example

      Fixtures::Contents.(stage_dir, control_contents)
    end
  end
end
