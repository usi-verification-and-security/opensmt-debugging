#!/usr/bin/env bash
if [[ $# == 0 ]]; then
    echo "Usage: $0 <result-dir>";
    exit 1;
fi

for file in $1/osmt.*.smt2.bz2.sh.*.out; do
    name=$(echo $file |sed 's,'$1'/osmt\.\(.*\)\.smt2\.bz2\.sh\.\(.*\).out,\1,g');
    num=$(echo $file |sed 's,'$1'/osmt\.\(.*\)\.smt2\.bz2\.sh\.\(.*\).out,\2,g');
    inst=$(basename $(head -1 $file) .smt2.bz2);
    if (grep '^sat' $file > /dev/null); then
        result=sat
    elif (grep '^unsat' $file > /dev/null); then
        result=unsat
    else
        result=indet
    fi
    dn=$(dirname $file)
    tf=${dn}/osmt.${name}.smt2.bz2.sh.${num}.out
    tm=$(sed -n 's/^Number of distinct variables in the proof: \([0-9][0-9]*\)/\1/p' $tf)
# [hyvaeria@cub satcomp]$ less
# results-osmt/osmt.289-sat-6x20.smt2.bz2.sh.osmt.0.time
# user: 0.15 system: 0.01 wall: 0.17 CPU: 98%CPU
# [hyvaeria@cub satcomp]$
    echo $inst $result $tm;
done

