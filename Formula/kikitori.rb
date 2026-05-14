class Kikitori < Formula
  include Language::Python::Virtualenv

  desc "macOS menu bar voice-to-text tool with overlay UI"
  homepage "https://github.com/konyu/kikitori"
  url "https://github.com/konyu/kikitori/archive/refs/tags/v1.0.0.tar.gz"
  sha256 "c494f62479cf3881979a9afaac70bad52f4b873433c6eae1a20053a72a72765a"
  license "MIT"

  depends_on "python@3.14"
  depends_on "ffmpeg"
  depends_on "portaudio"

  def install
    venv = virtualenv_create(libexec, "python3.14")
    venv.pip_install buildpath

    # requirements.txt から依存関係をインストール
    system libexec/"bin/pip", "install", "-r", buildpath/"requirements.txt"

    # エントリポイントスクリプト
    (bin/"kikitori").write <<~EOS
      #!/bin/bash
      export KIKITORI_HOME="#{opt_prefix}"
      exec "#{libexec}/bin/python" "#{opt_prefix}/pyside_main.py" "$@"
    EOS
  end

  service do
    run [opt_bin/"kikitori"]
    keep_alive true
    log_path var/"log/kikitori.log"
    error_log_path var/"log/kikitori.error.log"
  end

  test do
    system bin/"kikitori", "--version"
  end
end
