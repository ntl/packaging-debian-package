require_relative '../automated_init'

context "Package" do
  context "Packaged" do
    name = Controls::Package.name
    version = Controls::Package.version
    maintainer = Controls::Package.maintainer

    contents = Controls::Package::Contents.example

    tarball = Controls::Tarball.example(
      package_name: name,
      version: version,
      contents: contents
    )

    package = Package.build(tarball, name, version)
    package.maintainer = maintainer

    output_dir = package.output_dir

    comment "Output Directory: #{output_dir}"

    package.()

    context "Debian Package" do
      deb_file = File.join(output_dir, "#{name}-#{version}.deb")

      test "File exists and contains data" do
        assert(File.size?(deb_file))
      end

      context "Metadata" do
        metadata = Controls::Package::Queries::GetMetadata.(deb_file)

        refute(metadata.nil?)

        test "Package name" do
          assert(metadata.name == name)
        end

        test "Package version" do
          assert(metadata.version == version)
        end

        test "Description is set to default" do
          assert(metadata.description == Package::Defaults.description)
        end

        test "Architecture is set to default" do
          assert(metadata.architecture == Package::Defaults.architecture)
        end
      end

      context "Contents" do
        contents_dir = Controls::Package::Extract.(deb_file)

        comment "Directory: #{contents_dir}"

        contents.each do |path, control_data|
          full_path = File.join(contents_dir, path)

          context "Entry: #{path}" do
            if control_data == Dir
              test "Is directory" do
                assert(File.directory?(full_path))
              end
            else
              test "Exists and has non-zero size" do
                assert(File.size?(full_path))
              end

              test "Data" do
                data = File.read(full_path)

                assert(data == control_data)
              end
            end
          end
        end
      end
    end
  end
end
