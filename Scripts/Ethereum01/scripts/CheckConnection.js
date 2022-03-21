const Web3 = require('web3');
const Provider = require('@truffle/hdwallet-provider');
//const MyContract = require('./build/contracts/MyContract.json');
const DataSwapper01 = require('../build/contracts/DataSwapper.json');
const Broker01 = require('../build/contracts/Broker.json')

const DataSwapper02 = require('../../Ethereum02/build/contracts/DataSwapper.json')
const Broker02 = require('../../Ethereum02/build/contracts/Broker.json')





const address = '0xfBe29Cc66a5680Fbc0305f3A11369becc78AC945';
const privateKey = '3a733f78f96937987c4086ff380f19802e5b754e96db0fc215b9ee9e32d5007f';
const infuraUrl = 'https://rinkeby.infura.io/v3/43b36e4162f04775b91869b9fed5e5c8'; 

const infuraUrl02 = 'https://rinkeby.infura.io/v3/731722c66a504aa6bcc25135f3dfc3f9'

const init = async () =>{

    //----------------------------- All the contract addresses, needs to be gotten from SetupInfo.txt-----------------------------
    let TransferAddress = '0xfB1CeeC48B7d8f8dFE364B4c75523206c146A181'
    let SwapperAddress = '0xF682536154B375C8dba09ff0e85f02E4A1eA9d76'
    
    let SecondTransferAddress = '0xe565fefAdf304B8d4b0a4c1B35bbDb69C18dDF0a'
    let SecondSwapperAddress = '0x31a78C4d79f71fD1fD80fcAAcCc2b5313CF2db5B'
    let SecondChainID = '0x7646DFE5a79721426AEFCA2c325f9CFA2635b118'
    //-----------------------------------------------------------------------------------------------------------------
    
    //--------------------------------------------- Init contracts of Ethereum01
    const provider01 = new Provider(privateKey, infuraUrl); 
    const web3 = new Web3(provider01);
    const networkId = await web3.eth.net.getId();

    const dataSwapper01 = new web3.eth.Contract(
        DataSwapper01.abi,
        DataSwapper01.networks[networkId].address
      );

    const broker01 = new web3.eth.Contract(
        Broker01.abi,
        Broker01.networks[networkId].address
    )

    //--------------------------------------------------------------------------------------------

    //--------------------------------------- Init contracts of Ethereum02
    const provider02 = new Provider(privateKey, infuraUrl02); 
    const web302 = new Web3(provider02);
    const networkId02 = await web302.eth.net.getId();

    const dataSwapper02 = new web3.eth.Contract(
        DataSwapper02.abi,
        DataSwapper02.networks[networkId02].address
      );

    const broker02 = new web3.eth.Contract(
        Broker02.abi,
        Broker02.networks[networkId02].address
    )
    //---------------------------------------------------------------------------------

    //Set the data for K V pair on both 01 and 02
    const receipt01 = await dataSwapper01.methods.set("key1", "value01").send({ from: address });
    console.log(await dataSwapper01.methods.getData("key1").call());

    const receipt02 = await dataSwapper02.methods.set("key2", "value03").send({ from: address });
    console.log(await dataSwapper02.methods.getData("key2").call());
    
    await broker01.methods.register(SwapperAddress).send({ from: address });
    await broker01.methods.register(TransferAddress).send({ from: address });
    // await broker01.methods.register(SecondSwapperAddress).send({ from: address });
    // await broker01.methods.register(SecondTransferAddress).send({ from: address });

    // await broker02.methods.register(SwapperAddress).send({ from: address });
    // await broker02.methods.register(TransferAddress).send({ from: address });
    await broker02.methods.register(SecondSwapperAddress).send({ from: address });
    await broker02.methods.register(SecondTransferAddress).send({ from: address });

    


    const second = await dataSwapper01.methods.get(SecondChainID, SecondSwapperAddress, "key2").send({from: address});

    // console.log(await dataSwapper01.methods.getData("key10001").call());
    // console.log(await dataSwapper01.methods.getData("key10002").call());
    // console.log(await dataSwapper01.methods.getData("key3").call());

    console.log("done");
  
   
}

init()