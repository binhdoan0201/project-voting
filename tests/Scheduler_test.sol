// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "remix_tests.sol";
import "../Contracts/ElectionScheduler.sol";

contract SchedulerTest {
    ElectionScheduler scheduler;

    function beforeEach() public {
        scheduler = new ElectionScheduler();
    }

    function testInitialState() public {
        Assert.equal(scheduler.isElectionActive(), false, "Initial state should be inactive");
    }

    function testStartAndEndElection() public {
        scheduler.startElection();
        Assert.equal(scheduler.isElectionActive(), true, "State should be active after start");
        
        scheduler.endElection();
        Assert.equal(scheduler.isElectionActive(), false, "State should be inactive after end");
    }
}