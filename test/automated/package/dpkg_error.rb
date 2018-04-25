require_relative '../automated_init'

context "Package" do
  context "Dpkg error" do
    name = Controls::Package.name
    version = Controls::Package.version
    maintainer = Controls::Package.maintainer

    tarball_io = Controls::Tarball::IO.example

    package = Package.build(tarball_io, name, version)

    execute_shell_command = Dependency::Substitute.(:execute_shell_command, package)

    execute_shell_command.failure!

    test "Raises error" do
      action = proc {
        package.() do |metadata|
          metadata.package = nil
        end
      }

      assert action do
        raises_error?(Package::PackagingError)
      end
    end
  end
end
