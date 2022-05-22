#!/usr/bin/env bash
if [[ $# == 0 ]]; then
    echo "Usage: $0 <result-dir>";
    exit 1;
fi

for file in $1/smts.*.smt2.bz2.sh.*.out; do
    name=$(echo $file |sed 's,'$1'/smts\.\(.*\)\.smt2\.bz2\.sh\.\(.*\).out,\1,g');
    num=$(echo $file |sed 's,'$1'/smts\.\(.*\)\.smt2\.bz2\.sh\.\(.*\).out,\2,g');
    inst=$(basename $(head -1 $file) .smt2.bz2);
    if (grep '^sat' $file > /dev/null); then
        result=sat
    elif (grep '^unsat' $file > /dev/null); then
        result=unsat
    else
        result=indet
    fi
    dn=$(dirname $file)
    tf=${dn}/smts.${name}.smt2.bz2.sh.smts.${num}.time
    tm=$(sed -n 's/.* wall: \(.*\) CPU: .*/\1/p' $tf)
    echo $inst $result $tm;
done

