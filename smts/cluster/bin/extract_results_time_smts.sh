#!/usr/bin/env bash
if [[ $# != 2 ]]; then
    echo "Usage: $0 <result-dir> <project osmt|smts>";
    exit 1;
fi

for file in $1/$2.*.smt2.bz2.sh.*.out; do
    name=$(echo $file |sed 's,'$1'/'$2'\.\(.*\)\.smt2\.bz2\.sh\.\(.*\).out,\1,g');
    num=$(echo $file |sed 's,'$1'/'$2'\.\(.*\)\.smt2\.bz2\.sh\.\(.*\).out,\2,g');
    inst=$(basename $(head -1 $file) .smt2.bz2);
    if (grep '^sat' $file > /dev/null); then
        result=sat
    elif (grep '^unsat' $file > /dev/null); then
        result=unsat
    else
        result=indet
    fi
    dn=$(dirname $file)
    tf=${dn}/$2.${name}.smt2.bz2.sh.$2.${num}.time
    tm=$(sed -n 's/.* wall: \(.*\) CPU: .*/\1/p' $tf)
    echo $inst $result $tm;
done

