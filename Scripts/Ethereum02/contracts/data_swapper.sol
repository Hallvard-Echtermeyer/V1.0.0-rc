pragma solidity >=0.5.7;

contract DataSwapper {
    mapping(string => string) dataM; // map for accounts
    Hasher hasher = Hasher(0x00000000000000000000000000000000000000fa);
    // change the address of Broker accordingly
    address BrokerAddr = 0xD0E1B0d7D04CA60F11Ab3C58b7782B2379fa9090;
    DataBroker broker = DataBroker(BrokerAddr);

    // AccessControl
    modifier onlyBroker() {
        require(msg.sender == BrokerAddr, "Invoker are not the Broker");
        _;
    }

    // Business contract for data exchange class
    function getData(string memory key) public returns (string memory) {
        return dataM[key];
    }

    function get(
        address destChainID,
        string memory destAddr,
        string memory key
    ) public {
        bool ok = broker.InterchainDataSwapInvoke(destChainID, destAddr, key);
        require(ok);
    }

    function set(string memory key, string memory value) public {
        dataM[key] = value;
    }

    function interchainSet(string memory key, string memory value)
        public
        onlyBroker
    {
        set(key, value);
    }

    function interchainGet(string memory key)
        public
        view
        onlyBroker
        returns (bool, string memory)
    {
        return (true, dataM[key]);
    }
}

contract DataBroker {
    function InterchainDataSwapInvoke(
        address destChainID,
        string memory destAddr,
        string memory key
    ) public returns (bool);
}

contract Hasher {
    function getHash() public returns (bytes32);
}
