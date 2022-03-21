const fs = require('fs');
const readline = require('readline');

const Start = process.argv[3];

async function processLineByLine() {

  const value = process.argv[2];

  //This function gives us the new contract value, which we desire.
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

  let myArray 
  switch(value){
    case "broker":
      myArray =  await Ethereum(contractAddress)
      await fs.writeFile(`../../EthereumSetup/EtherPier${Start}/pier${Start}/ether/config/ethereum.toml`, '', function(){console.log(`reset`)})

      if(Start == '01'){
      //Becouse Broker is always first we set it here to delet the old one
      await fs.writeFile('../SetupInfo.txt', '', function(){console.log(`reset SetupInfo.txt`)} )
      }
      var logger = fs.createWriteStream('../SetupInfo.txt', {
        flags: `a` 
      })
      logger.write(`EhterPier${Start}\n`);
      logger.write(`brokerAddress: ${contractAddress}\n`)
      

      break;
    case "dataSwapper":
      // myArray = await DataSwapper(contractAddress);
      // await fs.writeFile(`../../EthereumSetup/EtherPier${Start}/pier${Start}/ether/config/ethereum.toml`, '', function(){console.log(`reset`)})

      
      
      var logger = fs.createWriteStream('../SetupInfo.txt', {
        flags: `a` 
      })
      logger.write(`dataSwapperAddress: ${contractAddress}\n`)

      break;
    case "transfer":
      // myArray = await Transfer(contractAddress);
      // await fs.writeFile(`../../EthereumSetup/EtherPier${Start}/pier${Start}/ether/config/ethereum.toml`, '', function(){console.log(`reset`)})


      
      var logger = fs.createWriteStream('../SetupInfo.txt', {
        flags: `a` 
      })
      logger.write(`transferAddress: ${contractAddress}\n`)
      break;


  }
  

  await editor(myArray)



}

async function Transfer(myString){
  let CurrentArray = [];
  const fileStream = fs.createReadStream(`../../EthereumSetup/EtherPier${Start}/pier${Start}/ether/config/ethereum.toml`);

  const rl = readline.createInterface({
    input: fileStream,
    crlfDelay: Infinity
  });

  for await (const line of rl) {
    let splitter = line.split("=");
    console.log(splitter)
    if(splitter[1] == `"transfer.abi"`){
      splitter[0] = `${myString}`;
      let newLine = `${splitter[0]}=${splitter[1]}`
      CurrentArray.push(newLine);
      
    }
    else{
      CurrentArray.push(line)
    }
  }

  return CurrentArray;

}

async function DataSwapper(myString){
  let CurrentArray = [];
  const fileStream = fs.createReadStream(`../../EthereumSetup/EtherPier${Start}/pier${Start}/ether/config/ethereum.toml`);

  const rl = readline.createInterface({
    input: fileStream,
    crlfDelay: Infinity
  });

  for await (const line of rl) {
    let splitter = line.split("=");
    console.log(splitter)
    if(splitter[1] == `"data_swapper.abi"`){
      splitter[0] = `${myString}`;
      let newLine = `${splitter[0]}=${splitter[1]}`
      CurrentArray.push(newLine);
      
    }
    else{
      CurrentArray.push(line)
    }
  }

  return CurrentArray;

}

async function Ethereum(myString){

  let CurrentArray = [];
  const fileStream = fs.createReadStream(`../../EthereumSetup/EtherPier${Start}/pier${Start}/ether/config/ethereum.toml`);

  const rl = readline.createInterface({
    input: fileStream,
    crlfDelay: Infinity
  });

  for await (const line of rl) {
    let splitter = line.split(" ");
    if(splitter[0] == "contract_address"){
      splitter[2] = `"${myString}"`;
      let newLine = `${splitter[0]} ${splitter[1]} ${splitter[2]}`
      CurrentArray.push(newLine);
      
    }
    else{
      CurrentArray.push(line)
    }
  }

  return CurrentArray;

    
}


async function editor(myArray){
  //blank out the file

  var logger = fs.createWriteStream(`../../EthereumSetup/EtherPier${Start}/pier${Start}/ether/config/ethereum.toml`, {
    flags: `a` 
  })

  for(let line in myArray){
    logger.write(`${myArray[line]}\n`)
  }

  logger.end();
}

processLineByLine() 