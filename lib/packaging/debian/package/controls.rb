require 'rubygems'
require 'rubygems/package'

require 'tmpdir'
require 'open3'

require 'packaging/debian/schemas/controls'

require 'packaging/debian/package/controls/contents'

require 'packaging/debian/package/controls/tarball'
require 'packaging/debian/package/controls/tarball/io'

require 'packaging/debian/package/controls/package'
require 'packaging/debian/package/controls/package/control_file'
require 'packaging/debian/package/controls/package/extract'
require 'packaging/debian/package/controls/package/metadata'
require 'packaging/debian/package/controls/package/queries'
