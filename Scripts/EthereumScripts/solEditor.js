const fs = require('fs');
const readline = require('readline');

const Start = process.argv[2];

async function getBrokerAddress(){
    const fileStream = fs.createReadStream('h.txt');

  const rl = readline.createInterface({
    input: fileStream,
    crlfDelay: Infinity
  });
  let contractAddress = ""
  for await (const line of rl) {
    let trimmer = line.replace(">","").replace(":","").replace("    ","").trim()
    let splitter = trimmer.split(' ');
    if(splitter[0] == "contract"){
        contractAddress = splitter[5];
        break;
    }
  }

  console.log(contractAddress)

  let dataArray = await SolChanger(contractAddress, 'dataSwapper' )
  console.log(dataArray)
  await fs.writeFile(`../Ethereum${Start}/contracts/data_swapper.sol`, '', function(){console.log(`reset`)})
  await solEditor(dataArray,'dataSwapper');
  let transferrArray = await SolChanger(contractAddress, 'transfer')
  console.log(transferrArray)
  await fs.writeFile(`../Ethereum${Start}/contracts/transfer.sol`, '', function(){console.log(`reset`)})
  await solEditor(transferrArray, 'transfer');


}

async function SolChanger(myString, value){
    let CurrentArray = [];
  
    let contract
    if(value == 'dataSwapper'){
        contract = 'data_swapper.sol'
    }
    else{
        contract = 'transfer.sol'
    }
  
    const fileStream = fs.createReadStream(`../Ethereum${Start}/contracts/${contract}`);
  
    const rl = readline.createInterface({
      input: fileStream,
      crlfDelay: Infinity
    });
  
    for await (const line of rl) {
      let splitter = line.split(" ");
      if(splitter[5] == 'BrokerAddr'){
        
        let newLine= `    ${splitter[4]} ${splitter[5]} ${splitter[6]} ${myString};`
        console.log(newLine)
        CurrentArray.push(newLine)
      }
      else{
        CurrentArray.push(line)
      }
    }
  
    return CurrentArray;
  }

  async function solEditor(myArray, value ){
    //blank out the file
  
    let contract
    if(value == 'dataSwapper'){
        contract = 'data_swapper.sol'
    }
    else{
        contract = 'transfer.sol'
    }
  
    var logger = fs.createWriteStream(`../Ethereum${Start}/contracts/${contract}`, {
      flags: 'a' 
    })
  
    for(let line in myArray){
      logger.write(`${myArray[line]}\n`)
    }
  
    logger.end();
  }

  getBrokerAddress();