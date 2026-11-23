#!/bin/bash
set -e
cd "$(dirname "$0")"
for i in 1 2 3; do
  case $i in 1) f=assets/scene1-panas.webp;; 2) f=assets/scene2-adem.webp;; 3) f=assets/scene3-esteh.webp;; esac
  ffmpeg -y -v error -i "$f" -vf "scale=1080:1920,zoompan=z='min(zoom+0.0006,1.12)':x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)':d=182:s=1080x1920:fps=30,format=yuv420p" -t 6.07 -c:v libx264 -preset veryfast -pix_fmt yuv420p "seg$i.mp4"
done
printf "file 'seg1.mp4'\nfile 'seg2.mp4'\nfile 'seg3.mp4'\n" > concat.txt
ffmpeg -y -v error -f concat -safe 0 -i concat.txt -i assets/voiceover.mp3 -filter_complex "[0:v]drawtext=fontfile=/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf:text='DI LUAR 35°  /  DI DALAM 22°':fontsize=58:fontcolor=white:box=1:boxcolor=black@0.6:boxborderw=18:x=(w-text_w)/2:y=160:enable='between(t,0,6.07)',drawtext=fontfile=/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf:text='TANAH NYIMPEN SUHU':fontsize=64:fontcolor=white:box=1:boxcolor=black@0.6:boxborderw=18:x=(w-text_w)/2:y=160:enable='between(t,6.07,12.14)',drawtext=fontfile=/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf:text='MAU TINGGAL DI RUMAH TANAH?':fontsize=52:fontcolor=white:box=1:boxcolor=black@0.6:boxborderw=18:x=(w-text_w)/2:y=160:enable='between(t,12.14,18.2)'[v]" -map "[v]" -map 1:a -c:v libx264 -preset veryfast -pix_fmt yuv420p -c:a aac -shortest rumah-tanah-adem-short.mp4
rm -f seg1.mp4 seg2.mp4 seg3.mp4 concat.txt
