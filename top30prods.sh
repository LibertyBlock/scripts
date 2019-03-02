# get a list of active producers
PRODUCERS=$(cleos -u 'http://kylin.libertyblock.io:8888' system listproducers -l 30 | tail -n +2 | head -n 30 | awk '{print $1}')
for prod in $PRODUCERS; do
    echo "{ \"actor\": \"$prod\", \"permission\": \"active\" }" > $prod.perm.tmp
done
cat *.perm.tmp | jq -s '' > producers.json
rm *.perm.tmp
