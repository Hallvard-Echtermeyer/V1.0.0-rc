pragma solidity >=0.5.6;

contract Transfer {
    mapping(string => uint64) accountM; // map for accounts

    address BrokerAddr = 0xD0E1B0d7D04CA60F11Ab3C58b7782B2379fa9090;
    TransferBroker broker = TransferBroker(BrokerAddr);

    // AccessControl
    modifier onlyBroker() {
        require(msg.sender == BrokerAddr, "Invoker are not the Broker");
        _;
    }

    // 资产类的业务合约
    function transfer(
        address destChainID,
        string memory destAddr,
        string memory sender,
        string memory receiver,
        string memory amount
    ) public {
        uint64 am = uint64(parseInt(amount));
        accountM[sender] -= am;

        // 拼接参数
        string memory args = concat(toSlice(sender), toSlice(","));
        args = concat(toSlice(args), toSlice(receiver));
        args = concat(toSlice(args), toSlice(","));
        args = concat(toSlice(args), toSlice(amount));

        bool ok = broker.InterchainTransferInvoke(destChainID, destAddr, args);
        require(ok);
    }

    function interchainRollback(string memory sender, uint64 val)
        public
        onlyBroker
        returns (bool)
    {
        accountM[sender] += val;
        return true;
    }

    function interchainCharge(
        string memory sender,
        string memory receiver,
        uint64 val
    ) public onlyBroker returns (bool) {
        accountM[receiver] += val;
        return true;
    }

    function getBalance(string memory id) public view returns (uint64) {
        return accountM[id];
    }

    function setBalance(string memory id, uint64 amount) public {
        accountM[id] = amount;
    }

    function parseInt(string memory self) internal pure returns (uint256 _ret) {
        bytes memory _bytesValue = bytes(self);
        uint256 j = 1;
        for (
            uint256 i = _bytesValue.length - 1;
            i >= 0 && i < _bytesValue.length;
            i--
        ) {
            assert(uint8(_bytesValue[i]) >= 48 && uint8(_bytesValue[i]) <= 57);
            _ret += (uint8(_bytesValue[i]) - 48) * j;
            j *= 10;
        }
    }

    struct slice {
        uint256 _len;
        uint256 _ptr;
    }

    function toSlice(string memory self) internal pure returns (slice memory) {
        uint256 ptr;
        assembly {
            ptr := add(self, 0x20)
        }
        return slice(bytes(self).length, ptr);
    }

    function concat(slice memory self, slice memory other)
        internal
        pure
        returns (string memory)
    {
        string memory ret = new string(self._len + other._len);
        uint256 retptr;
        assembly {
            retptr := add(ret, 32)
        }
        memcpy(retptr, self._ptr, self._len);
        memcpy(retptr + self._len, other._ptr, other._len);
        return ret;
    }

    function memcpy(
        uint256 dest,
        uint256 src,
        uint256 len
    ) private pure {
        // Copy word-length chunks while possible
        for (; len >= 32; len -= 32) {
            assembly {
                mstore(dest, mload(src))
            }
            dest += 32;
            src += 32;
        }

        // Copy remaining bytes
        uint256 mask = 256**(32 - len) - 1;
        assembly {
            let srcpart := and(mload(src), not(mask))
            let destpart := and(mload(dest), mask)
            mstore(dest, or(destpart, srcpart))
        }
    }
}

contract TransferBroker {
    function InterchainTransferInvoke(
        address destChainID,
        string memory destAddr,
        string memory args
    ) public returns (bool);
}
