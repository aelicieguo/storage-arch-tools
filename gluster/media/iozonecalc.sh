#!/bin/bash
# grep Children iozone--large-file-rw--mag-raid6-local-1-node-1-client-1-worker.results | grep write | awk -F= '{print $2}' | awk '{print $1}'

file=$1

listvals=()

function _calc() {
  declare -a i=("${!1}")
  total=$(echo ${i[@]} | sed s/\ /+/g | bc)
  count=${#i[@]}
  avg=$(echo "scale=2; $total / $count" | bc)
  sd=$(echo ${i[@]} | awk -v M=$count '{x+=$0;y+=$0^2}END{print sqrt(y/M-(x/M)^2)}')
  echo "$2 = $avg (δ $sd)"
  if [ "$3" == "true" ]; then
    listvals+=("$(echo "scale=2; $sd / $avg" | bc)")
  fi
  listvals+=("$avg")
}


echo ""

label="Tot Write Throughput"
iterations=($(grep Children $1 | grep writers | awk -F= '{print $2}' | awk '{print $1}'))
_calc iterations[@] "$label" true

label="Min Write Throughput"
iterations=($(grep -A4 Children $1 | grep -A4 writers | grep 'Min throughput' | awk -F= '{print $2}' | awk '{print $1}'))
_calc iterations[@] "$label"

label="Max Write Throughput"
iterations=($(grep -A4 Children $1 | grep -A4 writers | grep 'Max throughput' | awk -F= '{print $2}' | awk '{print $1}'))
_calc iterations[@] "$label"

label="Avg Write Throughput"
iterations=($(grep -A4 Children $1 | grep -A4 writers | grep 'Avg throughput' | awk -F= '{print $2}' | awk '{print $1}'))
_calc iterations[@] "$label"

echo -e "spreadsheet:
δ/µ\ttot_write\tmin_write\tmax_write\tavg_write
${listvals[*]}" | sed s/\ /\\t/g
listvals=()

echo ""

label="Tot Read Throughput"
iterations=($(grep Children $1 | grep readers | awk -F= '{print $2}' | awk '{print $1}'))
_calc iterations[@] "$label" true

label="Min Read Throughput"
iterations=($(grep -A4 Children $1 | grep -A4 readers | grep 'Min throughput' | awk -F= '{print $2}' | awk '{print $1}'))
_calc iterations[@] "$label"

label="Max Read Throughput"
iterations=($(grep -A4 Children $1 | grep -A4 readers | grep 'Max throughput' | awk -F= '{print $2}' | awk '{print $1}'))
_calc iterations[@] "$label"

label="Avg Read Throughput"
iterations=($(grep -A4 Children $1 | grep -A4 readers | grep 'Avg throughput' | awk -F= '{print $2}' | awk '{print $1}'))
_calc iterations[@] "$label"

echo -e "spreadsheet:
δ/µ\ttot_read\tmin_read\tmax_read\tavg_read
${listvals[*]}" | sed s/\ /\\t/g
