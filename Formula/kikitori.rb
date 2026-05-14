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
    # 仮想環境作成
    venv = virtualenv_create(libexec, "python3.14")

    # pip アップグレード
    system libexec/"bin/pip", "install", "--upgrade", "pip"

    # 依存関係インストール
    system libexec/"bin/pip", "install", "-r", buildpath/"requirements.txt"

    # アプリケーションファイルをコピー
    libexec.install Dir["*"]

    # ランチャースクリプト
    (bin/"kikitori").write <<~EOS
      #!/bin/bash
      exec "#{libexec}/bin/python" "#{libexec}/pyside_main.py" "$@"
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
