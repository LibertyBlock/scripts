REFERENDUM_REWARD=42000
VOTES=$(cat QmXSrM7Gg3b9nVnii8JUcCgGyu2rtGyjeTTet1QdQS1Vht)
LENGTH=$(echo $VOTES | jq "length")
for i in $(seq 0 $LENGTH); do
    VOTER=$(echo $VOTES | jq ".[$i].act.data.voter")
    VOTE_AMOUNT=$(echo $VOTES | jq ".[$i].act.data.amount")
    REWARD_AMOUNT=$(echo "scale=3; $VOTE_AMOUNT * $REFERENDUM_REWARD / 36114664" | bc -l | sed 's/^\./0./')
    cleos -u http://mainnet.libertyblock.io:8888 push action everipediaiq transfer "[\"encyclopedia\", $VOTER, \"$REWARD_AMOUNT IQ\", \"referendum #1 reward\"]" -p encyclopedia
done
