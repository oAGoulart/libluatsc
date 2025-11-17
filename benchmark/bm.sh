#!/bin/bash

SIZES=("1000" "10000" "25000" "50000" "75000" "100000" "250000" "500000" "750000" "1000000")
REPEATS=10
RESULTS_FILE="bm.csv"
PAYLOAD_FILE="bm.data"

echo "Method,Size,MeanTime" > $RESULTS_FILE

function create_data()
{
  dd if=/dev/urandom of=$PAYLOAD_FILE bs=1 count="$1" 2> /dev/null
  echo "-> Created file of size $1 bytes."
}

echo "Warming up runs..."
for SIZE in "${SIZES[@]}"; do
  create_data "$SIZE"
done

echo "Starting benchmark..."
for SIZE in "${SIZES[@]}"; do
  create_data "$SIZE"

  TIMES_LUA=""
  TIMES_TSC=""
  TIMES_PY=""
  TIMES_BASH=""

  for i in $(seq 1 $REPEATS); do
    echo "Running for $SIZE bytes ($i/$REPEATS)..."

    TIME=$(lua ./native.lua $PAYLOAD_FILE)
    TIMES_LUA+=" $TIME"

    TIME=$(lua ./tsc.lua $PAYLOAD_FILE)
    TIMES_TSC+=" $TIME"

    TIME=$(python3 ./bm.py $PAYLOAD_FILE)
    TIMES_PY+=" $TIME"

    TBEGIN=$(date +%s.%N)
    lua ./crc32.lua $PAYLOAD_FILE 1>/dev/null
    TEND=$(date +%s.%N)
    TIME=$(echo "$TEND $TBEGIN" | awk '{printf "%.9f", ($1 - $2) * 1000000}')
    TIMES_BASH+=" $TIME"
  done

  AVG=$(echo "$TIMES_LUA" | tr ' ' '\n' | awk '{sum+=$1; n+=1} END {print sum/n}')
  echo "Lua 'clock',$SIZE,$AVG" >> $RESULTS_FILE

  AVG=$(echo "$TIMES_TSC" | tr ' ' '\n' | awk '{sum+=$1; n+=1} END {print sum/n}')
  echo "Lua TSC,$SIZE,$AVG" >> $RESULTS_FILE

  AVG=$(echo "$TIMES_PY" | tr ' ' '\n' | awk '{sum+=$1; n+=1} END {print sum/n}')
  echo "Python 'time',$SIZE,$AVG" >> $RESULTS_FILE

  AVG=$(echo "$TIMES_BASH" | tr ' ' '\n' | awk '{sum+=$1; n+=1} END {print sum/n}')
  echo "Bash 'date',$SIZE,$AVG" >> $RESULTS_FILE

done

rm $PAYLOAD_FILE
echo -e "\nBenchmark finished. Results saved in $RESULTS_FILE"
