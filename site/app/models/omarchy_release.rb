# The release a package version names, coarse enough that two machines on the
# same release share it and saying when it isn't the release itself:
# "4.0.0.alpha.quattro.r179...-1" is 4.0.0-alpha, a snapshot built from git
# ("4.0.0.r7547.gf2b8378-1") 4.0.0-dev, "4.5.0rc2-1" 4.5.0-rc2.
module OmarchyRelease
  PACKAGE_VERSION = /\A(\d+(?:\.\d+)*)(.*?)(?:-[\d.]+)?\z/
  PRERELEASE = /\A[.-]?(alpha|beta|rc)[.-]?(\d*)/i
  GIT_SNAPSHOT = /\.r\d+\.g\h+\z/

  def self.of(version)
    found = PACKAGE_VERSION.match(version) or return version
    number, qualifier = found.captures
    case qualifier
    when "" then number
    when PRERELEASE then "#{number}-#{$1.downcase}#{$2}"
    when GIT_SNAPSHOT then "#{number}-dev"
    else "#{number}-#{qualifier.sub(/\A[.-]/, "")}"
    end
  end
end
