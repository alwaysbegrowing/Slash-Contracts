// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4 <0.9.0;

import {Script} from 'forge-std/Script.sol';
import {ContractRegistry} from 'contracts/ContractRegistry.sol';

contract Populate is Script {
  function run() external {
    vm.startBroadcast();
    ContractRegistry registry = ContractRegistry(0xB0779231B0FDA405680e889D13814488720b9adD);
    // Gnosis EasyAuction
    // [1]: 0x0b7fFc1f4AD541A4Ed16b40D8c37f0929158D101
    // [5]: 0x1fBAb40C338E2e7243DA945820Ba680C92EF8281
    // BondFactory
    // [1]: 0x1533Eb8c6cc510863b496D182596AB0e9E77A00c
    // [5]: 0xBE9A5b24dbEB65b21Fc91BD825257f5c4FE9c01D
    // BondImplementation
    // [1]: 0x6285D6b0Ccac4ecaF4f7a2738fEc03330809B162
    // [5]: 0xF457Fcb60F761c98b23b4edDe638E99711476FF7
    registry.addAttestation('https://app.arbor.finance', 0x0b7fFc1f4AD541A4Ed16b40D8c37f0929158D101, 1, 'Gnosis EasyAuction');
    registry.addAttestation('https://app.arbor.finance', 0x1fBAb40C338E2e7243DA945820Ba680C92EF8281, 5, 'Gnosis EasyAuction');
    registry.addAttestation('https://app.arbor.finance', 0x1533Eb8c6cc510863b496D182596AB0e9E77A00c, 1, 'BondFactory');
    registry.addAttestation('https://app.arbor.finance', 0xBE9A5b24dbEB65b21Fc91BD825257f5c4FE9c01D, 5, 'BondFactory');
    registry.addAttestation('https://app.arbor.finance', 0x6285D6b0Ccac4ecaF4f7a2738fEc03330809B162, 1, 'BondImplementation');
    registry.addAttestation('https://app.arbor.finance', 0xF457Fcb60F761c98b23b4edDe638E99711476FF7, 5, 'BondImplementation');
    vm.stopBroadcast();
  }
}
