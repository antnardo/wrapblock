"""Check items.pdf: a block of items moved to the next page.

On the page of the short items, the first item must be at the top of the
page (no blank left above it), and the labels of the items of the block
must be at the same abscissa as the label of the item after the block.
Usage: python3 items.py items-lualatex.pdf
"""
import re
import subprocess
import sys

pdf = sys.argv[1]
html = subprocess.run(["pdftotext", "-bbox", pdf, "-"], capture_output=True, text=True).stdout
problems = []
found = False
for page in html.split("<page ")[1:]:
    words = [
        (float(m.group(1)), float(m.group(2)), m.group(3))
        for m in re.finditer(r'<word xMin="([\d.]+)" yMin="([\d.]+)"[^>]*>([^<]*)</word>', page)
    ]
    texts = [w[2] for w in words]
    if "short" not in texts:
        continue
    found = True
    y_first = min(y for x, y, w in words if w == "short")
    if y_first > 200:
        problems.append(f"the first item starts {y_first:.0f} pt down the page: a blank is left above it")
    labels = {w: x for x, y, w in words if re.fullmatch(r"\d\.", w)}
    if len({round(x) for x in labels.values()}) > 1:
        problems.append(f"the labels are not aligned: {labels}")
if not found:
    problems.append("page of the short items not found")
print(f"{pdf}: items moved to the next page: {len(problems)} problem(s)")
for p in problems:
    print("  " + p)
sys.exit(1 if problems else 0)
