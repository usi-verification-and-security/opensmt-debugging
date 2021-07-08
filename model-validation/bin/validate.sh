#!/usr/bin/env bash

VALIDATOR=~/src/opensmt-debugging/model-validation/bin/validate-cluster-runs.sh

if [[ $# != 2 ]]; then
    echo "Usage: $0 <validation-dir> <track>"
    exit 1;
fi

validation_dir=$1
track=$2

output=${validation_dir}-validations.list;
rm -f ${output};

for file in ${validation_dir}/*.sh.[0-9].out; do
    echo $file;
    ${VALIDATOR} -b ~/benchmarks/${track}/ $file >> ${output};
done

