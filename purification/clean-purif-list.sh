#!/bin/sh

PURIFLIST=npurifs-list.txt
CLEANED=npurifs-list-cleaned.txt
TIMEOUT=600

MaxEqs=$(
    grep -v '^Command terminated by signal 24' < $PURIFLIST \
    |awk 'BEGIN {max=0} $1 > max {max=$1} END {print max}' \
    )

ntouts=$(grep '^Command terminated by signal 24' < $PURIFLIST \
    |wc -l \
    |awk '{print $1}'
    )
echo "Number of timeouts in purification: $ntouts"

UnknownEqValue=$(echo "$MaxEqs*1.1" | bc -l)

echo $UnknownEqValue

sed 's/^Command terminated by signal 24/'$UnknownEqValue'/g' \
    < $PURIFLIST \
    > $CLEANED

cat << __EOF__ |gnuplot > purif_times.png
set term pngcairo
set logscale x
set xlabel "number of purification equalities"
set ylabel "time"
plot "./npurifs-list-cleaned.txt"
__EOF__
