#!/bin/bash

function get_abs_path {
  echo $(cd $(dirname $1); pwd)/$(basename $1)
}

SCRIPT_ROOT=$(get_abs_path $(dirname $0))
DEFAULTOSMT=${DEFAULTOSMT:-~/bin/opensmt}
DEFAULTSCRAMBLER=${SCRAMBLER:-~/bin/scrambler}
DEFAULTCHECKER=${CHECKER:-~/bin/ModelValidator}

usage="Usage: $0 [-h] [-o <osmt2-binary>] [-s <scrambler>] [-c <checker>] <file>"

while [ $# -gt 0 ]; do
    case $1 in
      -h|--help)
        echo "${usage}"
        exit 1
        ;;
      -o|--osmt-binary)
        binary=$2
        ;;
      -s|--scrambler)
        scrambler=$2
        ;;
      -c|--checker)
        checker=$2
        ;;
      -*)
        echo "Error: invalid option '$1'"
        exit 1
        ;;
      *)
        break
    esac
    shift; shift
done

echo $1

tmpin=$(tempfile -d /tmp -p tmp -s .smt2)
tmpout=$(dirname ${tmpin})/$(basename ${tmpin} .smt2).out

${scrambler} -seed "1" -gen-model-val true < $1 > ${tmpin}

${binary} ${tmpin} > ${tmpout}

if [[ $(grep '^sat' ${tmpout}) ]]; then
    ${checker} --smt2 ${tmpin} --model ${tmpout}
else
    echo "not sat"
fi

rm -rf ${tmpin} ${tmpout}

