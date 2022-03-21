#!/bin/bash
#remove old build files

cd ../Ethereum$1

rm -rf build

#compile the scripts 
truffle compile

truffle migrate --network rinkeby --reset -f 2 --to 2 > ../EthereumScripts/h.txt

cd ../EthereumScripts

node abiMaker.js broker $1

node fileReader.js broker $1

# # echo "Now you need to manually copy and paste the Broker contract address into data_swapper.sol and transfer.sol"

node solEditor $1



cd ../Ethereum$1

sleep 5

truffle migrate --network rinkeby --reset -f 3 --to 3 > ../EthereumScripts/h.txt

cd ../EthereumScripts

# node abiMaker.js transfer $1

node fileReader.js transfer $1

cd ../Ethereum$1


sleep 5

truffle migrate --network rinkeby --reset -f 4 --to 4 > ../EthereumScripts/h.txt

cd ../EthereumScripts

# node abiMaker.js dataSwapper $1

node fileReader.js dataSwapper $1

cd ../EthereumScripts