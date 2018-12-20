for ACCOUNT in $(cat blacklist); do 
    BALANCE=$(cleos -u "http://mainnet.libertyblock.io:8888" get table eosio.token $ACCOUNT accounts | jq ".rows[0].balance" | tr -d '"' | tr -d "EOS")
    echo "$ACCOUNT: $BALANCE"
    BAL_GT_1=$(echo "$BALANCE >= 1.0" | bc -l)
    if [ $BAL_GT_1 -eq 1 ]; then
        echo "Restaking $ACCOUNT"
        cleos -u 'http://mainnet.libertyblock.io:8888' system delegatebw -s -j -d $ACCOUNT $ACCOUNT "$BALANCE EOS" "0 EOS" >> actions.tmp
    fi
done 

# merge all the actions 
cat actions.tmp | jq -s 'map(.actions[0])' > merged.actions.tmp

# create sample tx
cleos -u 'http://mainnet.libertyblock.io:8888' set account permission -s -j -d blacklistmee active EOS1111111111111111111111111111111114T1Anm -p blacklistmee@active > sample.tmp

# change expirations and attach actions to sample trx
cat sample.tmp | jq '.ref_block_num = 0 | .ref_block_prefix = 0 | .expiration = "2018-12-25T00:00:00"' | jq ".actions = $(cat merged.actions.tmp)" > stake.tmp

# wrap the transactions
cleos -u 'http://mainnet.libertyblock.io:8888' wrap exec -s -j -d libertyblock stake.tmp > stake.wrapped.trx.tmp
cat stake.wrapped.trx.tmp | jq '.ref_block_num = 0 | .ref_block_prefix = 0 | .expiration = "2018-12-25T00:00:00"' > stake.wrapped.trx

# get a list of active producers
PRODUCERS=$(cleos -u 'http://mainnet.libertyblock.io:8888' system listproducers -l 30 | tail -n +2 | head -n 30 | awk '{print $1}')
for prod in $PRODUCERS; do
    echo "{ \"actor\": \"$prod\", \"permission\": \"active\" }" > $prod.perm
done
cat *.perm | jq -s '' > producers.json
rm *.perm

# Delete temp files
rm *.tmp
