#!/bin/zsh
# Runs every test with pdfLaTeX and LuaLaTeX, plain and tagged:
# limits.tex (article and book), extra.tex, contexts.tex (and twocolumn),
# floats.tex, images.tex, groups.tex, items.tex, heading.tex.
# Prints errors, `moved` warnings, overlaps and tagpdf structure warnings.
# First checks that the documentation prints the whole package (chunks.py).
# Needs pdflatex, lualatex, python3 and pdftotext (poppler) in the PATH.
# With veraPDF in the PATH, each tagged build is also checked against PDF/UA-2,
# and the failed clauses are printed (8.2.2 on pages with footnotes under
# pdfLaTeX comes from LaTeX itself, with or without the package).
# Usage: zsh tests/run.zsh
cd "$(dirname "$0")"
export TEXINPUTS="$(cd .. && pwd):"
# the documentation prints every line of the package, chunk by chunk
python3 chunks.py

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
  # floats, marginal notes and centred text in a block
  compile floats-$engine "" floats 2
  # unusual images: a tcolorbox, text, nothing, too wide, too tall
  compile images-$engine "" images 2
  # a paragraph that starts in a group, a tcolorbox beside the image,
  # a caption in an image with a width
  compile groups-$engine "" groups 2
  # items in a block, the list opened before it and closed after it
  compile items-$engine "" items 2
  printf "%-26s " ""; python3 items.py items-$engine.pdf | head -1
  # images near the bottom of a page: a heading never left alone
  for mode in plain tag; do
    tag=""; [[ $mode == tag ]] && tag='\def\TAGGING{}'
    job=heading-$engine-$mode
    rm -f $job.aux   # the room kept for footnotes is found again from scratch
    for i in 1 2 3; do
      $engine -interaction=nonstopmode -jobname=$job "$tag\\input{heading}" >/dev/null 2>&1
    done
    alone=0
    for p in $(seq 1 $(pdfinfo $job.pdf | awk '/^Pages/{print $2}')); do
      pdftotext -f $p -l $p $job.pdf - | grep -v '^[[:space:]]*[0-9]*[[:space:]]*$' |
        tail -1 | grep -q 'high$' && alone=$((alone + 1))
    done
    printf "%-26s errors=%s headings alone=%s early=%s  " $job $(grep -c '^!' $job.log) $alone $(grep -c 'broke too early' $job.log)
    python3 collisions.py $job.pdf | head -1
    if [[ $mode == tag ]] && (( $+commands[verapdf] )); then
      local failed=$(verapdf --flavour ua2 --format mrr $job.pdf 2>/dev/null |
        grep -o 'clause="[^"]*" testNumber="[0-9]*" status="failed"' |
        sed 's/clause="\([^"]*\)" testNumber="\([0-9]*\)".*/\1-\2/' | tr '\n' ' ')
      printf "%-26s PDF/UA-2 failed clauses: %s\n" "" "${failed:-none}"
    fi
  done
done
