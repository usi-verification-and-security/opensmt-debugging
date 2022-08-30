#!/bin/bash

master="osmt2-master-results-2022-03-$1-non-incremental-interesting"
lookahead="osmt2-lookahead-results-2022-03-$1-non-incremental-interesting"

./compare.sh $master $lookahead
mv "$lookahead.list" "res$2l.list"
mv "$master.list" "res$2.list"

./compare_nodes.sh $master $lookahead
mv "$lookahead.list" "res$2l_nodes.list"
mv "$master.list" "res$2_nodes.list"

./compare_disctinct_vars.sh $master $lookahead
mv "$lookahead.list" "res$2l_vars.list"
mv "$master.list" "res$2_vars.list"

./compare_operators.sh $master $lookahead
mv "$lookahead.list" "res$2l_operators.list"
mv "$master.list" "res$2_operators.list"

./compare_complexity.sh $master $lookahead
mv "$lookahead.list" "res$2l_compl.list"
mv "$master.list" "res$2_compl.list"

rm -r $lookahead
rm -r $master
