"""Check that the documentation prints the whole of wrapblock.sty.

In wrapblock.sty, the code sits in chunks between "% <name>" and
"% </name>"; the documentation prints each one with \\code{name}. This
script checks that every line of code is in a chunk, that the chunks are
well formed, and that the documentation prints each of them exactly once.
"""
import re
import sys
from pathlib import Path

root = Path(__file__).resolve().parent.parent
sty = (root / "wrapblock.sty").read_text().splitlines()
doc = (root / "doc" / "wrapblock-doc.tex").read_text()

problems = []
chunks = []
current = None
header = True  # the license header, before the first chunk
for number, line in enumerate(sty, 1):
    begin = re.fullmatch(r"% <([^/>]+)>", line)
    end = re.fullmatch(r"% </([^>]+)>", line)
    if begin:
        header = False
        name = begin.group(1)
        if current:
            problems.append(f"line {number}: chunk {name} opens inside {current}")
        if not re.fullmatch(r"[a-z]+", name):
            problems.append(f"line {number}: chunk name {name!r} is not plain lowercase letters")
        current = name
        chunks.append(name)
    elif end:
        if end.group(1) != current:
            problems.append(f"line {number}: {end.group(1)} closes {current}")
        current = None
    elif current is None and line.strip() and not header:
        problems.append(f"line {number}: outside any chunk: {line.strip()}")
if current:
    problems.append(f"chunk {current} is not closed")

for name in sorted(set(chunks)):
    if chunks.count(name) > 1:
        problems.append(f"chunk {name} is defined {chunks.count(name)} times")
printed = re.findall(r"\\code\{([^}]*)\}", doc)
for name in sorted(set(chunks) | set(printed)):
    n = printed.count(name)
    if name not in chunks:
        problems.append(f"the documentation prints {name}, which is not a chunk")
    elif n != 1:
        problems.append(f"chunk {name} is printed {n} times")

print(f"chunks: {len(chunks)} in the .sty, {len(printed)} printed; problems: {len(problems)}")
for p in problems:
    print("  " + p)
sys.exit(1 if problems else 0)
