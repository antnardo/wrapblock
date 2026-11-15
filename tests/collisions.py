"""Find the words that overlap an image set by wrapblock.

The test image carries three text markers: IMGA at the top left, IMGB at
the top right, IMGC at the bottom left. The image rectangle runs from IMGA
to IMGB in width, from the top of IMGA to the bottom of IMGC in height.

    python collisions.py file.pdf
"""

import html
import re
import subprocess
import sys

WORD = re.compile(
    r'<word xMin="([\d.]+)" yMin="([\d.]+)" xMax="([\d.]+)" yMax="([\d.]+)">(.*?)</word>'
)
PAGE = re.compile(r"<page [^>]*>(.*?)</page>", re.DOTALL)


def pages(pdf):
    output = subprocess.run(
        ["pdftotext", "-bbox", pdf, "-"], capture_output=True, text=True, check=True
    ).stdout
    for content in PAGE.findall(output):
        yield [
            (float(a), float(b), float(c), float(d), html.unescape(t))
            for a, b, c, d, t in WORD.findall(content)
        ]


def images(words):
    a = [w for w in words if w[4] == "IMGA"]
    b = [w for w in words if w[4] == "IMGB"]
    c = [w for w in words if w[4] == "IMGC"]
    return [(wa[0], wa[1], wb[2], wc[3]) for wa, wb, wc in zip(a, b, c)]


def collisions(pdf, margin=0.3):
    found = []
    for number, words in enumerate(pages(pdf), 1):
        for x0, y0, x1, y1 in images(words):
            for wx0, wy0, wx1, wy1, text in words:
                if text.startswith("IMG"):
                    continue
                dx = min(x1, wx1) - max(x0, wx0)
                dy = min(y1, wy1) - max(y0, wy0)
                if dx > margin and dy > margin:
                    found.append((number, text, round(dx, 1), round(dy, 1)))
    return found


if __name__ == "__main__":
    for pdf in sys.argv[1:]:
        found = collisions(pdf)
        print(f"{pdf}: {len(found)} overlap(s)")
        for page, text, dx, dy in found[:15]:
            print(f"   p.{page}  {text!r}  {dx} x {dy} pt")
