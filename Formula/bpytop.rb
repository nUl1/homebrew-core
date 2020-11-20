class Bpytop < Formula
  include Language::Python::Virtualenv

  desc "Linux/OSX/FreeBSD resource monitor"
  homepage "https://github.com/aristocratos/bpytop"
  url "https://files.pythonhosted.org/packages/ba/df/8d73c1134944116f96cd13cb82bf0295e0d1832450b783b023764b00d5a1/bpytop-1.0.50.tar.gz"
  sha256 "0a06b621d77b7b7223cef6421f6ceb04da4bfce20836d1c473ebfaa89dc1c838"
  license "Apache-2.0"

  bottle do
    cellar :any_skip_relocation
    sha256 "b39de73e084429f1e3b2f5276a3134f2075813b5810ebf2782617f7274fd23ca" => :big_sur
    sha256 "7f7ee5558e63a38d8944eb39161c648846bf6355966fc6be7d2437a2e8de734f" => :catalina
    sha256 "115ecf39c7e025c6a0a24d07ba8a214ddc67765f64edec049f0a5f6dcbad86d7" => :mojave
  end

  depends_on "python@3.9"
  on_macos do
    depends_on "osx-cpu-temp"
  end

  resource "psutil" do
    url "https://files.pythonhosted.org/packages/33/e0/82d459af36bda999f82c7ea86c67610591cf5556168f48fd6509e5fa154d/psutil-5.7.3.tar.gz"
    sha256 "af73f7bcebdc538eda9cc81d19db1db7bf26f103f91081d780bbacfcb620dee2"
  end

  def install
    virtualenv_install_with_resources
    pkgshare.install "bpytop-themes" => "themes"
  end

  test do
    config = (testpath/".config/bpytop")
    (config/"bpytop.conf").write <<~EOS
      #? Config file for bpytop v. #{version}

      update_ms=2000
      log_level=DEBUG
    EOS

    require "pty"
    require "io/console"

    r, w, pid = PTY.spawn("#{bin}/bpytop")
    r.winsize = [80, 130]
    sleep 5
    w.write "\cC"

    log = (config/"error.log").read
    assert_match "bpytop version #{version} started with pid #{pid}", log
    assert_not_match /ERROR:/, log
  ensure
    Process.kill("TERM", pid)
  end
end