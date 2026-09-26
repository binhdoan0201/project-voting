// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "remix_tests.sol";
import "../Contracts/CandidateManager.sol";
import "../Contracts/ElectionScheduler.sol";
import "../Contracts/VotingCore.sol";

contract VotingCoreTest {
    ElectionScheduler scheduler;
    CandidateManager candidateManager;
    VotingCore votingCore;

    function beforeEach() public {
        scheduler = new ElectionScheduler();
        candidateManager = new CandidateManager();
        votingCore = new VotingCore(address(candidateManager), address(scheduler));
        
        candidateManager.setVotingCore(address(votingCore));
    }

    function testCompleteElectionWorkflow() public {
        // Thêm ứng viên và khóa
        candidateManager.addCandidate("Obama", "Dang Dan Chu", "Good");
        candidateManager.addCandidate("Trump", "Dang Cong Hoa", "Rich");
        candidateManager.lockCandidates();

        // Mở bầu cử
        scheduler.startElection();

        // Bỏ phiếu
        votingCore.vote(0);
        Assert.equal(votingCore.totalVotesCast(), uint256(1), "Total votes cast must be 1");

        // Kết thúc và kiểm tra phiếu
        scheduler.endElection();
        
        CandidateManager.Candidate memory obama = candidateManager.getCandidate(0);
        CandidateManager.Candidate memory trump = candidateManager.getCandidate(1);

        Assert.equal(obama.voteCount, uint(1), "Obama vote count must be 1");
        Assert.equal(trump.voteCount, uint(0), "Trump vote count must be 0");
    }
}