// SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

import {DSTestFull} from 'test/utils/DSTestFull.sol';
import {ContractRegistry} from 'contracts/ContractRegistry.sol';

abstract contract Base is DSTestFull {
    ContractRegistry internal _registry;
    address internal _attestor1 = _label('attestor1');
    address internal _attestor2 = _label('attestor2');
    address internal _attestor3 = _label('attestor3');
    address internal _contractAddress = _label('contractAddress');
    string internal _website = 'example.com';
    uint256 internal _networkId = 1;
    string internal _displayName = 'Example Contract';

    function setUp() public virtual {
        _registry = new ContractRegistry(2);
    }
}

contract UnitContractRegistryConstructor is Base {
    function test_RequiredAttestationsSet(uint8 _requiredAttestations) public {
        vm.assume(_requiredAttestations > 0);
        _registry = new ContractRegistry(_requiredAttestations);

        assertEq(_registry.requiredAttestations(), _requiredAttestations);
    }

    function test_RevertIfRequiredAttestationsIsZero() public {
        vm.expectRevert(ContractRegistry.ZeroAmount.selector);
        new ContractRegistry(0);
    }
}

contract UnitContractRegistryAddAttestation is Base {
    event AttestationAdded(
        string indexed website,
        uint256 indexed networkId,
        address indexed attestor,
        address contractAddress
    );

    function setUp() public override {
        super.setUp();
        vm.startPrank(_attestor1);
    }

    function test_RevertIfInvalidInput() public {
        vm.expectRevert(ContractRegistry.InvalidInput.selector);
        _registry.addAttestation(
            '',
            _contractAddress,
            _networkId,
            _displayName
        );

        vm.expectRevert(ContractRegistry.InvalidInput.selector);
        _registry.addAttestation(
            _website,
            address(0),
            _networkId,
            _displayName
        );

        vm.expectRevert(ContractRegistry.InvalidInput.selector);
        _registry.addAttestation(_website, _contractAddress, _networkId, '');
    }

    function test_RevertIfSenderHasAlreadyAttested() public {
        _registry.addAttestation(
            _website,
            _contractAddress,
            _networkId,
            _displayName
        );

        vm.expectRevert(ContractRegistry.SenderHasAlreadyAttested.selector);
        _registry.addAttestation(
            _website,
            _contractAddress,
            _networkId,
            _displayName
        );
    }

    function test_AddAttestation() public {
        _registry.addAttestation(
            _website,
            _contractAddress,
            _networkId,
            _displayName
        );

        assertEq(
            _registry.getAttestationStatus(
                _website,
                _networkId,
                _contractAddress,
                _attestor1
            ),
            true
        );
    }

    function test_EmitEvent() public {
        _expectEmitNoIndex();
        emit AttestationAdded(
            _website,
            _networkId,
            _attestor1,
            _contractAddress
        );

        _registry.addAttestation(
            _website,
            _contractAddress,
            _networkId,
            _displayName
        );
    }
}

contract UnitContractRegistryRemoveAttestation is Base {
    event AttestationRemoved(
        string indexed website,
        uint256 indexed networkId,
        address indexed attestor,
        address contractAddress
    );

    function setUp() public override {
        super.setUp();
        vm.prank(_attestor1);
        _registry.addAttestation(
            _website,
            _contractAddress,
            _networkId,
            _displayName
        );
    }

    function test_RevertIfSenderHasNotAttested() public {
        vm.prank(_attestor2);
        vm.expectRevert(ContractRegistry.SenderHasNotAttested.selector);
        _registry.removeAttestation(_website, _networkId, _contractAddress);
    }

    function test_RemoveAttestation() public {
        vm.prank(_attestor1);
        _registry.removeAttestation(_website, _networkId, _contractAddress);
        assertEq(
            _registry.getAttestationStatus(
                _website,
                _networkId,
                _contractAddress,
                _attestor1
            ),
            false
        );
    }

    function test_EmitEvent() public {
        _expectEmitNoIndex();
        emit AttestationRemoved(
            _website,
            _networkId,
            _attestor1,
            _contractAddress
        );

        vm.prank(_attestor1);
        _registry.removeAttestation(_website, _networkId, _contractAddress);
    }
}

contract UnitContractRegistryGetAttestationStatus is Base {
    function setUp() public override {
        super.setUp();
        vm.prank(_attestor1);
        _registry.addAttestation(
            _website,
            _contractAddress,
            _networkId,
            _displayName
        );
    }

    function test_GetAttestationStatus() public {
        bool status = _registry.getAttestationStatus(
            _website,
            _networkId,
            _contractAddress,
            _attestor1
        );
        assertEq(status, true);
    }
}

contract UnitContractRegistryGetContractInfo is Base {
    function setUp() public override {
        super.setUp();
        vm.prank(_attestor1);
        _registry.addAttestation(
            _website,
            _contractAddress,
            _networkId,
            _displayName
        );
    }

    function test_GetContractInfo() public {
        (
            uint256 attestorCount,
            address[] memory attestorList,
            string memory displayName
        ) = _registry.getContractInfo(_website, _networkId, _contractAddress);

        assertEq(attestorCount, 1);
        assertEq(attestorList.length, 1);
        assertEq(displayName, _displayName);
    }
}
