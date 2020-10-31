#!/bin/bash

function get_abs_path {
  echo $(cd $(dirname $1); pwd)/$(basename $1)
}

SCRIPT_ROOT=$(get_abs_path $(dirname $0))

BMBASE=${BMBASE:-~/benchmarks/}
DEFAULTOSMT=${DEFAULTOSMT:-~/bin/opensmt}
DEFAULTCONFIG=empty.smt2
WORKSCRIPT=${SCRIPT_ROOT}/make_scripts_osmt2.sh

usage="Usage: $0 [-h] [-o <osmt2-binary>] [-c <config>] -b <QF_UF|QF_LRA|QF_LIA> [-f <flavor>]"

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

if [ ${benchmarks} == QF_UF ]; then
    bmpath=${BMBASE}/QF_UF;
elif [ ${benchmarks} == QF_LRA ]; then
    bmpath=${BMBASE}/QF_LRA;
elif [ ${benchmarks} == QF_LIA ]; then
    bmpath=${BMBASE}/QF_LIA;
else
    echo "Unknown benchmark ${benchmarks}"
    exit 1
fi

n_benchmarks=$(ls ${bmpath}/*.smt2.bz2 |wc -l)

echo "Binary:"
echo " - ${binary}"
echo "Flavor:"
echo " - ${flavor}"
echo "Modification date:"
echo " - $(date -r ${binary})"
echo "Benchmark set (total ${n_benchmarks}):"
echo " - ${bmpath}"

scriptdir=osmt2-${flavor}-scripts-$(date +'%F')-non-incremental-${benchmarks}
resultdir=osmt2-${flavor}-results-$(date +'%F')-non-incremental-${benchmarks}

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
${WORKSCRIPT} ${binary} ${scriptdir} ${resultdir} ${config} ${bmpath}/*.smt2.bz2

for script in ${scriptdir}/*.sh; do
    echo ${script};
    sbatch ${script};
    sleep 1;
done

