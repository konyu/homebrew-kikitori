class Kikitori < Formula
  desc "macOS menu bar voice-to-text tool with overlay UI"
  homepage "https://github.com/konyu/kikitori"
  url "https://github.com/konyu/kikitori.git",
      tag:      "v0.5.0",
      revision: "103b020f57bab1f5325c1e7b632e33203e7bda48"
  license "MIT"

  depends_on "python@3.14"
  depends_on "ffmpeg"
  depends_on "portaudio"

  # pip install にネットワークアクセスが必要
  allow_network_access! :build

  bottle do
    root_url "https://github.com/konyu/kikitori/releases/download/v0.5.0"
    sha256 arm64_sequoia: "9eeccaeb306adfff49c188dbbbbb915d4336c97d749d8824db7011b1e68cc436"
  end

  def install
    # 手動でvenv作成（pip付き）
    system Formula["python@3.14"].opt_bin/"python3.14", "-m", "venv", libexec

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
