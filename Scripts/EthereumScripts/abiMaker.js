
const Start = process.argv[3]

const broker = require(`../Ethereum${Start}/build/contracts/Broker.json`);
const data_swapper = require(`../Ethereum${Start}/build/contracts/DataSwapper.json`)
const transfer = require(`../Ethereum${Start}/build/contracts/Transfer.json`)
const fs = require('fs')

function RemoveSpace(file){

    const value = process.argv[2];


    switch(value){
        case "broker":

            let abiJSON  = broker.abi
            let abiString = JSON.stringify(abiJSON)
            console.log(abiString);
            fs.writeFile(`../../EthereumSetup/EtherPier${Start}/pier${Start}/ether/config/broker.abi`, '', function(){console.log(`reset ${file}`)})
            //fs.writeFile('./broker.abi', '');
            fs.writeFile(`../../EthereumSetup/EtherPier${Start}/pier${Start}/ether/config/broker.abi`, abiString, function(){console.log(`coppied ${file}.abi into `)})
            break;
        // case "dataSwapper":
        //     let dataJSON  = data_swapper.abi
        //     let dataabiString = JSON.stringify(dataJSON)
        //     console.log(dataabiString);
        //     fs.writeFile(`../../EthereumSetup/EtherPier${Start}/pier${Start}/ether/config/data_swapper.abi`, '', function(){console.log(`reset ${file}`)})
        //     //fs.writeFile('./broker.abi', '');
        //     fs.writeFile(`../../EthereumSetup/EtherPier${Start}/pier${Start}/ether/config/data_swapper.abi`, dataabiString, function(){console.log(`coppied ${file}.abi into `)})
        //     break;
        // case "transfer":
        //     let transferJSON  = transfer.abi
        //     let transferAbiString = JSON.stringify(transferJSON)
        //     console.log(transferAbiString);
        //     fs.writeFile(`../../EthereumSetup/EtherPier${Start}/pier${Start}/ether/config/transfer.abi`, '', function(){console.log(`reset ${file}`)})
        //     //fs.writeFile('./broker.abi', '');
        //     fs.writeFile(`../../EthereumSetup/EtherPier${Start}/pier${Start}/ether/config/transfer.abi`, transferAbiString, function(){console.log(`coppied ${file}.abi into `)})
        //     break;
        default:
            console.log("no alue")

    }

}


RemoveSpace()