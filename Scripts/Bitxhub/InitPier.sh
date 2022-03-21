# cd ../../EthereumSetup/EtherPier$1/pier$1/RelayChain/

# export LD_LIBRARY_PATH=$(pwd)
# ./bitxhub --repo ../../../build_solo client governance vote --id 0x62e08aa4fa5310619bb81f0232dad3fe0c9c0025-0 --info approve --reason approve

# ./bitxhub --repo ../../../build_solo client governance proposals --type AppchainMgr

# cd ../../

cd ../../EthereumSetup/EtherPier$1

export LD_LIBRARY_PATH=$(pwd)

pier --repo=pier$1 rule deploy --path=pier$1/ether/config/validating.wasm

pier --repo=pier$1 start
