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

    context "Control Information" do
      read_field = proc { |field|
        line = `dpkg-deb -f #{deb_file} | grep '^#{field}:'`.chomp

        _, value = line.split(/[[:blank:]]+/, 2)

        value
      }

      {
        'Package' => Controls::Package::ControlFile.package,
        'Source' => Controls::Package::ControlFile.source,
        'Version' => Controls::Package::ControlFile.version,
        'Section' => Controls::Package::ControlFile.section,
        'Priority' => Controls::Package::ControlFile.priority,
        'Architecture' => Controls::Package::ControlFile.architecture,
        'Essential' => Controls::Package::ControlFile.essential ? 'yes' : 'no',
        'Depends' => Controls::Package::ControlFile.depends,
        'Pre-Depends' => Controls::Package::ControlFile.pre_depends,
        'Recommends' => Controls::Package::ControlFile.recommends,
        'Suggests' => Controls::Package::ControlFile.suggests,
        'Enhances' => Controls::Package::ControlFile.enhances,
        'Breaks' => Controls::Package::ControlFile.breaks,
        'Conflicts' => Controls::Package::ControlFile.conflicts,
        'Installed-Size' => Controls::Package::ControlFile.installed_size.to_s,
        'Maintainer' => Controls::Package::ControlFile.maintainer,
        'Description' => Controls::Package::ControlFile.description,
        'Homepage' => Controls::Package::ControlFile.homepage,
        'Built-Using' => Controls::Package::ControlFile.built_using
      }.each do |field, control_value|
        test field do
          value = read_field.(field)

          comment "Value: #{value.inspect}"
          comment "Control: #{control_value.inspect}"

          assert(value == control_value)
        end
      end
    end

    context "Contents" do
      control_contents = Controls::Package::Contents.example

      extract_dir = Dir.mktmpdir

      `dpkg-deb -x #{deb_file} #{extract_dir}`

      control_contents.each do |file, data|
        path = File.join(extract_dir, file)

        read_data = File.read(path)

        test "#{file}" do
          assert(data == read_data)
        end
      end
    end
  end
end
