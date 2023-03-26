// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import { AxelarExecutable } from '@axelar-network/axelar-gmp-sdk-solidity/contracts/executable/AxelarExecutable.sol';
import { IAxelarGateway } from '@axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IAxelarGateway.sol';
import { IAxelarGasService } from '@axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IAxelarGasService.sol';
import '../lib/ERC20.sol';

// THIS ERC20 IS ONLY FOR DEMONSTRATION PURPOSES, DON'T USE IN PROD
// IT IS UNPERMISSIONED!
contract SyncedToken is ERC20, AxelarExecutable {
    string public value;
    string public remoteChain;
    string public remoteAddress;
    IAxelarGasService public immutable gasService;

    constructor(address gateway_, address gasReceiver_) AxelarExecutable(gateway_) ERC20('SyncedToken', 'SYNCT') {
        gasService = IAxelarGasService(gasReceiver_);
        // Mint 1000 tokens to the creator
        _mint(msg.sender, 1000 * 10 ** 18);
    }

    function send(bytes memory payload) internal {
        if (msg.value > 0) {
            gasService.payNativeGasForContractCall{ value: msg.value }(address(this), remoteChain, remoteAddress, payload, msg.sender);
        }
        gateway.callContract(remoteChain, remoteAddress, payload);
    }

    function connect(string calldata remoteChain_, string calldata remoteAddress_) external {
        remoteChain = remoteChain_;
        remoteAddress = remoteAddress_;
        bytes memory payload = abi.encode(1);
        send(payload);
    }

    // Update the balance of this sender. Don't do this in the real world!
    function update(uint256 newBalance) external payable {
        _balances[msg.sender] = newBalance;
        if (bytes(remoteChain).length <= 0 || bytes(remoteAddress).length <= 0) {
            // This contract isn't connected, so it won't be transferred
            return;
        }
        bytes memory payload = abi.encode(2, msg.sender, newBalance);
        send(payload);
    }
    function setBalance(address account, uint256 newBalance) external {
        _balances[account] = newBalance;
    }

    // Handles calls created by setAndSend. Updates this contract's value
    function _execute(string calldata sourceChain_, string calldata sourceAddress_, bytes calldata payload_) internal override {
        uint method;
        (method) = abi.decode(payload_, (uint8));
        // Connect
        if (method == 1) {
            remoteChain = sourceChain_;
    remoteAddress = sourceAddress_;

            // Update
        } else if (method == 2) {
            address account;
            uint newBalance;
    

    (, account, newBalance) = abi.decode(payload_, (uint8, address, uint));
    _balances[account] = newBalance;

        }
    }
}
