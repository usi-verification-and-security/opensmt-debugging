#!/usr/bin/env bash

function get_abs_path {
  echo $(cd $(dirname $1); pwd)/$(basename $1)
}

SCRIPT_ROOT=$(get_abs_path $(dirname $0))
DEFAULTSCRAMBLER=${SCRAMBLER:-~/bin/scrambler}
DEFAULTCHECKER=${CHECKER:-~/bin/ModelValidator}
DEFAULTBMPATH=${BMPATH:-~/benchmarks/}

usage="Usage: $0 [-h] [-s <scrambler>] [-c <checker>] [-b <benchmarkdir>] <file>"

while [ $# -gt 0 ]; do
    case $1 in
      -h|--help)
        echo "${usage}"
        exit 1
        ;;
      -s|--scrambler)
        scrambler=$2
        ;;
      -c|--checker)
        checker=$2
        ;;
      -b|--benchmark-dir)
        bmdir=$2
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

if [ -z ${scrambler} ]; then
    scrambler=${DEFAULTSCRAMBLER}
fi

if [ -z ${checker} ]; then
    checker=${DEFAULTCHECKER}
fi

if [ -z ${bmdir} ]; then
    bmdir=${DEFAULTBMPATH}
fi

model_file=$1
echo ${model_file}
result=$(head -2 ${model_file} |tail -1)

if [[ "${result}" != sat ]]; then
    echo "Not sat"
    exit 0;
fi

compressed_bm_name=$(basename $(head -1 ${model_file}))
echo ${compressed_bm_name}
input_inst=${bmdir}/${compressed_bm_name}

if [[ ! -e ${input_inst} ]]; then
    echo "Input instance ${input_inst} not found"
    exit 1;
fi

tmpinst=$(tempfile -d /tmp -p tmpinst -s .smt2)
bunzip2 -c ${input_inst} > ${tmpinst}

tmpmodel=$(tempfile -d /tmp -p tmp -s .model)

tail +2 ${model_file} > ${tmpmodel}

tmpin=$(tempfile -d /tmp -p tmpscrambled -s .smt2)

${scrambler} -gen-model-val true -seed 1 < ${tmpinst} > ${tmpin}

/usr/bin/time ${checker} --smt2=${tmpin} --model=${tmpmodel} 2>&1

rm ${tmpin} ${tmpmodel} ${tmpinst}
