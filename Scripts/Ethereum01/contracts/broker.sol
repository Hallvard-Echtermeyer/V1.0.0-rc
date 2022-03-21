pragma solidity >=0.5.6;

contract Broker {
    // Only contracts in the whitelist can call Broker for cross-chain operations
    mapping(address => int64) whiteList;
    address[] contracts;
    address[] admins;

    event throwEvent(
        uint64 index,
        address to,
        address fid,
        string tid,
        string func,
        string args,
        string callback
    );
    event LogInterchainData(bool status, string data);
    event LogInterchainStatus(bool status);

    address[] outChains;
    address[] inChains;
    address[] callbackChains;

    //Self implemented event for seeing what functions get called
    event Logger(string message);

    mapping(address => uint64) outCounter; // mapping from contract address to out event last index
    mapping(address => mapping(uint64 => uint256)) outMessages;
    mapping(address => uint64) inCounter;
    mapping(address => mapping(uint64 => uint256)) inMessages;
    mapping(address => uint64) callbackCounter;

    // Permission control, business contracts need to be registered
    modifier onlyWhiteList() {
        emit Logger("something happened WhiteList");
        require(whiteList[msg.sender] == 1, "Invoker are not in white list");
        _;
    }

    // Permission control, only the administrator specified during the contract deployment can review the business contract
    modifier onlyAdmin() {
        emit Logger("something happened onlyAdmin");
        bool flag = false;
        for (uint256 i = 0; i < admins.length; i++) {
            if (msg.sender == admins[i]) {
                flag = true;
            }
        }
        if (flag) {
            revert();
        }
        _;
    }

    function initialize() public {
        emit Logger("something happened initialize");

        for (uint256 i = 0; i < inChains.length; i++) {
            inCounter[inChains[i]] = 0;
        }
        for (uint256 i = 0; i < outChains.length; i++) {
            outCounter[outChains[i]] = 0;
        }
        for (uint256 i = 0; i < callbackChains.length; i++) {
            callbackCounter[callbackChains[i]] = 0;
        }
        for (uint256 i = 0; i < contracts.length; i++) {
            whiteList[contracts[i]] = 0;
        }
        outChains.length = 0;
        inChains.length = 0;
        callbackChains.length = 0;
    }

    // 0 indicates that it is under review, 1 indicates that the review is passed, and -1 indicates that registration is rejected
    function register(address addr) public {
        emit Logger("something happened register");

        whiteList[addr] = 1;
    }

    function audit(address addr, int64 status) public returns (bool) {
        emit Logger("something happened audit");
        if (status != -1 && status != 0 && status != 1) {
            return false;
        }
        whiteList[addr] = status;
        // Only the approved contracts are recorded
        if (status == 1) {
            contracts.push(addr);
        }
        return true;
    }

    function InterchainTransferInvoke(
        address destChainID,
        string memory destAddr,
        string memory args
    ) public onlyWhiteList returns (bool) {
        emit Logger("something happened InterchainTransferInvoke");
        // initiate a cross-chain request
        return
            invokeInterchain(
                destChainID,
                msg.sender,
                destAddr,
                "interchainCharge",
                args,
                "interchainConfirm"
            );
    }

    function InterchainDataSwapInvoke(
        address destChainID,
        string memory destAddr,
        string memory key
    ) public onlyWhiteList returns (bool) {
        emit Logger("something happened InterchainDataSwapInvoke");
        return
            invokeInterchain(
                destChainID,
                msg.sender,
                destAddr,
                "interchainGet",
                key,
                "interchainSet"
            );
    }

    function invokeInterchain(
        address destChainID,
        address sourceAddr,
        string memory destAddr,
        string memory func,
        string memory args,
        string memory callback
    ) internal returns (bool) {
        emit Logger("something happened invokeInterchain");
        // Record the serial number information of the cross-chain contracts that have been carried out by each contract
        outCounter[destChainID]++;
        if (outCounter[destChainID] == 1) {
            outChains.push(destChainID);
        }

        outMessages[destChainID][outCounter[destChainID]] = block.number;

        // Throw cross-chain events for Plugin to monitor
        emit throwEvent(
            outCounter[destChainID],
            destChainID,
            sourceAddr,
            destAddr,
            func,
            args,
            callback
        );
        return true;
    }

    function interchainGet(
        address sourceChainID,
        uint64 index,
        address destAddr,
        string memory key
    ) public returns (bool, string memory) {
        emit Logger("something happened interchainGet");
        BrokerDataSwapper dataGetter = BrokerDataSwapper(destAddr);
        markInCounter(sourceChainID);
        if (whiteList[destAddr] != 1) {
            return (false, "");
        }
        string memory data;
        bool status;
        (status, data) = dataGetter.interchainGet(key);
        emit LogInterchainData(status, data);
        return (status, data);
    }

    function interchainSet(
        address sourceChainID,
        uint64 index,
        address destAddr,
        string memory key,
        string memory value
    ) public returns (bool) {
        emit Logger("something happened interchainSet");
        if (callbackCounter[sourceChainID] + 1 != index) {
            emit LogInterchainStatus(false);
            return false;
        }
        BrokerDataSwapper dataSetter = BrokerDataSwapper(destAddr);
        markCallbackCounter(sourceChainID, index);
        dataSetter.interchainSet(key, value);
        emit LogInterchainStatus(true);
        return true;
    }

    function interchainCharge(
        address sourceChainID,
        uint64 index,
        address destAddr,
        string memory sender,
        string memory receiver,
        uint64 amount
    ) public returns (bool) {
        emit Logger("something happened interchainCharge");
        // Check if the serial number is correct to prevent replay attack
        if (inCounter[sourceChainID] + 1 != index) {
            emit LogInterchainStatus(false);
            return false;
        }

        markInCounter(sourceChainID);
        if (whiteList[destAddr] != 1) {
            emit LogInterchainStatus(false);
            return false;
        }

        BrokerTransfer exchanger = BrokerTransfer(destAddr);
        bool status = exchanger.interchainCharge(sender, receiver, amount);
        emit LogInterchainStatus(status);
        return status;
    }

    function interchainConfirm(
        address sourceChainID,
        uint64 index,
        address destAddr,
        bool status,
        string memory sender,
        uint64 amount
    ) public returns (bool) {
        emit Logger("something happened interchainConfirm");
        if (callbackCounter[sourceChainID] + 1 != index) {
            emit LogInterchainStatus(false);
            return false;
        }

        markCallbackCounter(sourceChainID, index);
        if (whiteList[destAddr] != 1) {
            emit LogInterchainStatus(false);
            return false;
        }
        // if status is ok, no need to rollback
        if (status) {
            emit LogInterchainStatus(true);
            return true;
        }

        BrokerTransfer exchanger = BrokerTransfer(destAddr);
        bool status = exchanger.interchainRollback(sender, amount);
        emit LogInterchainStatus(status);
        return status;
    }

    // Helper function to help record Meta information
    function markCallbackCounter(address from, uint64 index) private {
        emit Logger("something happened markCallbackCounter");
        if (callbackCounter[from] == 0) {
            callbackChains.push(from);
        }
        callbackCounter[from] = index;
        inMessages[from][callbackCounter[from]] = block.number;
    }

    function markInCounter(address from) private {
        emit Logger("something happened markInCounter");
        inCounter[from]++;
        if (inCounter[from] == 1) {
            inChains.push(from);
        }

        inMessages[from][inCounter[from]] = block.number;
    }

    // Provide auxiliary functions for Plugin to query
    function getOuterMeta()
        public
        view
        returns (address[] memory, uint64[] memory)
    {
        uint64[] memory indices = new uint64[](outChains.length);
        for (uint64 i = 0; i < outChains.length; i++) {
            indices[i] = outCounter[outChains[i]];
        }

        return (outChains, indices);
    }

    function getOutMessage(address to, uint64 idx)
        public
        view
        returns (uint256)
    {
        return outMessages[to][idx];
    }

    function getInMessage(address from, uint64 idx)
        public
        view
        returns (uint256)
    {
        return inMessages[from][idx];
    }

    function getInnerMeta()
        public
        view
        returns (address[] memory, uint64[] memory)
    {
        uint64[] memory indices = new uint64[](inChains.length);
        for (uint256 i = 0; i < inChains.length; i++) {
            indices[i] = inCounter[inChains[i]];
        }

        return (inChains, indices);
    }

    function getCallbackMeta()
        public
        view
        returns (address[] memory, uint64[] memory)
    {
        uint64[] memory indices = new uint64[](callbackChains.length);
        for (uint64 i = 0; i < callbackChains.length; i++) {
            indices[i] = callbackCounter[callbackChains[i]];
        }

        return (callbackChains, indices);
    }

    // some string utils
    function toString(uint256 _base) internal pure returns (string memory) {
        bytes memory _tmp = new bytes(32);
        uint256 i;
        for (i = 0; _base > 0; i++) {
            _tmp[i] = bytes1(uint8((_base % 10) + 48));
            _base /= 10;
        }
        bytes memory _real = new bytes(i--);
        for (uint256 j = 0; j < _real.length; j++) {
            _real[j] = _tmp[i--];
        }
        return string(_real);
    }

    function split(string memory _base, string memory _delimiter)
        internal
        pure
        returns (string[] memory splitArr)
    {
        bytes memory _baseBytes = bytes(_base);

        uint256 _offset = 0;
        uint256 _splitsCount = 1;
        while (_offset < _baseBytes.length - 1) {
            int256 _limit = _indexOf(_base, _delimiter, _offset);
            if (_limit == -1) break;
            else {
                _splitsCount++;
                _offset = uint256(_limit) + 1;
            }
        }

        splitArr = new string[](_splitsCount);

        _offset = 0;
        _splitsCount = 0;
        while (_offset < _baseBytes.length - 1) {
            int256 _limit = _indexOf(_base, _delimiter, _offset);
            if (_limit == -1) {
                _limit = int256(_baseBytes.length);
            }

            string memory _tmp = new string(uint256(_limit) - _offset);
            bytes memory _tmpBytes = bytes(_tmp);

            uint256 j = 0;
            for (uint256 i = _offset; i < uint256(_limit); i++) {
                _tmpBytes[j++] = _baseBytes[i];
            }
            _offset = uint256(_limit) + 1;
            splitArr[_splitsCount++] = string(_tmpBytes);
        }
        return splitArr;
    }

    function _indexOf(
        string memory _base,
        string memory _value,
        uint256 _offset
    ) internal pure returns (int256) {
        bytes memory _baseBytes = bytes(_base);
        bytes memory _valueBytes = bytes(_value);

        assert(_valueBytes.length == 1);

        for (uint256 i = _offset; i < _baseBytes.length; i++) {
            if (_baseBytes[i] == _valueBytes[0]) {
                return int256(i);
            }
        }

        return -1;
    }
}

contract BrokerTransfer {
    function interchainRollback(string memory sender, uint64 val)
        public
        returns (bool);

    function interchainCharge(
        string memory sender,
        string memory receiver,
        uint64 val
    ) public returns (bool);
}

contract BrokerDataSwapper {
    function interchainGet(string memory key)
        public
        view
        returns (bool, string memory);

    function interchainSet(string memory key, string memory value) public;
}
