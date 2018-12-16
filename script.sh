# create transactions for all active and owner changes
for producer in $(cat blacklist); do
    cleos set account permission -s -j -d $producer active EOS1111111111111111111111111111111114T1Anm -p $producer@active > $producer.active
    cleos set account permission -s -j -d $producer owner EOS1111111111111111111111111111111114T1Anm -p $producer@owner > $producer.owner
done

# merge all the actions into arrays of actives and owner
cat *.active | jq -s 'map(.actions[0])' > merged.actions.activ
cat *.owner | jq -s 'map(.actions[0])' > merged.actions.owne

# delete useless files
rm *.active
rm *.owner

mv merged.actions.activ merged.actions.active
mv merged.actions.owne merged.actions.owner

# create sample tx
cleos set account permission -s -j -d blacklistmee active EOS1111111111111111111111111111111114T1Anm -p blacklistmee@active > sample.active
cleos set account permission -s -j -d blacklistmee owner EOS1111111111111111111111111111111114T1Anm -p blacklistmee@owner > sample.owner

# change expirations and attach actions to sample trxs
cat sample.owner | jq '.ref_block_num = 0 | .ref_block_prefix = 0 | .expiration = "2018-12-25T00:00:00"' | jq ".actions = $(cat merged.actions.owner)" > owner.trx
cat sample.active | jq '.ref_block_num = 0 | .ref_block_prefix = 0 | .expiration = "2018-12-25T00:00:00"' | jq ".actions = $(cat merged.actions.active)" > active.trx

rm merged.actions.* sample.*

# wrap the transactions
cleos wrap exec -s -j -d libertyblock active.trx > active.wrapped.trx.tmp
cleos wrap exec -s -j -d libertyblock owner.trx > owner.wrapped.trx.tmp
cat owner.wrapped.trx.tmp | jq '.ref_block_num = 0 | .ref_block_prefix = 0 | .expiration = "2018-12-25T00:00:00"' > owner.wrapped.trx
cat active.wrapped.trx.tmp | jq '.ref_block_num = 0 | .ref_block_prefix = 0 | .expiration = "2018-12-25T00:00:00"' > active.wrapped.trx
rm *.trx.tmp

# get a list of active producers
PRODUCERS=$(cleos -u 'https://mainnet.libertyblock.io:7777' system listproducers -l 30 | tail -n +2 | head -n 30 | awk '{print $1}')
for prod in $PRODUCERS; do
    echo "{ \"actor\": \"$prod\", \"permission\": \"active\" }" > $prod.perm
done
cat *.perm | jq -s '' > producers.json
rm *.perm
