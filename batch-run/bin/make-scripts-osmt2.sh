#!/bin/bash

DEFAULTOSMT=opensmt
DEFAULTCONFIG=""
DEFAULTNCPUS=16
BENCHMARKPATH=/u1/hyvaeria/smt-lib
DEFAULTFLAVOR=master
DEFAULTTRACK=non-incremental

usage="Usage: $0 [-h] [-f <flavor>] [-c config] [-b <opensmt-path>] [-n <n-cpus>] -d <smtlib-logic> [-t incremental | non-incremental] [-y ask | noask]"

mode=ask

while [ $# -gt 0 ]; do
    case $1 in
      -h|--help)
        echo "${usage}"
        exit 1
        ;;
      -f|--flavor)
        flavor=$2
        ;;
      -c|--config)
        config=$2
        ;;
      -s|--scripts)
        scripts=$2
        ;;
      -b|--osmt)
        osmt=$2
        ;;
      -n|--ncpus)
        ncpus=$2
        ;;
      -d|--division)
        division=$2
        ;;
      -t|--track)
        track=$2
        ;;
      -y|--yes)
        mode=$2
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

if [ -z ${osmt} ]; then
    osmt=${DEFAULTOSMT}
fi

if [ -z ${config} ]; then
    config=${DEFAULTCONFIG}
fi

if [ -z ${flavor} ]; then
    flavor=${DEFAULTFLAVOR}
fi

if [ -z ${ncpus} ]; then
    ncpus=${DEFAULTNCPUS}
fi

if [ -z ${division} ]; then
    echo "Division not specified"
    exit 1
fi

if [ -z ${track} ]; then
    track=${DEFAULTTRACK}
elif [ ${track} != non-incremental ] && [ ${track} != incremental ]; then
    echo "Unknown track ${track}"
    exit 1
fi

if [ ${track} == incremental ]; then
    div_path_name=$(echo ${division} |tr '[:upper:]' '[:lower:]')
else
    div_path_name=${division}
fi

if [ ! -z ${config} ] && [ ! -f ${config} ]; then
    echo "Config ${config} not found"
    exit 1
fi

date=$(date +'%F')
scripts=osmt2-${flavor}-scripts-${date}-${track}-${division}
results=osmt2-${flavor}-results-${date}-${track}-${division}

echo "Constructing and running as follows:"
echo " - osmt: ${osmt} ($(stat -c '%y' ${osmt}))"
echo " - flavor: ${flavor}"
echo " - track: ${track}"
echo " - division: ${division}"
echo " - scripts: ${scripts}"
echo " - results: ${results}"
echo " - config: ${config}"
echo " - ncpus: ${ncpus}"
echo

if [ ${mode} == ask ]; then
    echo "Construct and run the above jobs locally?"
    read -p "y/N? "

    if [[ ${REPLY} != y ]]; then
        echo "Aborting."
        exit 1
    fi
fi

rm -rf ${scripts} ${results}
mkdir -p ${scripts} ${results}

divisionpath=${BENCHMARKPATH}/${track}/${div_path_name}

files=()
for file in $(find ${divisionpath} -name '*.smt2'); do
    files+=( ${file} )
done

count=0
set -- "${files[@]}"
while (( $# )); do
    r=0
    scriptfile=$(printf "${scripts}/%04d.sh" ${count})
    outfilebase=$(printf "${results}/%04d" ${count})
    echo ${scriptfile}
    cat > ${scriptfile} << __EOF__
#!/bin/bash
osmt=${osmt}
config=${config}

__EOF__
    while [ ${r} -lt ${ncpus} ] && [ $# -gt 0 ]; do
        file=${1}
        outfile=${outfilebase}-${r}.out
        errfile=${outfilebase}-${r}.err
        timefile=${outfilebase}-${r}.time
        cat >> ${scriptfile} << __EOF__
(
  file=${file}
  timefile=${timefile}
  echo \${file}
  sh -c "ulimit -St 10; ulimit -Sv 4000000; /usr/bin/time -o \${timefile} \${osmt} \${config} \${file} "
) > ${outfile} 2> ${errfile} &
__EOF__
        r=$((${r}+1))
        shift
    done
    echo "wait" >> ${scriptfile}
    chmod +x ${scriptfile}
    count=$((${count}+1))
done

if [ $(ls ${scripts}/*.sh 2>/dev/null|wc -l) -eq 0 ]; then
    echo "No files."
    exit 1
fi

for script in ${scripts}/*.sh; do
    echo -n "${script} ";
    ${script};
    echo "done"
done

