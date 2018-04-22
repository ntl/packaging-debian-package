require_relative '../automated_init'

context "Controls" do
  context "Package" do
    deb_file = Controls::Package.example

    comment "File location: #{deb_file}"

    test "Is file" do
      assert(File.size?(deb_file))
    end

    test "Is debian package" do
      assert((File.extname(deb_file)) == '.deb')
    end

    test "Metadata" do
      metadata = Controls::Package::Queries::GetMetadata.(deb_file)

      control_metadata = Controls::Package::Metadata.example

      assert(metadata == control_metadata)
    end

    context "Contents" do
      control_contents = Controls::Package::Contents.example

      extract_dir = Dir.mktmpdir

      `dpkg-deb -x #{deb_file} #{extract_dir}`

      control_contents.each do |file, data|
        path = File.join(extract_dir, file)

        if data == Dir
          test "#{path}" do
            assert(File.directory?(path))
          end
        else
          read_data = File.read(path)

          test "#{file}" do
            assert(data == read_data)
          end
        end
      end
    end
  end
end
