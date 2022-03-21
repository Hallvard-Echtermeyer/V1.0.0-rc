//This script finds the chain from 
//./pier --repo ~/.pier appchain register --name=ethereum --type=ether --consensusType POS --validators=~/.pier1/ether/ether.validators --desc="ethereum appchain for test" --version=1.0.0
// and makes it usable in the script, as well as places the info in SetupInfo.txt

//appchain register successfully, chain id is 0xcb33b10104cd217aAB4b302e9BbeEd1957EDaA31, proposal id is 0xcb33b10104cd217aAB4b302e9BbeEd1957EDaA31-0

const fs = require('fs');
const readline = require('readline');

const Info = process.argv[2];

async function getChainId(){

    const fileStream = fs.createReadStream('../Bitxhub/chainId.txt');

    const rl = readline.createInterface({
        input: fileStream,
        crlfDelay: Infinity
    });
    let chainId
    let proposalId;
    for await (const line of rl){
        let splitter = line.split(" ");
        console.log(splitter)
        chainId = splitter[5];
        proposalId =`${splitter[5]}-0`
        // if(splitter.length > 9){
        //     chainId = splitter[9].replace(',', '');
        //     proposalId = splitter[13]
        // }
    }

    console.log(chainId);
    console.log(proposalId);

    var logger = fs.createWriteStream('../SetupInfo.txt', {
        flags: `a` 
      })
    logger.write(`ChainID: ${chainId}\n`);
    logger.write(`ProposalID: ${proposalId}\n`);

    
    // let myArray = await addToSh(proposalId);
    // await editor(myArray)



}

async function addToSh(myID){
    let CurrentArray = [];
  const fileStream = fs.createReadStream(`../Bitxhub/InitPier.sh`);

  const rl = readline.createInterface({
    input: fileStream,
    crlfDelay: Infinity
  });

  for await (const line of rl) {
    let splitter = line.split(" ");
    if(splitter[6] == `--id`){
      splitter[7] = `${myID}`;
      let newLine = `${splitter[0]} ${splitter[1]} ${splitter[2]} ${splitter[3]} ${splitter[4]} ${splitter[5]} ${splitter[6]} ${splitter[7]} ${splitter[8]} ${splitter[9]} ${splitter[10]} ${splitter[11]}`
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
    await fs.writeFile('../Bitxhub/InitPier.sh', '', function(){console.log(`reset InitPier.sh`)} )
  
    var logger = fs.createWriteStream(`../Bitxhub/InitPier.sh`, {
      flags: `a` 
    })
  
    for(let line in myArray){
      logger.write(`${myArray[line]}\n`)
    }
  
    logger.end();
  }

// 9 13

getChainId()