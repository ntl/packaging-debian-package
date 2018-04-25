require_relative '../automated_init'

context "Package" do
  package_name = Controls::Package.name
  version = Controls::Package.upstream_version

  tarball = Controls::Tarball.example(package_name: package_name, version: version)

  stage_dir = Controls::Directory.random

  deb_file = Package::Package.(tarball, stage_dir: stage_dir)

  test "Path to debian file is returned" do
    control_deb_file = File.join(stage_dir, 'deb', "#{package_name}-#{version}.deb")

    assert(File.absolute_path(deb_file) == File.absolute_path(control_deb_file))
  end

  test "Debian file returned exists" do
    assert(File.size?(deb_file))
  end

  test "Stage directory is emptied of all files except package" do
    stage_files = Dir[File.join(stage_dir, '**/*')].map do |entry|
      File.absolute_path(entry)
    end

    control_stage_files = [File.dirname(deb_file), deb_file]

    assert(stage_files == control_stage_files)
  end

  context "Package" do
    context "Metadata"

    context "Contents"
  end
end
