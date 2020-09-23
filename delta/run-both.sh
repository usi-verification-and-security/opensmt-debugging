#!/usr/bin/env bash

# 0 - sat
# 1 - unsat
# 2 - unknown


osmt=opensmt
reference=z3

usage="Usage: $0 [-h] [-o <opensmt>] [-r <reference>] <file.smt2>"

while [ $# -gt 0 ]; do
    case $1 in
        -h|--help)
            echo "${usage}"
            exit 1
            ;;
        -o|--opensmt)
            osmt=$2
            ;;
        -r|--reference)
            reference=$2
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

out_osmt=`$osmt $1`
echo $out_osmt
res_osmt=2

if [[ $out_osmt == 'sat' ]]; then
    res_osmt=0
elif [[ $out_osmt == 'unsat' ]]; then
    res_osmt=1
fi


out_reference=`${reference} $1`
echo $out_reference
res_reference=2

if [[ $out_reference == 'sat' ]]; then
    res_reference=0
elif [[ $out_reference == 'unsat' ]]; then
    res_reference=1
fi

echo "testing if ${res_osmt} == ${res_reference}"
if [[ ${res_osmt} -eq ${res_reference} ]]; then
    echo "This is the case"
    exit 0
else
    echo "This is not the case"
    exit 1
fi
