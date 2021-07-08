#!/usr/bin/env bash

osmt=~/src/opensmt/build/opensmt
validator=~/bin/ModelValidator

usage="Usage: $0 [-h] [-o <opensmt>] [-v <modelvalidator>] <file.smt2>"

while [ $# -gt 0 ]; do
    case $1 in
        -h|--help)
            echo "${usage}"
            exit 1
            ;;
        -o|--opensmt)
            osmt=$2
            ;;
        -v|--validator)
            validator=$2
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

if [ $# == 0 ]; then
    echo "No file provided"
    exit 1
fi

# If there is no get-model, the result is by definition ok
grep '(get-model)' $1 > /dev/null || exit 0

model=$(tempfile).out
${osmt} $1 > ${model}

if [[ $(grep '^sat' $model) ]]; then
    sat=true;
else
    sat=false;
fi

if [[ ${sat} == true ]]; then
    echo "Instance is sat.  Continuing"
    ${validator} --smt2 ${1} --model=${model}
    res=$?
    echo "Result is ${res}"
fi

if [[ ${sat} == false || ${res} == 0 ]]; then
    echo "Not sat or res == 0"
    echo "Not to go"
    exit 0
else
    exit 1
fi

