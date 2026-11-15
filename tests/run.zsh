#!/bin/zsh
# Runs every test with pdfLaTeX and LuaLaTeX, plain and tagged:
# limits.tex (article and book), extra.tex, contexts.tex (and twocolumn).
# Prints errors, `moved` warnings, overlaps and tagpdf structure warnings.
# Needs pdflatex, lualatex, python3 and pdftotext (poppler) in the PATH.
# With veraPDF in the PATH, each tagged build is also checked against PDF/UA-2,
# and the failed clauses are printed (8.2.2 on pages with footnotes under
# pdfLaTeX comes from LaTeX itself, with or without the package).
# Usage: zsh tests/run.zsh
cd "$(dirname "$0")"
export TEXINPUTS="$(cd .. && pwd):"

compile() {  # job, preamble definitions, file, runs
  local i
  for i in $(seq 1 $4); do
    $engine -interaction=nonstopmode -jobname=$1 "$2\\input{$3}" >/dev/null 2>&1
  done
  local errors=$(grep -c '^!' $1.log)
  local moved=$(grep -c 'moved to a new page' $1.log)
  local tagwarn=$(grep 'Package tagpdf Warning' $1.log | grep -v unicode-math | wc -l | tr -d ' ')
  printf "%-26s errors=%s moved=%s tagpdf=%s  " $1 $errors $moved $tagwarn
  python3 collisions.py $1.pdf | head -1
  if [[ $1 == *-tag ]] && (( $+commands[verapdf] )); then
    local failed=$(verapdf --flavour ua2 --format mrr $1.pdf 2>/dev/null |
      grep -o 'clause="[^"]*" testNumber="[0-9]*" status="failed"' |
      sed 's/clause="\([^"]*\)" testNumber="\([0-9]*\)".*/\1-\2/' | tr '\n' ' ')
    printf "%-26s PDF/UA-2 failed clauses: %s\n" "" "${failed:-none}"
  fi
}

for engine in pdflatex lualatex; do
  for mode in plain tag; do
    tag=""; [[ $mode == tag ]] && tag='\def\TAGGING{}'
    compile limits-$engine-article-$mode "$tag" limits 3
    compile limits-$engine-book-$mode "$tag\\def\\BOOK{}" limits 3
    compile extra-$engine-$mode "$tag" extra 3
  done
  compile limits-$engine-plainimg-tag '\def\TAGGING{}\def\PLAINIMG{}' limits 2
  compile contexts-$engine "" contexts 2
  compile contexts-$engine-twocol '\def\TWOCOL{}' contexts 2
done
