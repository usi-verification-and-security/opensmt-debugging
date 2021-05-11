#!/bin/bash

function get_abs_path {
  echo $(cd $(dirname $1); pwd)/$(basename $1)
}

SCRIPT_ROOT=$(get_abs_path $(dirname $0))
DEFAULTOSMT=${DEFAULTOSMT:-~/bin/opensmt}
DEFAULTSCRAMBLER=${SCRAMBLER:-~/bin/scrambler}
DEFAULTCHECKER=${CHECKER:-~/bin/ModelValidator}
DEFAULTOUTDIR=./out/
DEFAULTPRESERVE=false

usage="Usage: $0 [-h] [-o <osmt2-binary>] [-s <scrambler>] [-c <checker>] [ -d <output-directory> ] [-p <true|false] <file>"

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
      -d|--out-dir)
        outdir=$2
        ;;
      -p|--preserve-tmp-output)
        preserve=$2
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

if [ -z ${binary} ]; then
    binary=${DEFAULTOSMT}
fi

if [ -z ${scrambler} ]; then
    scrambler=${DEFAULTSCRAMBLER}
fi

if [ -z ${checker} ]; then
    checker=${DEFAULTCHECKER}
fi

if [ -z ${outdir} ]; then
    outdir=${DEFAULTOUTDIR}
fi

if [ -z ${preserve} ]; then
    preserve=${DEFAULTPRESERVE}
fi


echo $1

tmpin=$(tempfile -d /tmp -p tmp -s .smt2)
tmpout=$(dirname ${tmpin})/$(basename ${tmpin} .smt2).out

mkdir -p ${outdir}

${scrambler} -seed "0" -gen-model-val true < $1 > ${tmpin}

sh -c "\
    ulimit -St 10;
    ulimit -Sv 4000000
    ${binary} ${tmpin}" \
        > ${tmpout}

if [[ $(grep '^sat' ${tmpout}) ]]; then
    sh -c "\
        ulimit -St 10;
        ulimit -Sv 4000000;
        ${checker} --smt2 ${tmpin} --model ${tmpout}" \
            > ${outdir}/$(basename $1 .smt2).out
else
    echo "not sat"
fi

if [[ ${preserve} == "true" ]]; then
    echo "Left the annotated instance and the model to ${tmpin} and ${tmpout}"
else
    rm -rf ${tmpin} ${tmpout}
fi

