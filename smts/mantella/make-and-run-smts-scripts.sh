#!/bin/bash

function get_abs_path {
  echo $(cd $(dirname $1); pwd)/$(basename $1)
}

SCRIPT_ROOT=$(get_abs_path $(dirname $0))

BMBASE=${BMBASE:-/home/masoud/dev/benchmarks}
DEFAULTSMTS=${DEFAULTSMTS:-/home/masoud/dev/SMTS/server/smts.py}
DEFAULTCONFIG=empty.smt2
WORKSCRIPT=${SCRIPT_ROOT}/make_scripts_smts.sh

usage="Usage: $0 [-h] [-s <smts-server>] [-c <config>] -b <QF_UF|QF_LRA|QF_LIA|QF_RDL|QF_IDL> [-f <flavor>] [-i true | false]"

incremental=false;

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
      -i|--incremental)
        incremental=$2
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

if [[ ${incremental} == true ]]; then
    incr_str="incremental"
else
    incr_str="non-incremental"
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
n_benchmarks=$(ls ${bmpath}/*.smt2.bz2 |wc -l)

echo "SMTSServer:"
echo " - ${smtServer}"
echo "Flavor:"
echo " - ${flavor}"
echo "Modification date:"
echo " - $(date -r ${smtServer})"
echo "Benchmark set (total ${n_benchmarks}):"
echo " - ${bmpath}"

echo "Incremental Solving:"
echo " - ${incremental}"

scriptdir=smts-${flavor}-scripts-$(date +'%F')-${incr_str}-${benchmarks}
resultdir=smts-${flavor}-results-$(date +'%F')-${incr_str}-${benchmarks}

echo "Work directories:"
echo " - ${scriptdir}"
echo " - ${resultdir}"

echo

echo "Construct and run the above jobs one by one?"
read -p "y/N? "

if [[ ${REPLY} != y ]]; then
    echo "Aborting."
    exit 1
fi

mkdir -p ${scriptdir}
mkdir -p ${resultdir}
${WORKSCRIPT} ${smtServer} ${scriptdir} ${resultdir} ${config} ${bmpath}/*.smt2.bz2

for script in ${scriptdir}/*.sh; do
    echo ${script};
    sh ${script};
    sleep 1;
done

