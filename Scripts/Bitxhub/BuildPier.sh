cd ../../EthereumSetup/EtherPier$1/

rm -rf pier$1

export LD_LIBRARY_PATH=$(pwd)

pier --repo=pier$1 init

cd pier$1

mkdir plugins
mkdir ether

rm -rf pier.toml

cd ../../../Scripts/Bitxhub/

cp eth-client.so ../../EthereumSetup/EtherPier$1/pier$1/plugins
cp -r config/ ../../EthereumSetup/EtherPier$1/pier$1/ether
cp -r RelayChain ../../EthereumSetup/EtherPier$1/pier$1

cd pier$1

cp pier.toml ../../../EthereumSetup/EtherPier$1/pier$1
cp account.key ../../../EthereumSetup/EtherPier$1/pier$1/ether/config
cp password ../../../EthereumSetup/EtherPier$1/pier$1/ether/config 
cp ethereum.toml ../../../EthereumSetup/EtherPier$1/pier$1/ether/config


cd ../../EthereumScripts

source script.sh $1

cd ../../EthereumSetup/EtherPier$1/

export LD_LIBRARY_PATH=$(pwd)

#Seems to be correct, but we get 
#read validators file: open pier01/ether/config/ether.validators: no such file or directory

sleep 2

pier --repo=pier$1 appchain register --name=ethereum --type=ether --validators=pier$1/ether/config/ether.validators --desc="ethereum appchain for test" --version=1.0.0 > ../../Scripts/Bitxhub/chainId.txt

cd ../../Scripts/EthereumScripts

node ChainId.js $1

cd ../Bitxhub

source InitPier.sh $1