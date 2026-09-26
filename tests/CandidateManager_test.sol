// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "remix_tests.sol";
import "remix_accounts.sol";

import "../contracts/CandidateManager.sol";
import "../contracts/ElectionScheduler.sol";
import "../contracts/VotingCore.sol";

contract CandidateManagerTest {

    CandidateManager manager;

    function beforeEach() public {
        manager = new CandidateManager();
    }

    // 1. Thêm ứng viên
    function testAddCandidates() public {
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

        Assert.equal(
            manager.getValidCandidatesCount(),
            uint(2),
            "Phai co 2 ung vien"
        );

        CandidateManager.Candidate memory c0 =
            manager.getCandidate(0);

        CandidateManager.Candidate memory c1 =
            manager.getCandidate(1);

        Assert.equal(
            c0.name,
            "Nguyen Van A",
            "Sai ten ung vien A"
        );

        Assert.equal(
            c1.name,
            "Nguyen Van B",
            "Sai ten ung vien B"
        );

        Assert.equal(
            c0.voteCount,
            uint(0),
            "Ung vien A phai co 0 phieu"
        );

        Assert.equal(
            c1.voteCount,
            uint(0),
            "Ung vien B phai co 0 phieu"
        );
    }

    // 2. Cập nhật ứng viên trước khi khóa
    function testUpdateCandidateBeforeLock() public {
        manager.addCandidate(
            "Nguyen Van A",
            "Dang A",
            "Mo ta cu"
        );

        manager.updateCandidate(
            0,
            "Nguyen Van A Updated",
            "Dang A Updated",
            "Mo ta moi"
        );

        CandidateManager.Candidate memory c =
            manager.getCandidate(0);

        Assert.equal(
            c.name,
            "Nguyen Van A Updated",
            "Ten chua duoc cap nhat"
        );

        Assert.equal(
            c.party,
            "Dang A Updated",
            "Dang chua duoc cap nhat"
        );

        Assert.equal(
            c.description,
            "Mo ta moi",
            "Mo ta chua duoc cap nhat"
        );
    }

    // 3. Xóa ứng viên trước khi khóa
    function testDeleteCandidateBeforeLock() public {
        manager.addCandidate(
            "Nguyen Van A",
            "Dang A",
            "Mo ta A"
        );

        manager.addCandidate(
            "Nguyen Van B",
            "Dang B",
            "Mo ta B"
        );

        manager.deleteCandidate(0);

        Assert.equal(
            manager.getValidCandidatesCount(),
            uint(1),
            "Phai con 1 ung vien hop le"
        );

        CandidateManager.Candidate memory c =
            manager.getCandidate(0);

        Assert.equal(
            c.isActive,
            false,
            "Ung vien phai duoc vo hieu hoa"
        );
    }

    // 4. Thiết lập VotingCore
    function testSetVotingCore() public {
        ElectionScheduler scheduler =
            new ElectionScheduler();

        VotingCore core = new VotingCore(
            address(manager),
            address(scheduler)
        );

        manager.setVotingCore(address(core));

        Assert.equal(
            manager.votingCoreAddress(),
            address(core),
            "VotingCore chua duoc thiet lap"
        );
    }

    // 5. Khóa danh sách ứng viên
    function testLockCandidates() public {
        manager.addCandidate(
            "Nguyen Van A",
            "Dang A",
            "Mo ta A"
        );

        manager.lockCandidates();

        Assert.equal(
            manager.candidatesLocked(),
            true,
            "Danh sach ung vien phai duoc khoa"
        );
    }

    // 6. Không được thêm ứng viên sau khi khóa
    function testCannotAddAfterLock() public {
        manager.addCandidate(
            "Nguyen Van A",
            "Dang A",
            "Mo ta A"
        );

        manager.lockCandidates();

        (bool success, ) = address(manager).call(
            abi.encodeWithSignature(
                "addCandidate(string,string,string)",
                "Nguyen Van B",
                "Dang B",
                "Mo ta B"
            )
        );

        Assert.equal(
            success,
            false,
            "Khong duoc them ung vien sau khi khoa"
        );
    }

    // 7. Không được sửa ứng viên sau khi khóa
    function testCannotUpdateAfterLock() public {
        manager.addCandidate(
            "Nguyen Van A",
            "Dang A",
            "Mo ta A"
        );

        manager.lockCandidates();

        (bool success, ) = address(manager).call(
            abi.encodeWithSignature(
                "updateCandidate(uint256,string,string,string)",
                uint(0),
                "Ten moi",
                "Dang moi",
                "Mo ta moi"
            )
        );

        Assert.equal(
            success,
            false,
            "Khong duoc sua ung vien sau khi khoa"
        );
    }

    // 8. Không được xóa ứng viên sau khi khóa
    function testCannotDeleteAfterLock() public {
        manager.addCandidate(
            "Nguyen Van A",
            "Dang A",
            "Mo ta A"
        );

        manager.lockCandidates();

        (bool success, ) = address(manager).call(
            abi.encodeWithSignature(
                "deleteCandidate(uint256)",
                uint(0)
            )
        );

        Assert.equal(
            success,
            false,
            "Khong duoc xoa ung vien sau khi khoa"
        );
    }

    // 9. Không thể khóa khi chưa có ứng viên
    function testCannotLockWithoutCandidate() public {
        (bool success, ) = address(manager).call(
            abi.encodeWithSignature("lockCandidates()")
        );

        Assert.equal(
            success,
            false,
            "Khong duoc khoa khi chua co ung vien"
        );
    }

    // 10. Không thể khóa khi toàn bộ ứng viên đã bị xóa
    function testCannotLockAfterAllCandidatesDeleted() public {
        manager.addCandidate(
            "Nguyen Van A",
            "Dang A",
            "Mo ta A"
        );

        manager.deleteCandidate(0);

        Assert.equal(
            manager.getValidCandidatesCount(),
            uint(0),
            "Phai khong con ung vien hop le"
        );

        (bool success, ) = address(manager).call(
            abi.encodeWithSignature("lockCandidates()")
        );

        Assert.equal(
            success,
            false,
            "Khong duoc khoa khi tat ca ung vien da bi xoa"
        );
    }

    // 11. Candidate nhận phiếu thông qua VotingCore
    function testCandidateVoteCountThroughVotingCore() public {
        ElectionScheduler scheduler =
            new ElectionScheduler();

        VotingCore core = new VotingCore(
            address(manager),
            address(scheduler)
        );

        manager.setVotingCore(address(core));

        manager.addCandidate(
            "Nguyen Van A",
            "Dang A",
            "Mo ta A"
        );

        manager.lockCandidates();
        scheduler.startElection();

        core.vote(0);

        CandidateManager.Candidate memory c =
            manager.getCandidate(0);

        Assert.equal(
            c.voteCount,
            uint(1),
            "Ung vien phai nhan duoc 1 phieu"
        );
    }
}