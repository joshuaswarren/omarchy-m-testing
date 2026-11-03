require "test_helper"

class OmarchyReleaseTest < ActiveSupport::TestCase
  test "a package version names its release and whether it is the release itself" do
    {
      "4.0.2-2" => "4.0.2",
      "0.2.3-1" => "0.2.3",
      "4.0.0.alpha.quattro.r1790484851.g0052582276d9-1.362956774610001" => "4.0.0-alpha",
      "4.0.0.r7547.gf2b8378-1" => "4.0.0-dev",
      "4.0.4.r7099.gb8ed395-1" => "4.0.4-dev",
      "4.0.3rc4-1" => "4.0.3-rc4",
      "4.5.0rc2-1" => "4.5.0-rc2",
      "4.0.4-mac.1-2" => "4.0.4-mac.1",
      "not-a-version" => "not-a-version"
    }.each { |package, release| assert_equal release, OmarchyRelease.of(package), package }
  end

  test "pre-releases sort below their release" do
    releases = %w[4.0.0-dev 4.0.0 4.0.0-alpha 4.0.3-rc4].sort_by { |release| Gem::Version.new(release) }
    assert_equal %w[4.0.0-alpha 4.0.0-dev 4.0.0 4.0.3-rc4], releases
  end
end
