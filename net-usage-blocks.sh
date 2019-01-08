START_BLOCK=30000000
COUNT=28800
END_BLOCK=$(echo "$START_BLOCK + $COUNT" | bc)

for BLOCK in $(seq $START_BLOCK $END_BLOCK); do
    NET_USAGE=$(cleos get block $BLOCK | jq '.transactions[] | .net_usage_words' | paste -sd+ | bc)
    echo $NET_USAGE >> "net-$START_BLOCK-$END_BLOCK"
done
