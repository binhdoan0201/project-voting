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

    function beforeEach() public {
        manager = new CandidateManager();

        scheduler = new ElectionScheduler();

        registry = new VoterRegistry(
            address(scheduler)
        );

        core = new VotingCore(
            address(manager),
            address(scheduler)
        );

        manager.setVotingCore(
            address(core)
        );
    }

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

    // 2. Khóa ứng viên và bắt đầu bầu cử
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

    // 3. Bỏ phiếu trong thời gian bầu cử
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

    // 4. Không được bỏ phiếu hai lần
    function testCannotVoteTwice() public {
        manager.addCandidate(
            "Nguyen Van A",
            "Dang A",
            "Ung vien A"
        );

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

    // 5. Không được bỏ phiếu trước khi bắt đầu
    function testCannotVoteBeforeElection() public {
        manager.addCandidate(
            "Nguyen Van A",
            "Dang A",
            "Ung vien A"
        );

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

    // 6. Không được vote ứng viên không tồn tại
    function testCannotVoteInvalidCandidate() public {
        manager.addCandidate(
            "Nguyen Van A",
            "Dang A",
            "Ung vien A"
        );

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

    // 7. Bỏ phiếu cho nhiều ứng viên bằng nhiều địa chỉ
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

        manager.lockCandidates();

        scheduler.startElection();

        // core.vote() luôn nhận msg.sender là test contract.
        // Vì vậy test này kiểm tra kết quả của một voter.
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
    }

    // 8. Kết thúc cuộc bầu cử
    function testEndElection() public {
        manager.addCandidate(
            "Nguyen Van A",
            "Dang A",
            "Ung vien A"
        );

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
    }

    // 9. Không được vote sau khi kết thúc
    function testCannotVoteAfterElectionEnded() public {
        manager.addCandidate(
            "Nguyen Van A",
            "Dang A",
            "Ung vien A"
        );

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

    // 10. Kiểm tra kết quả cuối cùng
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

        scheduler.endElection();

        Assert.equal(
            uint(scheduler.currentState()),
            uint(ElectionScheduler.ElectionState.Ended),
            "Trang thai cuoi phai la Ended"
        );
    }
}