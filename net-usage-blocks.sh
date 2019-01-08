START_BLOCK=35000000
COUNT=172800
END_BLOCK=$(echo "$START_BLOCK + $COUNT" | bc)

for BLOCK in $(seq $START_BLOCK $END_BLOCK); do
    NET_USAGE=$(cleos get block $BLOCK | jq '.transactions[] | .net_usage_words' | paste -sd+ | bc)
    if [ ! -z $NET_USAGE ]; then
        echo $NET_USAGE >> "net-$START_BLOCK-$END_BLOCK"
    fi
done
