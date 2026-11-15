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

Four properties that no existing wrapping package combines:

- **lists**: a list beside the image is narrowed, at any depth, and the block
  may itself open an `\item`;
- **page breaks**: the image and the lines beside it stay on the same page;
  when there is no room, the block moves to the next page, together with the
  heading before it;
- **both engines**: pdfLaTeX and LuaLaTeX, with the same output;
- **tagged PDF**: with `\DocumentMetadata{tagging=on}`, the structure is the
  one the same text would have without the package.

The package is written in expl3.

## Contents

| File | Role |
| --- | --- |
| `wrapblock.sty` | the package |
| `doc/wrapblock-doc.tex`, `doc/wrapblock-doc.pdf` | the documentation; it compiles with both engines |
| `examples/` | minimal examples, one per property: `mwe-basic`, `mwe-lists`, `mwe-pagebreak`, `mwe-tagged`; `zsh examples/build.zsh` compiles them with both engines |
| `tests/` | the tests: `zsh tests/run.zsh` compiles each one with both engines, plain and tagged, and reports errors, tagging warnings and text overlapping an image; it needs `python3` and `pdftotext` (poppler), and checks the tagged builds against PDF/UA-2 when `verapdf` is in the PATH |

## Installation

Copy `wrapblock.sty` into a TeX tree (`TEXMFHOME/tex/latex/wrapblock/`). The
package needs a LaTeX with paragraph hooks (2021 or later); it was tested with
TeX Live 2026.

## License

This work may be distributed and/or modified under the conditions of the LaTeX
Project Public License, version 1.3c or any later version.

Author and maintainer: Antonin Marchand.
