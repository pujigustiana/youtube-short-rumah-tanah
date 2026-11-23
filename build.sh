#!/usr/bin/env bash
# build-v3.sh — Rakit video dokumenter v3 "Rumah di Dalam Lubang Tanah, Kok Bisa Adem?"
# 1080x1920 30fps H.264 + VO Indonesia + musik piano (CC BY, atribusi di README) + subtitle burn-in.
# Sumber: 4 klip Pexels (lisensi gratis) + VO TTS + "Meditation Impromptu 01" Kevin MacLeod.
# Pemakaian lokal:
#   FOOTAGE_DIR=../footage VO_DIR=vo MUSIC_FILE=music-meditation-impromptu-01.mp3 SRT_FILE=subtitles-v3.srt bash build-v3.sh rumah-tanah-adem-short-v3.mp4
# Pemakaian GitHub Actions (repo root): bash build.sh   (default: FOOTAGE_DIR=footage VO_DIR=assets/vo MUSIC_FILE=assets/music-meditation-impromptu-01.mp3 SRT_FILE=assets/subtitles-v3.srt)
set -euo pipefail
cd "$(dirname "$0")"

OUT="${1:-rumah-tanah-adem-short.mp4}"
FOOTAGE_DIR="${FOOTAGE_DIR:-footage}"
VO_DIR="${VO_DIR:-assets/vo}"
MUSIC_FILE="${MUSIC_FILE:-assets/music-meditation-impromptu-01.mp3}"
SRT_FILE="${SRT_FILE:-assets/subtitles-v3.srt}"
ASS_FILE="${ASS_FILE:-assets/subtitles-v3.ass}"
# Subtitle dipakai lewat filter ass (file .ass dibuat dari .srt oleh srt2ass.py;
# PlayRes 1080x1920, FontSize 56). JANGAN pakai filter subtitles + FontSize besar:
# libass menafsir FontSize relatif ke PlayResY 288 sehingga teks jadi raksasa.

SWEAT_URL="https://videos.pexels.com/video-files/4742595/4742595-uhd_2560_1440_25fps.mp4"
MORNING_URL="https://videos.pexels.com/video-files/20225586/20225586-hd_1080_1920_24fps.mp4"
INTERIOR_URL="https://videos.pexels.com/video-files/7578546/7578546-uhd_2560_1440_30fps.mp4"
ICED_URL="https://videos.pexels.com/video-files/8540461/8540461-hd_1080_1920_30fps.mp4"

mkdir -p "$FOOTAGE_DIR"
# Unduh klip Pexels bila belum ada (di Actions selalu diunduh; lokal sudah ada).
download_if_missing() {
  local file="$1" url="$2"
  if [ ! -s "$file" ]; then
    echo "Downloading $file ..."
    curl -sL -A "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0 Safari/537.36" -o "$file" "$url"
  else
    echo "Exists: $file"
  fi
}
download_if_missing "$FOOTAGE_DIR/sweat-4742595.mp4" "$SWEAT_URL"
download_if_missing "$FOOTAGE_DIR/morning-tea-20225586.mp4" "$MORNING_URL"
download_if_missing "$FOOTAGE_DIR/interior-7578546.mp4" "$INTERIOR_URL"
download_if_missing "$FOOTAGE_DIR/iced-tea-8540461.mp4" "$ICED_URL"

# Periksa semua input ada
for f in "$FOOTAGE_DIR/sweat-4742595.mp4" "$FOOTAGE_DIR/morning-tea-20225586.mp4" \
         "$FOOTAGE_DIR/interior-7578546.mp4" "$FOOTAGE_DIR/iced-tea-8540461.mp4" \
         "$VO_DIR/vo1.mp3" "$VO_DIR/vo2.mp3" "$VO_DIR/vo3.mp3" "$VO_DIR/vo4.mp3" "$VO_DIR/vo5.mp3" \
         "$MUSIC_FILE" "$SRT_FILE" "$ASS_FILE"; do
  [ -s "$f" ] || { echo "MISSING INPUT: $f" >&2; exit 1; }
