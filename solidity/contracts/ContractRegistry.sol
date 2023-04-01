// SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

contract ContractRegistry {
    struct ContractInfo {
        mapping(address => bool) attestorMap;
        address[] attestorList;
        uint256 attestorCount;
        address contractAddress;
        string displayName;
    }

    struct NetworkInfo {
        mapping(address => ContractInfo) contracts;
        address[] contractList;
    }

    struct AttestorInfo {
        address attestor;
        bool isAttested;
    }

    struct ContractData {
        string displayName;
        address[] attestorList;
        uint256 attestorCount;
        address contractAddress;
    }

    error ZeroAmount();
    error SenderHasAlreadyAttested();
    error SenderHasNotAttested();
    error InvalidInput();
    error DuplicateContract();

    mapping(string => mapping(uint256 => NetworkInfo)) private _registry;

    uint8 public requiredAttestations;

    event AttestationAdded(
        string indexed website,
        uint256 indexed networkId,
        address indexed attestor,
        address contractAddress
    );
    event AttestationRemoved(
        string indexed website,
        uint256 indexed networkId,
        address indexed attestor,
        address contractAddress
    );

    constructor(uint8 _requiredAttestations) {
        if (_requiredAttestations == 0) {
            revert ZeroAmount();
        }

        requiredAttestations = _requiredAttestations;
    }

    function addAttestation(
        string memory website,
        address contractAddress,
        uint256 networkId,
        string memory displayName
    ) public {
        if (
            bytes(website).length == 0 ||
            contractAddress == address(0) ||
            bytes(displayName).length == 0
        ) {
            revert InvalidInput();
        }

        ContractInfo storage info = _registry[website][networkId].contracts[
            contractAddress
        ];

        if (info.attestorMap[msg.sender]) {
            revert SenderHasAlreadyAttested();
        }

        if (info.attestorCount == 0) {
            _registry[website][networkId].contractList.push(contractAddress);
            info.displayName = displayName;
        }

        info.attestorMap[msg.sender] = true;
        info.attestorList.push(msg.sender);
        info.attestorCount++;

        if (info.attestorCount >= requiredAttestations) {
            info.contractAddress = contractAddress;
        }

        emit AttestationAdded(website, networkId, msg.sender, contractAddress);
    }

    function removeAttestation(
        string memory website,
        uint256 networkId,
        address contractAddress
    ) public {
        ContractInfo storage info = _registry[website][networkId].contracts[
            contractAddress
        ];

        if (!info.attestorMap[msg.sender]) {
            revert SenderHasNotAttested();
        }

        info.attestorMap[msg.sender] = false;
        info.attestorCount--;

        for (uint256 i = 0; i < info.attestorList.length; i++) {
            if (info.attestorList[i] == msg.sender) {
                info.attestorList[i] = info.attestorList[
                    info.attestorList.length - 1
                ];
                info.attestorList.pop();
                break;
            }
        }

        emit AttestationRemoved(
            website,
            networkId,
            msg.sender,
            contractAddress
        );
    }

    function getAttestationStatus(
        string memory website,
        uint256 networkId,
        address contractAddress,
        address attestor
    ) public view returns (bool) {
        ContractInfo storage info = _registry[website][networkId].contracts[
            contractAddress
        ];
        return info.attestorMap[attestor];
    }

    function getContractsByNetwork(
        string memory website,
        uint256 networkId
    ) public view returns (ContractData[] memory) {
        NetworkInfo storage networkInfo = _registry[website][networkId];
        uint256 contractCount = networkInfo.contractList.length;
        ContractData[] memory contractDatas = new ContractData[](contractCount);

        for (uint256 i = 0; i < contractCount; i++) {
            address contractAddress = networkInfo.contractList[i];
            ContractInfo storage contractInfo = _registry[website][networkId]
                .contracts[contractAddress];
            contractDatas[i] = ContractData({
                contractAddress: contractAddress,
                displayName: contractInfo.displayName,
                attestorList: contractInfo.attestorList,
                attestorCount: contractInfo.attestorCount
            });
        }

        return contractDatas;
    }

    function getAttestors(
        string memory website,
        uint256 networkId,
        address contractAddress
    ) public view returns (address[] memory) {
        ContractInfo storage contractInfo = _registry[website][networkId]
            .contracts[contractAddress];
        return contractInfo.attestorList;
    }

    // Add this function to access _registry
    function getContractInfo(
        string memory website,
        uint256 networkId,
        address contractAddress
    )
        public
        view
        returns (
            uint256 attestorCount,
            address[] memory attestorList,
            string memory displayName
        )
    {
        ContractInfo storage info = _registry[website][networkId].contracts[
            contractAddress
        ];
        return (info.attestorCount, info.attestorList, info.displayName);
    }
}
