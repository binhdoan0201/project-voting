// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "remix_tests.sol";
import "remix_accounts.sol";
import "../Contracts/ElectionScheduler.sol";
import "../Contracts/VoterRegistry.sol";

contract VoterRegistryTest {
    ElectionScheduler scheduler;
    VoterRegistry voterRegistry;
    address voter1;
    address voter2;

    function beforeEach() public {
        voter1 = TestsAccounts.getAccount(1);
        voter2 = TestsAccounts.getAccount(2);

        scheduler = new ElectionScheduler();
        voterRegistry = new VoterRegistry(address(scheduler));
    }

    function testBatchRegisterVoters() public {
        address[] memory voters = new address[](2);
        voters[0] = voter1;
        voters[1] = voter2;

        voterRegistry.batchRegisterVoters(voters);
        Assert.equal(voterRegistry.totalVoters(), uint(2), "Total voters must be 2");
        Assert.equal(voterRegistry.isRegistered(voter1), true, "Voter 1 must be registered");
        Assert.equal(voterRegistry.isRegistered(voter2), true, "Voter 2 must be registered");
    }
}