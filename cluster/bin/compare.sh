#!/bin/bash

function get_abs_path {
  echo $(cd $(dirname $1); pwd)/$(basename $1)
}

CLUSTER_BIN_ROOT=$(get_abs_path $(dirname $0))
PLOTTING_BIN_ROOT=${CLUSTER_BIN_ROOT}/../../plotting/bin

EXTRACTOR=${CLUSTER_BIN_ROOT}/extract_results_time_osmt2.sh
GNUPLOTTOR=${PLOTTING_BIN_ROOT}/make_scatterplot_time.py
PLOT_MAKEFILE=${PLOTTING_BIN_ROOT}/../Makefile

export epstopdf=${PLOTTING_BIN_ROOT}/epstopdf

if [ $# != 2 ]; then
    echo "Usage: $0 <x-axis-dir> <y-axis-dir>"
    exit 1
fi

xd=$1
yd=$2

regex='\(.*\)-results-\([0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]\)-\(.*\)-\([A-Z_]*\)\(_.*\)\?'

x_branch=$(echo ${xd} |sed s/${regex}/\\1/g)
x_branch=(${x_branch//-/ })
project_x=${x_branch[0]}
x_branch=${x_branch[1]}

y_branch=$(echo ${yd} |sed s/${regex}/\\1/g)
y_branch=(${y_branch//-/ })
project_y=${y_branch[0]}
y_branch=${y_branch[1]}

x_date=$(echo ${xd} |sed s/${regex}/\\2/g)
y_date=$(echo ${yd} |sed s/${regex}/\\2/g)

x_track=$(echo ${xd} |sed s/${regex}/\\3/g)
y_track=$(echo ${yd} |sed s/${regex}/\\3/g)

x_div=$(echo ${xd} |sed s/${regex}/\\4/g)
y_div=$(echo ${yd} |sed s/${regex}/\\4/g)

x_subdiv=$(echo ${xd} |sed s/${regex}/\\5/g)
y_subdiv=$(echo ${yd} |sed s/${regex}/\\5/g)


if [ ${x_div} != ${y_div} ]; then
    echo "Division differ: ${x_div} != ${y_div}"
    exit 1;
fi

if [ x"${x_subdiv}" != x"${y_subdiv}" ]; then
    echo "Subdivision differ: '${x_subdiv}' != '${y_subdiv}'"
    exit 1;
fi

if [ ${x_track} != ${y_track} ]; then
    echo "Tracks differ: ${x_track} != ${y_track}"
    exit 1;
fi

echo "Extracting "
[[ ${xd}.list -nt ${xd} ]] || ${EXTRACTOR} ${xd} osmt2 > ${xd}.list
[[ ${yd}.list -nt ${yd} ]] || ${EXTRACTOR} ${yd} osmt2 > ${yd}.list
echo "done."


name=figures/${x_track}-${x_div}${x_subdiv}-${x_branch}-${x_date}_vs_${y_branch}-${y_date}

mkdir -p figures

echo "Plotting "
${GNUPLOTTOR} ${xd}.list ${yd}.list \
    "${x_branch} ${x_date}"\
    "${y_branch} ${y_date}" \
    "${x_div}" \
    "${x_subdiv}" \
    ${name}.png > \
    ${name}.gp
echo "done."

echo "making "
make -f ${PLOT_MAKEFILE} ${name}.png
echo "done."

echo "The figure is available in"
echo ${USER}@hpc.ics.usi.ch:$(pwd)/${name}.png
