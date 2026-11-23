#!/bin/bash
# v2 — gerakan sinematik ala Netflix: slow push-in / pan / zoom-out + crossfade 0.8 dtk
# Scene 1: push-in 1.00 -> 1.35 (tengah) | Scene 2: pan kiri->kanan + zoom-out 1.30 -> 1.05
# Scene 3: push-in 1.00 -> 1.30 + pan bawah->atas | fade in/out 0.5 dtk
# Gerakan terukur: beda frame rata-rata ~27-31 (v1 cuma ~5, hampir tidak kelihatan).
set -e
cd "$(dirname "$0")"
ffmpeg -y -v error -i assets/scene1-panas.webp -vf "scale=1080:1920,zoompan=z='1+0.35*on/197':x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)':d=198:s=1080x1920:fps=30,format=yuv420p" -t 6.6 -c:v libx264 -preset veryfast -pix_fmt yuv420p seg1.mp4
ffmpeg -y -v error -i assets/scene2-adem.webp -vf "scale=1080:1920,zoompan=z='1.30-0.25*on/197':x='(iw-iw/zoom)*on/197':y='ih/2-(ih/zoom/2)':d=198:s=1080x1920:fps=30,format=yuv420p" -t 6.6 -c:v libx264 -preset veryfast -pix_fmt yuv420p seg2.mp4
ffmpeg -y -v error -i assets/scene3-esteh.webp -vf "scale=1080:1920,zoompan=z='1+0.30*on/197':x='iw/2-(iw/zoom/2)':y='(ih-ih/zoom)*(1-on/197)':d=198:s=1080x1920:fps=30,format=yuv420p" -t 6.6 -c:v libx264 -preset veryfast -pix_fmt yuv420p seg3.mp4
ffmpeg -y -v error -i seg1.mp4 -i seg2.mp4 -i seg3.mp4 -i assets/voiceover.mp3 -filter_complex "[0:v][1:v]xfade=transition=fade:duration=0.8:offset=5.8[x1];[x1][2:v]xfade=transition=fade:duration=0.8:offset=11.6,fade=t=in:st=0:d=0.5,fade=t=out:st=17.7:d=0.5,drawtext=fontfile=/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf:text='DI LUAR 35°  /  DI DALAM 22°':fontsize=58:fontcolor=white:box=1:boxcolor=black@0.6:boxborderw=18:x=(w-text_w)/2:y=160:enable='between(t,0,6.6)',drawtext=fontfile=/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf:text='TANAH NYIMPEN SUHU':fontsize=64:fontcolor=white:box=1:boxcolor=black@0.6:boxborderw=18:x=(w-text_w)/2:y=160:enable='between(t,6.6,12.4)',drawtext=fontfile=/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf:text='MAU TINGGAL DI RUMAH TANAH?':fontsize=52:fontcolor=white:box=1:boxcolor=black@0.6:boxborderw=18:x=(w-text_w)/2:y=160:enable='between(t,12.4,18.2)'[v]" -map "[v]" -map 3:a -c:v libx264 -preset veryfast -pix_fmt yuv420p -c:a aac -shortest rumah-tanah-adem-short.mp4
rm -f seg1.mp4 seg2.mp4 seg3.mp4
