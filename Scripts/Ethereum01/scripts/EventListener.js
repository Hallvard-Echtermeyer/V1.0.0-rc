const Web3 = require('web3');
const Provider = require('@truffle/hdwallet-provider');

const MyContract = require('../build/contracts/Broker.json');



const address = '0xfBe29Cc66a5680Fbc0305f3A11369becc78AC945';
const privateKey = '3a733f78f96937987c4086ff380f19802e5b754e96db0fc215b9ee9e32d5007f';
const infuraUrl = 'wss://rinkeby.infura.io/ws/v3/43b36e4162f04775b91869b9fed5e5c8'; 

async function init2(){
    var web3 = new Web3(new Web3.providers.WebsocketProvider('wss://rinkeby.infura.io/ws/v3/43b36e4162f04775b91869b9fed5e5c8'));
    const brokerContract = new web3.eth.Contract(MyContract.abi, "0xaBed58d2bB018D9d7D49bD129f898a89c09A325A");

    const dataSwapperContract = new web3.eth.Contract(MyContract.abi, "0xF682536154B375C8dba09ff0e85f02E4A1eA9d76");

    brokerContract.events.Logger()
    .on('data', function(event){
    console.log(`new event - transaction hash: ${event.transactionHash}`)
    console.log(`new event - sender: ${event.returnValues.message}`);
    //console.log(`new event - id: ${JSON.stringify(event)}`);
    //console.log(`new event - index: ${JSON.stringify(event.returnValues)}`);
    console.log()
    //console.log(`new event - location: ${web3.utils.hexToUtf8(event.returnValues.location)}`);
    }).on('error', function(error, receipt) { // If the transaction was rejected by the network with a receipt, the second parameter will be the receipt.
    console.log(`error`);
    });

    dataSwapperContract.events.Logger()
    .on('data', function(event){
    console.log(`new event - sender: ${event.returnValues.message}`);
    }).on('error', function(error, receipt) { // If the transaction was rejected by the network with a receipt, the second parameter will be the receipt.
    console.log(`error`);
    });
}

init2();