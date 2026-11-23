import re, sys
srt_path, ass_path = sys.argv[1], sys.argv[2]
with open(srt_path, encoding='utf-8') as f:
    content = f.read()
blocks = re.split(r'\n\s*\n', content.strip())
events = []
for b in blocks:
    lines = b.strip().split('\n')
    if len(lines) < 3: continue
    times = lines[1]
    m = re.match(r'(\d+):(\d+):(\d+),(\d+) --> (\d+):(\d+):(\d+),(\d+)', times)
    if not m: continue
    h1,mi1,s1,ms1,h2,mi2,s2,ms2 = [int(x) for x in m.groups()]
    start = f"{h1}:{mi1:02d}:{s1:02d}.{ms1//10:02d}"
    end = f"{h2}:{mi2:02d}:{s2:02d}.{ms2//10:02d}"
    text = "\\N".join(lines[2:])
    events.append((start, end, text))
header = """[Script Info]
ScriptType: v4.00+
PlayResX: 1080
PlayResY: 1920
ScaledBorderAndShadow: yes

[V4+ Styles]
Format: Name, Fontname, Fontsize, PrimaryColour, SecondaryColour, OutlineColour, BackColour, Bold, Italic, Underline, StrikeOut, ScaleX, ScaleY, Spacing, Angle, BorderStyle, Outline, Shadow, Alignment, MarginL, MarginR, MarginV, Encoding
Style: Default,DejaVu Sans,56,&H00FFFFFF,&H000000FF,&H00000000,&H80000000,0,0,0,0,100,100,0,0,1,2,1,2,40,40,100,1

[Events]
Format: Layer, Start, End, Style, Name, MarginL, MarginR, MarginV, Effect, Text
"""
with open(ass_path, 'w', encoding='utf-8') as f:
    f.write(header)
    for start, end, text in events:
        f.write(f"Dialogue: 0,{start},{end},Default,,0,0,0,,{text}\n")
print(f"wrote {ass_path} with {len(events)} events")
