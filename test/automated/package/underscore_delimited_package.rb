require_relative '../automated_init'

context "Package" do
  context "Underscore Delimited Package Name" do
    tarball = Controls::Tarball::UnderscoreDelimited.example

    stage_dir = Controls::Directory.random

    deb_file = Package.(tarball, stage_dir: stage_dir)

    test "Debian file returned exists" do
      assert(File.size?(deb_file))
    end

    context "Package" do
      test "Name has underscores converted to hyphens" do
        metadata = Packaging::Debian::Schemas::Package::Read.(deb_file)

        assert(metadata.package == 'some-package')
      end
    end
  end
end
