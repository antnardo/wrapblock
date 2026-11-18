#!/bin/zsh
# Builds the archive for CTAN: ../wrapblock-construction/ctan/wrapblock.zip.
# One folder, wrapblock/, with the package, the README, the documentation
# (source and PDF) and the examples; no tests. The PDF is the one of the
# repository: compile the documentation first.
# Usage: zsh ctan.zsh
cd "$(dirname "$0")"
out=../wrapblock-construction/ctan
mkdir -p $out/wrapblock
find $out/wrapblock -type f -delete
[[ -f $out/wrapblock.zip ]] && mv $out/wrapblock.zip $out/wrapblock-previous.zip
cp README.md wrapblock.sty doc/wrapblock-doc.tex doc/wrapblock-doc.pdf examples/mwe-*.tex $out/wrapblock/
chmod 755 $out/wrapblock && chmod 644 $out/wrapblock/*
(cd $out && /usr/bin/zip -q -r -X wrapblock.zip wrapblock -x '*.DS_Store')
unzip -l $out/wrapblock.zip
