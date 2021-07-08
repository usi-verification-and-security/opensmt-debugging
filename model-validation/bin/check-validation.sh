#!/usr/bin/env bash

if [[ $# != 1 ]]; then
    echo "Usage $0 <validation-list>"
    exit 1
fi

n_instances=$(grep '.*\.bz2' $1 |wc -l)
n_duplicates=$(grep '.*\.bz2' $1 | uniq -d |wc -l)
echo "Checking results from ${n_instances} instances (${n_duplicates} duplicates)"

grep -v '^/' $1 \
    |grep -v '^Not sat' \
    |grep -v '.*\.bz2' \
    |grep -v '^model_validator_status=VALID' \
    |grep -v '^model_validator_error=none' \
    |grep -v 'starexec-result=sat'

echo "done"

