// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "remix_tests.sol";
import "remix_accounts.sol";

import "../contracts/CandidateManager.sol";
import "../contracts/ElectionScheduler.sol";
import "../contracts/VoterRegistry.sol";
import "../contracts/VotingCore.sol";

contract VotingCoreTest {

    CandidateManager manager;
    ElectionScheduler scheduler;
    VoterRegistry registry;
    VotingCore core;

    // ==========================================
    // 1. Setup
    // ==========================================

    function beforeEach() public {
        manager = new CandidateManager();

        scheduler = new ElectionScheduler();

        registry = new VoterRegistry(
            address(scheduler)
        );

        core = new VotingCore(
            address(manager),
            address(scheduler),
            address(registry)
        );

        manager.setVotingCore(
            address(core)
        );
    }

    // ==========================================
    // 2. Test chuẩn bị cuộc bầu cử
    // ==========================================

    // 1. Chuẩn bị cuộc bầu cử
    function testPrepareElection() public {
        manager.addCandidate(
            "Nguyen Van A",
            "Dang A",
            "Ung vien A"
        );

        manager.addCandidate(
            "Nguyen Van B",
            "Dang B",
            "Ung vien B"
        );

        registry.registerVoter(
            TestsAccounts.getAccount(1)
        );

        registry.registerVoter(
            TestsAccounts.getAccount(2)
        );

        Assert.equal(
            manager.getValidCandidatesCount(),
            uint(2),
            "Phai co 2 ung vien"
        );

        Assert.equal(
            registry.totalVoters(),
            uint(2),
            "Phai co 2 voter"
        );
    }

    // ==========================================
    // 3. Test khoa ung vien va bat dau bau cu
    // ==========================================

    // 2. Khoa ung vien va bat dau bau cu
    function testLockAndStartElection() public {
        manager.addCandidate(
            "Nguyen Van A",
            "Dang A",
            "Ung vien A"
        );

        manager.addCandidate(
            "Nguyen Van B",
            "Dang B",
            "Ung vien B"
        );

        manager.lockCandidates();

        Assert.equal(
            manager.candidatesLocked(),
            true,
            "Danh sach ung vien phai duoc khoa"
        );

        scheduler.startElection();

        Assert.equal(
            scheduler.isElectionActive(),
            true,
            "Cuoc bau cu phai dang dien ra"
        );
    }

    // ==========================================
    // 4. Test bo phieu
    // ==========================================

    // 3. Bo phieu trong thoi gian bau cu
    function testVoteDuringElection() public {
        manager.addCandidate(
            "Nguyen Van A",
            "Dang A",
            "Ung vien A"
        );

        manager.addCandidate(
            "Nguyen Van B",
            "Dang B",
            "Ung vien B"
        );

        // Dang ky test contract lam cu tri
        registry.registerVoter(address(this));

        manager.lockCandidates();

        scheduler.startElection();

        core.vote(0);

        CandidateManager.Candidate memory candidate =
            manager.getCandidate(0);

        Assert.equal(
            candidate.voteCount,
            uint(1),
            "Ung vien phai nhan duoc 1 phieu"
        );

        Assert.equal(
            core.totalVotesCast(),
            uint(1),
            "Tong phieu phai bang 1"
        );

        Assert.equal(
            core.checkHasVoted(address(this)),
            true,
            "Voter phai duoc ghi nhan da vote"
        );
    }

    // 4. Khong duoc bo phieu hai lan
    function testCannotVoteTwice() public {
        manager.addCandidate(
            "Nguyen Van A",
            "Dang A",
            "Ung vien A"
        );

        // Dang ky test contract lam cu tri
        registry.registerVoter(address(this));

        manager.lockCandidates();

        scheduler.startElection();

        core.vote(0);

        (bool success, ) = address(core).call(
            abi.encodeWithSignature(
                "vote(uint256)",
                uint(0)
            )
        );

        Assert.equal(
            success,
            false,
            "Mot dia chi khong duoc vote hai lan"
        );

        Assert.equal(
            core.totalVotesCast(),
            uint(1),
            "Tong phieu van phai bang 1"
        );
    }

    // 5. Khong duoc bo phieu truoc khi bat dau
    function testCannotVoteBeforeElection() public {
        manager.addCandidate(
            "Nguyen Van A",
            "Dang A",
            "Ung vien A"
        );

        // Dang ky test contract lam cu tri
        registry.registerVoter(address(this));

        manager.lockCandidates();

        (bool success, ) = address(core).call(
            abi.encodeWithSignature(
                "vote(uint256)",
                uint(0)
            )
        );

        Assert.equal(
            success,
            false,
            "Khong duoc vote truoc khi bau cu bat dau"
        );

        Assert.equal(
            core.totalVotesCast(),
            uint(0),
            "Chua co phieu nao"
        );
    }

    // 6. Khong duoc vote ung vien khong ton tai
    function testCannotVoteInvalidCandidate() public {
        manager.addCandidate(
            "Nguyen Van A",
            "Dang A",
            "Ung vien A"
        );

        // Dang ky test contract lam cu tri
        registry.registerVoter(address(this));

        manager.lockCandidates();

        scheduler.startElection();

        (bool success, ) = address(core).call(
            abi.encodeWithSignature(
                "vote(uint256)",
                uint(99)
            )
        );

        Assert.equal(
            success,
            false,
            "Khong duoc vote ung vien khong ton tai"
        );

        Assert.equal(
            core.totalVotesCast(),
            uint(0),
            "Tong phieu phai van bang 0"
        );
    }

    // ==========================================
    // 5. Test bo phieu cho nhieu ung vien
    // ==========================================

    // 7. Bo phieu cho nhieu ung vien
    function testMultipleVotersMultipleCandidates() public {
        manager.addCandidate(
            "Nguyen Van A",
            "Dang A",
            "Ung vien A"
        );

        manager.addCandidate(
            "Nguyen Van B",
            "Dang B",
            "Ung vien B"
        );

        // Dang ky test contract lam cu tri
        registry.registerVoter(address(this));

        manager.lockCandidates();

        scheduler.startElection();

        // core.vote() duoc goi tu test contract
        // nen msg.sender trong VotingCore la address(this)
        core.vote(1);

        CandidateManager.Candidate memory candidateA =
            manager.getCandidate(0);

        CandidateManager.Candidate memory candidateB =
            manager.getCandidate(1);

        Assert.equal(
            candidateA.voteCount,
            uint(0),
            "Candidate A phai co 0 phieu"
        );

        Assert.equal(
            candidateB.voteCount,
            uint(1),
            "Candidate B phai co 1 phieu"
        );

        Assert.equal(
            core.totalVotesCast(),
            uint(1),
            "Tong phieu phai bang 1"
        );
    }

    // ==========================================
    // 6. Test ket thuc bau cu
    // ==========================================

    // 8. Ket thuc cuoc bau cu
    function testEndElection() public {
        manager.addCandidate(
            "Nguyen Van A",
            "Dang A",
            "Ung vien A"
        );

        // Dang ky test contract lam cu tri
        registry.registerVoter(address(this));

        manager.lockCandidates();

        scheduler.startElection();

        core.vote(0);

        scheduler.endElection();

        Assert.equal(
            uint(scheduler.currentState()),
            uint(ElectionScheduler.ElectionState.Ended),
            "Trang thai phai la Ended"
        );

        Assert.equal(
            scheduler.isElectionActive(),
            false,
            "Cuoc bau cu khong con hoat dong"
        );

        Assert.equal(
            core.totalVotesCast(),
            uint(1),
            "Tong phieu phai van bang 1"
        );
    }

    // ==========================================
    // 7. Test khong duoc vote sau khi ket thuc
    // ==========================================

    // 9. Khong duoc vote sau khi ket thuc
    function testCannotVoteAfterElectionEnded() public {
        manager.addCandidate(
            "Nguyen Van A",
            "Dang A",
            "Ung vien A"
        );

        // Dang ky test contract lam cu tri
        registry.registerVoter(address(this));

        manager.lockCandidates();

        scheduler.startElection();

        scheduler.endElection();

        (bool success, ) = address(core).call(
            abi.encodeWithSignature(
                "vote(uint256)",
                uint(0)
            )
        );

        Assert.equal(
            success,
            false,
            "Khong duoc vote sau khi bau cu ket thuc"
        );

        Assert.equal(
            core.totalVotesCast(),
            uint(0),
            "Khong duoc co phieu sau khi ket thuc"
        );
    }

    // ==========================================
    // 8. Test ket qua bau cu
    // ==========================================

    // 10. Kiem tra ket qua cuoi cung
    function testFinalElectionResult() public {
        manager.addCandidate(
            "Nguyen Van A",
            "Dang A",
            "Ung vien A"
        );

        manager.addCandidate(
            "Nguyen Van B",
            "Dang B",
            "Ung vien B"
        );

        // Dang ky test contract lam cu tri
        registry.registerVoter(address(this));

        manager.lockCandidates();

        scheduler.startElection();

        core.vote(0);

        CandidateManager.Candidate memory candidateA =
            manager.getCandidate(0);

        CandidateManager.Candidate memory candidateB =
            manager.getCandidate(1);

        Assert.equal(
            candidateA.voteCount,
            uint(1),
            "Candidate A phai co 1 phieu"
        );

        Assert.equal(
            candidateB.voteCount,
            uint(0),
            "Candidate B phai co 0 phieu"
        );

        Assert.equal(
            core.totalVotesCast(),
            uint(1),
            "Tong phieu phai bang 1"
        );

        Assert.equal(
            core.checkHasVoted(address(this)),
            true,
            "Voter phai duoc ghi nhan da vote"
        );

        scheduler.endElection();

        Assert.equal(
            uint(scheduler.currentState()),
            uint(ElectionScheduler.ElectionState.Ended),
            "Trang thai cuoi phai la Ended"
        );
    }
}