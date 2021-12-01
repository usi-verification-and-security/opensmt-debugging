#!/bin/sh

SMTLIBPATH=/u1/hyvaeria/smt-lib/non-incremental
LOGIC=QF_UFLRA

find $SMTLIBPATH/$LOGIC -name '*.smt2' \
  |while read -r file; do
   (
     ulimit -St 600;
     /usr/bin/time -f'%U' ./opensmt $file 2>&1 \
        |grep -v '^unknown' \
        |sed 's/; Added \([0-9][0-9]*\) .*/\1/g'
   ) |tr '\n' ' ';
   echo $file;
  done > npurifs-list.txt

