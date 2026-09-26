// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "remix_tests.sol";
import "../Contracts/CandidateManager.sol";

contract CandidateManagerTest {
    CandidateManager candidateManager;

    function beforeEach() public {
        candidateManager = new CandidateManager();
    }

    function testAddAndGetCandidate() public {
        candidateManager.addCandidate("Obama", "Dang Dan Chu", "Good");
        candidateManager.addCandidate("Trump", "Dang Cong Hoa", "Rich");
        
        Assert.equal(candidateManager.getValidCandidatesCount(), uint(2), "Valid count must be 2");

        CandidateManager.Candidate memory c = candidateManager.getCandidate(0);
        Assert.equal(c.name, "Obama", "Candidate name must match");
        
        // Sửa isDeleted thành isActive và kiểm tra true (vì mới thêm chưa bị xóa)
        Assert.equal(c.isActive, true, "Candidate should be active");
    }

    function testUpdateCandidate() public {
        candidateManager.addCandidate("Obama", "Dang Dan Chu", "Good");
        candidateManager.updateCandidate(0, "Obama New", "Dang Dan Chu", "Updated");
        
        CandidateManager.Candidate memory c = candidateManager.getCandidate(0);
        Assert.equal(c.name, "Obama New", "Candidate name should be updated");
    }

    function testDeleteAndLockCandidates() public {
        candidateManager.addCandidate("Obama", "Dang Dan Chu", "Good");
        candidateManager.addCandidate("Trump", "Dang Cong Hoa", "Rich");

        // Xóa mềm ứng viên số 1 trước khi khóa
        candidateManager.deleteCandidate(1);
        Assert.equal(candidateManager.getValidCandidatesCount(), uint(1), "Valid count must be 1 after delete");

        // Kiểm tra xem ứng viên số 1 đã chuyển thành isActive = false chưa
        CandidateManager.Candidate memory c1 = candidateManager.getCandidate(1);
        Assert.equal(c1.isActive, false, "Candidate 1 should be inactive after delete");

        // Khóa danh sách
        candidateManager.lockCandidates();
        Assert.equal(candidateManager.candidatesLocked(), true, "Candidates must be locked");
    }
}