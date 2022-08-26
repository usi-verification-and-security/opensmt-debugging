#!/bin/bash

function get_abs_path {
  echo $(cd $(dirname $1); pwd)/$(basename $1)
}

SCRIPT_ROOT=$(get_abs_path $(dirname $0))

BMBASE=${BMBASE:-/home/hyvaerinen/benchmarks-updated}
DEFAULTSMTS=${DEFAULTSMTS:-/home/masoud/SMTS/server/smts.py}
DEFAULTCONFIG=empty.smt2
WORKSCRIPT=${SCRIPT_ROOT}/make_scripts_smts.sh

usage="Usage: $0 [-h] [-s <smts-server>] [-l <lemma_sharing> true | false] [-p <partitioning> true | false] [-c <config>] -b <benchmark path> [-f <flavor>] [-m true | false]"

partitioning=true
lemma_sharing=true;
produce_models=false;

while [ $# -gt 0 ]; do
    case $1 in
      -h|--help)
        echo "${usage}"
        exit 1
        ;;
      -s|--smts-server)
        smtServer=$2
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
      -p|--partitioning)
        partitioning=$2
        ;;
      -l|--lemma_sharing)
        lemma_sharing=$2
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

if [ -z ${smtServer} ]; then
    smtServer=${DEFAULTSMTS}
fi

if [ -z ${config} ]; then
    config=${DEFAULTCONFIG}
fi

if [ -z ${flavor} ]; then
    flavor=$(basename $smtServer | sed 's/smts//g')
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

if [ ! -f $smtServer ]; then
    echo "SMTS Server $smtServer not found"
    exit 1
fi

if [[ ${lemma_sharing} == true ]]; then
    lemma_sharing_str="lemma_sharing"
else
    lemma_sharing_str="non-lemma_sharing"
fi

if [[ ${partitioning} == true ]]; then
    partitioning_str="partitioning"
else
    partitioning_str="non-partitioning"
fi

bmpath=${BMBASE}/${benchmarks};

n_benchmarks=$(find ${bmpath} -name '*.smt2.bz2' |wc -l)

echo "SMTSServer:"
echo " - ${smtServer}"
echo "Flavor:"
echo " - ${flavor}"
echo "Modification date:"
echo " - $(date -r ${smtServer})"
echo "Benchmark set (total ${n_benchmarks}):"
echo " - ${bmpath}"


echo "Lemma Sharing:"
echo " - ${lemma_sharing}"

echo "Partitioning:"
echo " - ${partitioning}"

if [[ ${produce_models} == true ]]; then
    mv_str="-mv"
    WORKSCRIPT=${SCRIPT_ROOT}/make_scripts_smts_models.sh
else
    mv_str=""
fi

echo "Produce models:"
echo " - ${produce_models}"

benchmarks_printable=$(echo ${benchmarks} |tr '/' '_')

scriptdir=smts${lemma_sharing_str}${partitioning_str}-${flavor}-scripts-$(date +'%F')-non-incremental-${benchmarks}${mv_str}
resultdir=smts${lemma_sharing_str}${partitioning_str}-${flavor}-results-$(date +'%F')-non-incremental-${benchmarks}${mv_str}

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
${WORKSCRIPT} ${smtServer} ${lemma_sharing} ${partitioning} ${scriptdir} ${resultdir} ${config} ${bmpath}

for script in ${scriptdir}/*.sh; do
    echo ${script};
    sbatch ${script};
    sleep 1;
done

