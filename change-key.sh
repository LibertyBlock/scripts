ACCOUNT="hezdqnjxgmge"
NEW_KEY="EOS7P1TmuGBdcShxEvweLYkVMYpxpUEeUubjak22mqvAwKDanfcdM"
EXPIRATION="2018-12-25T00:00:00"
EXECUTOR="libertyblock"

cleos set account permission -s -j -d $ACCOUNT active $NEW_KEY owner -p $ACCOUNT > active.tmp
cleos set account permission -s -j -d $ACCOUNT owner $NEW_KEY  -p $ACCOUNT@owner > owner.tmp

# Merge actions
cat *.tmp | jq -s 'map(.actions[0])' > merged.actions.tmp
cat active.tmp | jq ".ref_block_num = 0 | .ref_block_prefix = 0 | .expiration = \"$EXPIRATION\"" | jq ".actions = $(cat merged.actions.tmp)" > trx.tmp

# Wrap it
cleos wrap exec -s -j -d $EXECUTOR trx.tmp > wrapped.tmp
cat wrapped.tmp | jq ".ref_block_num = 0 | .ref_block_prefix = 0 | .expiration = \"$EXPIRATION\"" > wrapped.trx

# Get a list of active producers
PRODUCERS=$(cleos -u 'https://mainnet.libertyblock.io:7777' system listproducers -l 30 | tail -n +2 | head -n 30 | awk '{print $1}')
for prod in $PRODUCERS; do
    echo "{ \"actor\": \"$prod\", \"permission\": \"active\" }" > $prod.perm.tmp
done
cat *.perm.tmp | jq -s '' > producers.json

rm *.tmp
