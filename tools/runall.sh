#!/bin/sh
# runall.sh LABEL VOCDIR OUTDIR: compile and run every reproducer named in
# tools/manifest with the voc installed in VOCDIR (its bin/ and lib/), and
# write each transcript to OUTDIR/LABEL/<issue>/<module>/transcript.
# gen.py reads the transcripts labelled master and new. A manifest line is
# issue|model (2 or OC)|modules|stdin|setup|modules compiled first|command
# run in place of ./Module; the last four may be empty.
[ $# -eq 3 ] || { echo "usage: $0 LABEL VOCDIR OUTDIR" >&2; exit 2; }
L=$1; V=$(cd "$2" && pwd); O=$(mkdir -p "$3" && cd "$3" && pwd)
T=$(cd "$(dirname "$0")" && pwd)
export PATH=$V/bin:$PATH LD_LIBRARY_PATH=$V/lib
while IFS='|' read -r slug model files input setup pre run; do
  for m in $files; do
    d=$O/$L/$slug/$m; rm -rf "$d"; mkdir -p "$d"; cp "$T/../reproducers/$slug/$m.Mod" "$d/"; cd "$d"
    [ -n "$setup" ] && eval "$setup"
    opt=-O2; [ "$model" = OC ] && opt=-OC
    { for p in $pre; do cp "$T/../reproducers/$slug/$p.Mod" .; echo "\$ voc $opt $p.Mod"
        voc $opt $p.Mod 2>&1 | grep -v '^$'; done
      echo "\$ voc $opt $m.Mod -m"
      sh -c 'voc "$@"; exit $?' voc $opt $m.Mod -m > voc.out 2>&1; rc=$?
      grep -v '^$' voc.out
      if [ $rc -gt 128 ] && [ $rc -le 192 ]; then echo "(voc killed by SIG$(kill -l $((rc - 128))))"
      elif [ $rc -ne 0 ]; then echo "(voc's exit status $rc)"; fi
      if [ -x ./$m ]; then
        if [ -n "$run" ]; then
          echo "\$ $run"; (ulimit -v 2000000; timeout 60 sh -c "$run") 2>&1
        elif [ -n "$input" ]; then
          echo "\$ printf '$input\\n' | ./$m"
          printf "$input\n" | (ulimit -v 2000000; timeout 60 ./$m) 2>&1
        else echo "\$ ./$m"; (ulimit -v 2000000; timeout 60 ./$m) 2>&1; fi
        echo "(exit status $?)"
      fi; } > "$d/transcript" 2>&1
  done
done < "$T/manifest"
