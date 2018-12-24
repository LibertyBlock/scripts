// Fetch all the LogRegister events from the EOS 911 ETH contract
//
// To use:
// node fetch-logregister.js > LogRegister.csv

const fs = require('fs');

const Web3 = require('web3');
const web3 = new Web3("https://mainnet.infura.io/v3/a8c1c0a943274566bb4c530477ff225c");

const abi = JSON.parse(fs.readFileSync("eos911_abi.json", "utf-8"));
const contract = new web3.eth.Contract(abi, "0x71f2Ea939984349838578fBd20fd25e649C1d6a3");

contract.getPastEvents("LogRegister", { fromBlock: 5783436, toBlock: "latest" })
    .then(function (events) {
        const rows = events
            .filter(e => e.returnValues.key != '')
            .map(e => `${e.returnValues.user},${e.returnValues.key}`);

        const uniqueRows = Array.from(new Set(rows));
        console.log(uniqueRows.join('\n'));
    });
