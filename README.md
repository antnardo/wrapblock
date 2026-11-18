# wrapblock

An image beside its own text, which wraps around it and runs below, in LaTeX.

```latex
\usepackage{wrapblock}
…
\begin{wrapblock}[side=l]{\includegraphics[width=4cm, alt={The setup}]{setup}}
  The text of the block: paragraphs, lists, equations.
\end{wrapblock}
```

The text of the block runs along the image, then takes the full width again
below it; the text after the environment is full width. The block is closed:
the image never spills over what follows.

The package gives the image no size of its own: the room taken from the text
is the width and the height of the image as it is given. Only the width can
be forced, with the `width` key.

Four properties that no existing wrapping package combines:

- **lists**: a list beside the image is narrowed, at any depth, and a block
  may be the first thing in an `\item` (`\item \begin{wrapblock}…`);
- **page breaks**: the image and the lines beside it stay on the same page;
  when the image does not fit at the bottom of a page, the text fills that
  bottom at full width and the image goes to the top of the next page; a
  text too short for that moves with its image to the next page, together
  with the heading before it, and the log says so;
- **both engines**: pdfLaTeX and LuaLaTeX, with the same output;
- **tagged PDF**: with `\DocumentMetadata{tagging=on}`, the structure is the
  one the same text would have without the package.

Three things to know (section 2 of the documentation):

- **the text should be at least as long as the image**: when it is shorter,
  the block ends with vertical space down to the bottom of the image, since
  the text after the block never runs beside it;
- **near the bottom of a page, the text is typeset twice**, once at full
  width in a box that is thrown away, to measure it. LaTeX counters are put
  back, but any other global action is done twice: a TeX count, an expl3
  integer, an `\immediate\write`, the first use of an acronym (glossaries,
  acro). The key `defer=false` turns the measure off;
- **no verbatim in the block**: its contents are read as an argument. Verbatim
  material can be set beforehand in an `lrbox`.

The package is written in expl3.

## Contents

| File | Role |
| --- | --- |
| `wrapblock.sty` | the package |
| `doc/wrapblock-doc.tex`, `doc/wrapblock-doc.pdf` | the documentation, which ends with the whole code, commented; it compiles with both engines, from `doc/`, with `wrapblock.sty` one level up |
| `examples/` | minimal examples, one per property: `mwe-basic`, `mwe-lists`, `mwe-pagebreak`, `mwe-tagged`; `zsh examples/build.zsh` compiles them with both engines |
| `tests/` | the tests: `zsh tests/run.zsh` compiles each one with both engines, plain and tagged, and reports errors, tagging warnings and text overlapping an image; it needs `python3` and `pdftotext` (poppler), and checks the tagged builds against PDF/UA-2 when `verapdf` is in the PATH |

## Installation

Copy `wrapblock.sty` into a TeX tree (`TEXMFHOME/tex/latex/wrapblock/`). The
package needs a LaTeX kernel of June 2023 or later, which it checks, and
pdfLaTeX or LuaLaTeX; it was tested with TeX Live 2026 only. One correction,
for a footnote before an image sent to the next page, needs a kernel of June
2025.

## License

This work may be distributed and/or modified under the conditions of the LaTeX
Project Public License, version 1.3c or any later version.

Author and maintainer: Antonin Marchand.
