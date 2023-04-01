// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4 <0.9.0;

import {Script} from 'forge-std/Script.sol';
import {ContractRegistry} from 'contracts/ContractRegistry.sol';

abstract contract Deploy is Script {
  function _deploy(uint8 numberOfAttestations) internal {
    vm.startBroadcast();
    new ContractRegistry(numberOfAttestations);
    vm.stopBroadcast();
  }
}

contract DeployMainnet is Deploy {
  function run() external {
    _deploy(3);
  }
}

contract DeployGoerli is Deploy {
  function run() external {
    _deploy(1);
  }
}
