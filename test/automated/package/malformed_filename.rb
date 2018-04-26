require_relative '../automated_init'

context "Package" do
  context "Malformed Filename" do
    context "Incorrect Extension" do
      filename = 'some-package-1.1.1.tar.bz2'

      test "Raises error" do
        assert proc { Package.(filename) } do
          raises_error?(Package::MalformedFilenameError)
        end
      end
    end

    context "Missing Extension" do
      filename = 'some-package-1.1.1'

      test "Raises error" do
        assert proc { Package.(filename) } do
          raises_error?(Package::MalformedFilenameError)
        end
      end
    end

    context "No Version" do
      filename = '1.1.1.tar.gz'

      test "Raises error" do
        assert proc { Package.(filename) } do
          raises_error?(Package::MalformedFilenameError)
        end
      end
    end

    context "No Package Name" do
      filename = 'some-package.tar.gz'

      test "Raises error" do
        assert proc { Package.(filename) } do
          raises_error?(Package::MalformedFilenameError)
        end
      end
    end
  end
end
