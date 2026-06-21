class Netch < Formula
  desc "neofetch-style network info tool"
  homepage "https://github.com/realnishil/netch"
  url "https://github.com/realnishil/netch/archive/refs/tags/v1.0.0.tar.gz"
  sha256 "e0fa6f5516db6b588908cea210de609e739e43f17db1b5f74d4abdd59d2a6505"
  license "MIT"

  def install
    bin.install "netch.sh" => "netch"
  end
end