done

# Timeline (durasi segmen sebelum crossfade 0.6 dtk):
#   S1 sweat 6.0 | S2 morning-tea 8.8 | S3 interior 8.3 | S4 iced-tea 9.3 | S5 interior 5.6
#   Total = 38.0 - 4x0.6 = 35.6 detik. VO mulai 0.3 / 5.7 / 13.9 / 21.6 / 30.3.
# CATATAN: iced-tea sebenarnya 720x1280 (bukan 1080 seperti nama file Pexels) -> upscale lanczos ke 1080x1920.
ffmpeg -y \
  -i "$FOOTAGE_DIR/sweat-4742595.mp4" \
  -i "$FOOTAGE_DIR/morning-tea-20225586.mp4" \
  -i "$FOOTAGE_DIR/interior-7578546.mp4" \
  -i "$FOOTAGE_DIR/iced-tea-8540461.mp4" \
  -i "$FOOTAGE_DIR/interior-7578546.mp4" \
  -i "$VO_DIR/vo1.mp3" -i "$VO_DIR/vo2.mp3" -i "$VO_DIR/vo3.mp3" -i "$VO_DIR/vo4.mp3" -i "$VO_DIR/vo5.mp3" \
  -i "$MUSIC_FILE" \
  -filter_complex "\
[0:v]trim=0:6,setpts=PTS-STARTPTS,crop=1215:2160:1312:0,scale=1080:1920,fps=30,format=yuv420p[v0];\
[1:v]trim=0:8.8,setpts=PTS-STARTPTS,scale=1080:1920,fps=30,format=yuv420p[v1];\
[2:v]trim=0:8.3,setpts=PTS-STARTPTS,crop=810:1440:875:0,scale=1080:1920,fps=30,format=yuv420p[v2];\
[3:v]trim=0:9.3,setpts=PTS-STARTPTS,scale=1080:1920:flags=lanczos,fps=30,format=yuv420p[v3];\
[4:v]trim=12:17.6,setpts=PTS-STARTPTS,crop=810:1440:875:0,scale=1080:1920,fps=30,format=yuv420p[v4];\
[v0][v1]xfade=transition=fade:duration=0.6:offset=5.4[x1];\
[x1][v2]xfade=transition=fade:duration=0.6:offset=13.6[x2];\
[x2][v3]xfade=transition=fade:duration=0.6:offset=21.3[x3];\
[x3][v4]xfade=transition=fade:duration=0.6:offset=30.0[x4];\
[x4]ass='$ASS_FILE'[vout];\
[5:a]aresample=48000,volume=1.17,adelay=300|300[a0];\
[6:a]aresample=48000,volume=2.11,adelay=5700|5700[a1];\
[7:a]aresample=48000,volume=1.10,adelay=13900|13900[a2];\
[8:a]aresample=48000,volume=0.86,adelay=21600|21600[a3];\
[9:a]aresample=48000,volume=0.89,adelay=30300|30300[a4];\
[10:a]atrim=0:36,aresample=48000,volume=0.22,afade=t=in:st=0:d=2,afade=t=out:st=33.6:d=2[a5];\
[a0][a1][a2][a3][a4][a5]amix=inputs=6:normalize=0,alimiter=limit=0.9,aresample=48000,aformat=channel_layouts=stereo[aout]" \
  -map "[vout]" -map "[aout]" \
  -c:v libx264 -preset veryfast -crf 20 -pix_fmt yuv420p -r 30 \
  -c:a aac -b:a 160k -ar 48000 -ac 2 \
  -movflags +faststart -t 35.6 "$OUT"

echo "DONE: $OUT"
ffprobe -v error -show_entries stream=codec_name,width,height,r_frame_rate,channels,sample_rate -show_entries format=duration,size -of default=noprint_wrappers=1 "$OUT"
