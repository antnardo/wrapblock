#!/bin/zsh
# Compiles every example with pdfLaTeX and LuaLaTeX, into out-pdflatex/ and out-lualatex/.
# The LuaLaTeX PDF of each example is then copied beside its source: these
# copies are in the repository, so that the result can be seen without compiling.
# Usage: zsh examples/build.zsh
cd "$(dirname "$0")"
export TEXINPUTS="$(cd .. && pwd):"
for f in mwe-*.tex; do
  for engine in pdflatex lualatex; do
    mkdir -p out-$engine
    for i in 1 2; do
      $engine -interaction=nonstopmode -output-directory=out-$engine $f >/dev/null 2>&1
    done
    log=out-$engine/${f:r}.log
    printf "%-20s %-9s errors=%s overfull=%s\n" ${f:r} $engine $(grep -c '^!' $log) $(grep -c '^Overfull' $log)
  done
done
cp out-lualatex/mwe-*.pdf .
