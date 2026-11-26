"""Check that every image of tests/bottom.tex is there, and that nothing
lies below the text area (an image that ran out of the page).

The test image carries the markers IMGA, IMGB and IMGC (see
collisions.py). A word is below the text area when its bottom is lower
than the bottom of the text area of an A4 page with a 2.5 cm margin, by
more than the depth of a line; page numbers are not counted.

    python bottom.py file.pdf expected_images
"""

import sys

from collisions import pages

BOTTOM = 841.89 - 2.5 / 2.54 * 72  # bottom of the text area, in points


def check(pdf, expected):
    found = 0
    below = []
    for number, words in enumerate(pages(pdf), start=1):
        found += sum(1 for w in words if w[4] == "IMGA")
        below += [
            (number, w[4]) for w in words if w[3] > BOTTOM + 5 and not w[4].isdigit()
        ]
    return found, below


if __name__ == "__main__":
    pdf, expected = sys.argv[1], int(sys.argv[2])
    found, below = check(pdf, expected)
    print(
        f"{pdf}: images {found}/{expected}, words below the text area: {len(below)}",
        " ".join(f"p{n}:{t}" for n, t in below[:5]),
    )
