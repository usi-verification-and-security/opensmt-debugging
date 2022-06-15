#!/bin/bash

function get_abs_path {
  echo $(cd $(dirname $1); pwd)/$(basename $1)
}

SCRIPT_ROOT=$(get_abs_path $(dirname $0))

BMBASE=${BMBASE:-~/benchmarks-updated}
DEFAULTOSMT=${DEFAULTOSMT:-~/bin/opensmt}
DEFAULTCONFIG=empty.smt2
WORKSCRIPT=${SCRIPT_ROOT}/make_scripts_osmt2.sh

usage="Usage: $0 [-h] [-o <osmt2-binary>] [-c <config>] -b <benchmark-path> [-f <flavor>] [-i true | false] [-m true | false]"

incremental=false;
produce_models=false;

while [ $# -gt 0 ]; do
    case $1 in
      -h|--help)
        echo "${usage}"
        exit 1
        ;;
      -o|--osmt-binary)
        binary=$2
        ;;
      -c|--config)
        config=$2
        ;;
      -b|--benchmarks)
        benchmarks=$2
        ;;
      -f|--flavor)
        flavor=$2
        ;;
      -i|--incremental)
        incremental=$2
        ;;
      -m|--produce-models)
        produce_models=$2
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

if [ -z ${config} ]; then
    config=${DEFAULTCONFIG}
fi

if [ -z ${flavor} ]; then
    flavor=$(basename $binary | sed 's/opensmt//g')
    if [ -z ${flavor} ]; then
        flavor=master
    else
        flavor=$(echo ${flavor} |sed 's/^-//g')
    fi
fi

if [ -z ${benchmarks} ]; then
    echo "Error: benchmark set not provided"
    exit 1;
fi

if [ ! -f $binary ]; then
    echo "Binary $binary not found"
    exit 1
fi

if [ ! -f $config ]; then
    echo "Config $config not found"
    exit 1
fi

if [[ ${incremental} == true ]]; then
    incr_str="incremental"
    BMBASE=$BMBASE-incremental
else
    incr_str="non-incremental"
fi

bmpath=${BMBASE}/${benchmarks};

n_benchmarks=$(find ${bmpath} -name '*.smt2.bz2' |wc -l)

echo "Binary:"
echo " - ${binary}"
echo "Flavor:"
echo " - ${flavor}"
echo "Modification date:"
echo " - $(date -r ${binary})"
echo "Benchmark set (total ${n_benchmarks}):"
echo " - ${bmpath}"


echo "Incremental benchmarks:"
echo " - ${incremental}"

if [[ ${produce_models} == true ]]; then
    mv_str="-mv"
    WORKSCRIPT=${SCRIPT_ROOT}/make_scripts_osmt2_models.sh
else
    mv_str=""
fi

echo "Produce models:"
echo " - ${produce_models}"

benchmarks_printable=$(echo ${benchmarks} |tr '/' '_')

scriptdir=osmt2-${flavor}-scripts-$(date +'%F')-${incr_str}-${benchmarks_printable}${mv_str}
resultdir=osmt2-${flavor}-results-$(date +'%F')-${incr_str}-${benchmarks_printable}${mv_str}

echo "Work directories:"
echo " - ${scriptdir}"
echo " - ${resultdir}"

echo

echo "Construct and send the above jobs to batch queue?"
read -p "y/N? "

if [[ ${REPLY} != y ]]; then
    echo "Aborting."
    exit 1
fi

mkdir -p ${scriptdir}
mkdir -p ${resultdir}
${WORKSCRIPT} ${binary} ${scriptdir} ${resultdir} ${config} ${bmpath}

for script in ${scriptdir}/*.sh; do
    echo ${script};
    sbatch ${script};
    sleep 1;
done

