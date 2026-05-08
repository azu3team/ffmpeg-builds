# ffmpeg-builds

[Sucolab](https://sucolab.jp) 用 FFmpeg LGPL ビルド。

## ダウンロード

[Releases](https://github.com/azu3team/ffmpeg-builds/releases) から最新版をダウンロード。

| プラットフォーム | ファイル | ビルド方式 |
|---|---|---|
| macOS arm64 (Apple Silicon) | `ffmpeg-lgpl-darwin-arm64.tar.gz` | ソースビルド |
| Windows x64 | `ffmpeg-lgpl-win32-x64.zip` | BtbN LGPL リパッケージ |

## ライセンス

- **FFmpeg バイナリ**: LGPL-2.1 (GPL コーデック不使用)
- **ビルドスクリプト**: MIT ([mifi/ffmpeg-build-script](https://github.com/mifi/ffmpeg-build-script) ベース)

### 含まれるコーデック/機能

| コーデック | ライセンス | 用途 |
|---|---|---|
| VideoToolbox (macOS) | Apple Framework | HW H.264/HEVC エンコード |
| libvpx | BSD | VP8/VP9 |
| libwebp | BSD | WebP |
| dav1d | BSD | AV1 デコード |
| SVT-AV1 | BSD | AV1 エンコード |
| OpenSSL | Apache-2.0 | HTTPS |

### 含まれないもの (GPL)

- x264 (H.264 ソフトウェアエンコーダ)
- x265 (HEVC ソフトウェアエンコーダ)
- libmp3lame (MP3 エンコーダ)

## ビルド

### macOS (ローカル)

```bash
brew install nasm yasm python-setuptools meson ninja
./build-ffmpeg-macos
# 出力: workspace/bin/ffmpeg, workspace/bin/ffprobe
```

### CI

タグをプッシュすると GitHub Actions で自動ビルド + リリース:

```bash
git tag v8.0-lgpl-1
git push origin v8.0-lgpl-1
```

## ASR POC capabilities

The release workflow verifies the LGPL build has the audio filters needed by
Sucolab ASR experiments:

- `silencedetect`, `silenceremove`
- `loudnorm`, `speechnorm`, `volume`
- `highpass`, `lowpass`, `afftdn`, `arnndn`, `anequalizer`
- `atrim`, `asetpts`, `aresample`

Run locally:

```bash
./verify-asr-poc-filters.sh ./workspace/bin/ffmpeg
./verify-asr-poc-filters.sh ./dist/ffmpeg.exe strings
```
