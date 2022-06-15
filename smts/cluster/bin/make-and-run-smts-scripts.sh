#!/bin/bash

function get_abs_path {
  echo $(cd $(dirname $1); pwd)/$(basename $1)
}

SCRIPT_ROOT=$(get_abs_path $(dirname $0))

BMBASE=${BMBASE:-/home/hyvaerinen/benchmarks}
DEFAULTSMTS=${DEFAULTSMTS:-/home/masoud/SMTS/server/smts.py}
DEFAULTCONFIG=empty.smt2
WORKSCRIPT=${SCRIPT_ROOT}/make_scripts_smts.sh

usage="Usage: $0 [-h] [-s <smts-server>] [-l <lemma_sharing> true | false] [-p <partitioning> true | false] [-c <config>] [-b <QF_UF|QF_LRA|QF_LIA|QF_RDL|QF_IDL>] [-f <flavor>] [-m true | false] [-fp <selected instances>]"

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
      -fp|--file_path)
        file_path=$2
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

if [ ${benchmarks} == QF_UF ]; then
    bmpath=${BMBASE}/QF_UF;
elif [ ${benchmarks} == QF_LRA ]; then
    bmpath=${BMBASE}/QF_LRA;
elif [ ${benchmarks} == newQF_LRA ]; then
    bmpath=${BMBASE}/newQF_LRA;
elif [ ${benchmarks} == QF_LIA ]; then
    bmpath=${BMBASE}/QF_LIA;
elif [ ${benchmarks} == QF_RDL ]; then
    bmpath=${BMBASE}/QF_RDL;
elif [ ${benchmarks} == QF_IDL ]; then
    bmpath=${BMBASE}/QF_IDL;
elif [ ${benchmarks} == QF_UFLIA ]; then
    bmpath=${BMBASE}/QF_UFLIA;
elif [ ${benchmarks} == QF_UFLRA ]; then
    bmpath=${BMBASE}/QF_UFLRA;
else
    echo "Unknown benchmark ${benchmarks}"
    exit 1
fi

n_benchmarks=0
if [ -z ${file_path} ]; then
    bmset=${bmpath}/*.smt2.bz2
    n_benchmarks=$(ls ${bmset} |wc -l)
else
    chmod +r ${file_path}
    while IFS= read -r line;
    do
      bmset+=${bmpath}/$line' ';
      ((n_benchmarks=n_benchmarks+1))
    done < ${file_path}
fi



echo $bmset

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

scriptdir=smts-${flavor}-scripts-$(date +'%F')-${lemma_sharing_str}${partitioning_str}-${benchmarks}${mv_str}
resultdir=smts-${flavor}-results-$(date +'%F')-${lemma_sharing_str}${partitioning_str}-${benchmarks}${mv_str}

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
${WORKSCRIPT} ${smtServer} ${lemma_sharing} ${partitioning} ${scriptdir} ${resultdir} ${config} ${bmset}

for script in ${scriptdir}/*.sh; do
    echo ${script};
    sbatch ${script};
    sleep 1;
done

