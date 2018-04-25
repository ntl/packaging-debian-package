require_relative '../automated_init'

context "Package" do
  context "Preserve Stage Directory" do
    package_name = Controls::Package.name
    version = Controls::Package.upstream_version

    tarball = Controls::Tarball.example(package_name: package_name, version: version)

    stage_dir = Controls::Directory.random

    Package::Package.(tarball, stage_dir: stage_dir, preserve: true)

    context "Source Contents" do
      source_dir = File.join(stage_dir, "#{package_name}-#{version}")

      control_contents = Controls::Contents.example

      Fixtures::Contents.(source_dir, control_contents)
    end

    context "Staged Contents" do
      stage_dir = File.join(stage_dir, "deb/#{package_name}-#{version}")

      control_contents = Controls::Contents::Staged.example

      Fixtures::Contents.(stage_dir, control_contents)
    end
  end
end
