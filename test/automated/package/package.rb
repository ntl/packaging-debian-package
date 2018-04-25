require_relative '../automated_init'

context "Package" do
  package_name = Controls::Package.name
  version = Controls::Package.upstream_version

  tarball = Controls::Tarball.example(package_name: package_name, version: version)

  root_dir = Controls::Directory.random

  Package::Package.(tarball, root_dir: root_dir)

  context "Staged Contents" do
    stage_dir = File.join(root_dir, "deb/#{package_name}-#{version}")

    control_contents = Controls::Contents::Staged.example

    Fixtures::Contents.(stage_dir, control_contents)
  end
end
