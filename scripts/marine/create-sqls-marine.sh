#!/bin/bash

script_dir=$(realpath $(dirname $0))
BASEDIR=$(dirname $script_dir)
config_script=${BASEDIR}/glamod-config.py

REPORT_TYPE=$1

release=$2

if [ $# != 2 ]
then
	echo "Usage: <report type> <release i.e. r2.0>"
	exit
fi


if [ ! $REPORT_TYPE ] || [[ ! $REPORT_TYPE =~ ^[023]$ ]]; then
    echo "[ERROR] Must provide report type of: 0, 2 or 3."
    exit
fi

#BASE_OUTPUT_DIR=/gws/nopw/j04/c3s311a_lot2/data/cdmlite/r201910/marine
#BASE_OUTPUT_DIR=/work/scratch-nompiio/astephen/glamod/r202001/cdmlite/marine
BASE_OUTPUT_DIR=$($config_script ${release}:lite:marine:outputs:workflow)

#/${REPORT_TYPE}
#lotus_dir=/gws/smf/j04/c3s311a_lot2/ingest/log/populate/lotus-marine
lotus_dir=$($config_script ${release}:lite:marine:outputs:lotus)

queue="high-mem"

mkdir -p $lotus_dir

#mode=batch
mode=local

for year in $(ls $BASE_OUTPUT_DIR | sort -r); do

    cmd="$PWD/create-sql-marine-year.sh $REPORT_TYPE $year $release"

    #todo: updated sql_id to include release
    sql_id="marine-${REPORT_TYPE}-${year}-${release}-sql"
    lotus_base=$lotus_dir/$sql_id

    if [ $mode == 'batch' ]; then
        #cmd="bsub -q short-serial -W 02:00 -o ${lotus_base}.out -e ${lotus_base}.err $cmd"
        cmd="sbatch -p ${queue} --time=18:00:00 -o ${lotus_base}.out -e ${lotus_base}.err $cmd"
    fi

    echo "[INFO] Running: $cmd"
    $cmd
 
done
