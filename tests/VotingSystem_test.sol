// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "remix_tests.sol";
import "../contracts/ElectionScheduler.sol";
import "../contracts/CandidateManager.sol";
import "../contracts/VoterRegistry.sol";
import "../contracts/VotingCore.sol";

// Proxy giả lập Cử tri / Non-Admin (Được tối ưu chuẩn Remix Runner)
contract UserProxy {
    fallback() external payable {
        address target = VotingSystemFull19Test(msg.sender).currentTarget();
        (bool success, ) = target.call(msg.data);
        require(success, "PROXY_CALL_FAILED");
    }
}

contract VotingSystemFull19Test {
    ElectionScheduler internal scheduler;
    CandidateManager internal candidateMgr;
    VoterRegistry internal voterReg;
    VotingCore internal votingCore;

    UserProxy internal user1;
    UserProxy internal user2;

    address public currentTarget;

    function beforeEach() public {
        scheduler = new ElectionScheduler();
        candidateMgr = new CandidateManager();
        voterReg = new VoterRegistry(address(scheduler));
        votingCore = new VotingCore(
            address(candidateMgr), 
            address(scheduler), 
            address(voterReg)
        );

        candidateMgr.setVotingCore(address(votingCore));

        user1 = new UserProxy();
        user2 = new UserProxy();
    }

    // =========================================================================
    // STT: 1 | Mã TC: TC_ADM_01 | Chức năng: setVotingCore | Contract: CandidateManager
    // Thao tác: Admin dùng ví gọi hàm và truyền địa chỉ VotingCore
    // Kết quả mong đợi: Giao dịch thành công, liên kết 2 contract chuẩn xác
    // =========================================================================
    function test_01_TC_ADM_01_setVotingCore() public {
        Assert.equal(candidateMgr.votingCoreAddress(), address(votingCore), "TC_ADM_01 Failed");
    }

    // =========================================================================
    // STT: 2 | Mã TC: TC_ADM_02 | Chức năng: addCandidate | Contract: CandidateManager
    // Thao tác: Admin nhập tên ứng viên (Obama, Trump) khi hòm phiếu chưa mở
    // Kết quả mong đợi: Giao dịch thành công, ứng viên ghi nhận vào hệ thống
    // =========================================================================
    function test_02_TC_ADM_02_addCandidate() public {
        candidateMgr.addCandidate("Obama", "Party A", "Mo ta Obama");
        candidateMgr.addCandidate("Trump", "Party B", "Mo ta Trump");
        Assert.equal(candidateMgr.getValidCandidatesCount(), 2, "TC_ADM_02 Failed");
    }

    // =========================================================================
    // STT: 3 | Mã TC: TC_SEC_01 | Chức năng: addCandidate (Quyền) | Contract: CandidateManager
    // Thao tác: Cử tri (ví không phải Admin) cố tình gọi hàm addCandidate
    // Kết quả mong đợi: Hệ thống chặn giao dịch: 'Chi admin moi duoc thuc hien'
    // =========================================================================
    function test_03_TC_SEC_01_addCandidate_NonAdmin() public {
        currentTarget = address(candidateMgr);
        (bool ok, ) = address(user1).call(
            abi.encodeWithSignature("addCandidate(string,string,string)", "Hack", "Hack", "Hack")
        );
        Assert.equal(ok, false, "TC_SEC_01 Failed");
    }

    // =========================================================================
    // STT: 4 | Mã TC: TC_REG_01 | Chức năng: registerVoter | Contract: VoterRegistry
    // Thao tác: Admin gọi registerVoter để đăng ký 1 cử tri khi chưa bầu cử
    // Kết quả mong đợi: Giao dịch thành công, isRegistered = true, totalVoters + 1
    // =========================================================================
    function test_04_TC_REG_01_registerVoter() public {
        voterReg.registerVoter(address(user1));
        Assert.equal(voterReg.isRegistered(address(user1)), true, "TC_REG_01 Failed");
    }

    // =========================================================================
    // STT: 5 | Mã TC: TC_REG_02 | Chức năng: registerVoter (Quyền) | Contract: VoterRegistry
    // Thao tác: Cử tri (ví không phải Admin) cố bấm registerVoter(address)
    // Kết quả mong đợi: Hệ thống chặn giao dịch: 'Chi admin moi duoc thuc hien'
    // =========================================================================
    function test_05_TC_REG_02_registerVoter_NonAdmin() public {
        currentTarget = address(voterReg);
        (bool ok, ) = address(user1).call(
            abi.encodeWithSignature("registerVoter(address)", address(user2))
        );
        Assert.equal(ok, false, "TC_REG_02 Failed");
    }

    // =========================================================================
    // STT: 6 | Mã TC: TC_REG_03 | Chức năng: registerVoter (Trùng) | Contract: VoterRegistry
    // Thao tác: Admin đăng ký lại cử tri đã được đăng ký trước đó
    // Kết quả mong đợi: Hệ thống chặn giao dịch: 'Cu tri da duoc dang ky'
    // =========================================================================
    function test_06_TC_REG_03_registerVoter_Duplicate() public {
        voterReg.registerVoter(address(user1));
        (bool ok, ) = address(voterReg).call(
            abi.encodeWithSignature("registerVoter(address)", address(user1))
        );
        Assert.equal(ok, false, "TC_REG_03 Failed");
    }

    // =========================================================================
    // STT: 7 | Mã TC: TC_REG_04 | Chức năng: batchRegisterVoters | Contract: VoterRegistry
    // Thao tác: Admin gọi batchRegisterVoters đăng ký nhiều ví cùng lúc
    // Kết quả mong đợi: Giao dịch thành công, đăng ký danh sách cử tri hàng loạt
    // =========================================================================
    function test_07_TC_REG_04_batchRegisterVoters() public {
        address[] memory list = new address[](2);
        list[0] = address(user1);
        list[1] = address(user2);
        voterReg.batchRegisterVoters(list);
        Assert.equal(voterReg.isRegistered(address(user1)), true, "TC_REG_04 User1 Failed");
        Assert.equal(voterReg.isRegistered(address(user2)), true, "TC_REG_04 User2 Failed");
    }

    // =========================================================================
    // STT: 8 | Mã TC: TC_REG_05 | Chức năng: batchRegister (Quyền) | Contract: VoterRegistry
    // Thao tác: Cử tri (ví không phải Admin) cố gọi batchRegisterVoters
    // Kết quả mong đợi: Hệ thống chặn giao dịch: 'Chi admin moi duoc thuc hien'
    // =========================================================================
    function test_08_TC_REG_05_batchRegister_NonAdmin() public {
        currentTarget = address(voterReg);
        address[] memory list = new address[](1);
        list[0] = address(user1);
        (bool ok, ) = address(user1).call(
            abi.encodeWithSignature("batchRegisterVoters(address[])", list)
        );
        Assert.equal(ok, false, "TC_REG_05 Failed");
    }

    // =========================================================================
    // STT: 9 | Mã TC: TC_SCH_01 | Chức năng: startElection | Contract: ElectionScheduler
    // Thao tác: Admin gọi hàm startElection() để mở cuộc bầu cử
    // Kết quả mong đợi: Giao dịch thành công, chuyển trạng thái sang Active
    // =========================================================================
    function test_09_TC_SCH_01_startElection() public {
        scheduler.startElection();
        Assert.equal(scheduler.isElectionActive(), true, "TC_SCH_01 Failed");
    }

    // =========================================================================
    // STT: 10 | Mã TC: TC_REG_06 | Chức năng: registerVoter (Sau Mở) | Contract: VoterRegistry
    // Thao tác: Admin cố đăng ký cử tri sau khi startElection đã bấm
    // Kết quả mong đợi: Hệ thống chặn: 'Chi duoc dang ky truoc khi bau cu bat dau'
    // =========================================================================
    function test_10_TC_REG_06_registerVoter_AfterStart() public {
        scheduler.startElection();
        (bool ok, ) = address(voterReg).call(
            abi.encodeWithSignature("registerVoter(address)", address(user1))
        );
        Assert.equal(ok, false, "TC_REG_06 Failed");
    }

    // =========================================================================
    // STT: 11 | Mã TC: TC_SCH_02 | Chức năng: startElection (Trùng) | Contract: ElectionScheduler
    // Thao tác: Admin cố tình gọi startElection() lần thứ 2 khi đã chạy
    // Kết quả mong đợi: Hệ thống chặn: 'Cuoc bau cu da bat dau hoac ket thuc'
    // =========================================================================
    function test_11_TC_SCH_02_startElection_Duplicate() public {
        scheduler.startElection();
        (bool ok, ) = address(scheduler).call(abi.encodeWithSignature("startElection()"));
        Assert.equal(ok, false, "TC_SCH_02 Failed");
    }

    // =========================================================================
    // STT: 12 | Mã TC: TC_VOT_01 | Chức năng: vote (Hợp lệ) | Contract: VotingCore
    // Thao tác: Cử tri 1 gọi hàm vote(0) bầu cho Obama
    // Kết quả mong đợi: Giao dịch thành công, kích hoạt sự kiện Voted
    // =========================================================================
    function test_12_TC_VOT_01_vote_Valid() public {
        candidateMgr.addCandidate("Obama", "Party A", "Mo ta");
        voterReg.registerVoter(address(user1));
        scheduler.startElection();

        currentTarget = address(votingCore);
        (bool ok, ) = address(user1).call(abi.encodeWithSignature("vote(uint256)", 0));
        Assert.equal(ok, true, "TC_VOT_01 Vote Failed");
        Assert.equal(votingCore.checkHasVoted(address(user1)), true, "TC_VOT_01 Check Failed");
    }

    // =========================================================================
    // STT: 13 | Mã TC: TC_SEC_02 | Chức năng: vote (Double Vote) | Contract: VotingCore
    // Thao tác: Cử tri 1 tiếp tục gọi hàm vote(0) lần thứ 2 với cùng 1 ví
    // Kết quả mong đợi: Hệ thống chặn giao dịch: 'Ban da tham gia bau cu roi'
    // =========================================================================
    function test_13_TC_SEC_02_vote_DoubleVote() public {
        candidateMgr.addCandidate("Obama", "Party A", "Mo ta");
        voterReg.registerVoter(address(user1));
        scheduler.startElection();

        currentTarget = address(votingCore);
        (bool ok1, ) = address(user1).call(abi.encodeWithSignature("vote(uint256)", 0));
        Assert.equal(ok1, true, "TC_SEC_02 First Vote Failed");

        (bool ok2, ) = address(user1).call(abi.encodeWithSignature("vote(uint256)", 0));
        Assert.equal(ok2, false, "TC_SEC_02 Double Vote Should Fail");
    }

    // =========================================================================
    // STT: 14 | Mã TC: TC_VOT_02 | Chức năng: vote (Cử tri mới) | Contract: VotingCore
    // Thao tác: Cử tri 2 (chuyển ví mới) gọi hàm vote(0)
    // Kết quả mong đợi: Giao dịch thành công, ghi nhận thêm 1 phiếu cho ID 0
    // =========================================================================
    function test_14_TC_VOT_02_vote_SecondVoter() public {
        candidateMgr.addCandidate("Obama", "Party A", "Mo ta");
        voterReg.registerVoter(address(user1));
        voterReg.registerVoter(address(user2));
        scheduler.startElection();

        currentTarget = address(votingCore);
        (bool ok1, ) = address(user1).call(abi.encodeWithSignature("vote(uint256)", 0));
        Assert.equal(ok1, true, "TC_VOT_02 First Vote Failed");

        (bool ok2, ) = address(user2).call(abi.encodeWithSignature("vote(uint256)", 0));
        Assert.equal(ok2, true, "TC_VOT_02 Second Vote Failed");
    }

    // =========================================================================
    // STT: 15 | Mã TC: TC_SEC_03 | Chức năng: vote (ID sai) | Contract: VotingCore
    // Thao tác: Cử tri dùng ví mới gọi vote(999) bầu cho ID không tồn tại
    // Kết quả mong đợi: Hệ thống chặn giao dịch: 'Ung vien khong ton tai'
    // =========================================================================
    function test_15_TC_SEC_03_vote_InvalidID() public {
        candidateMgr.addCandidate("Obama", "Party A", "Mo ta");
        voterReg.registerVoter(address(user1));
        scheduler.startElection();

        currentTarget = address(votingCore);
        (bool ok, ) = address(user1).call(abi.encodeWithSignature("vote(uint256)", 999));
        Assert.equal(ok, false, "TC_SEC_03 Failed");
    }

    // =========================================================================
    // STT: 16 | Mã TC: TC_SEC_04 | Chức năng: endElection (Quyền) | Contract: ElectionScheduler
    // Thao tác: Cử tri (ví không phải Admin) cố bấm endElection()
    // Kết quả mong đợi: Hệ thống chặn giao dịch: 'Chi admin moi duoc thuc hien'
    // =========================================================================
    function test_16_TC_SEC_04_endElection_NonAdmin() public {
        scheduler.startElection();

        currentTarget = address(scheduler);
        (bool ok, ) = address(user1).call(abi.encodeWithSignature("endElection()"));
        Assert.equal(ok, false, "TC_SEC_04 Failed");
    }

    // =========================================================================
    // STT: 17 | Mã TC: TC_SCH_03 | Chức năng: endElection | Contract: ElectionScheduler
    // Thao tác: Admin chọn lại ví admin bấm endElection() để chốt sổ
    // Kết quả mong đợi: Giao dịch thành công, đóng hòm phiếu
    // =========================================================================
    function test_17_TC_SCH_03_endElection() public {
        scheduler.startElection();
        scheduler.endElection();
        Assert.equal(scheduler.isElectionActive(), false, "TC_SCH_03 Failed");
    }

    // =========================================================================
    // STT: 18 | Mã TC: TC_RES_01 | Chức năng: getAllCandidates | Contract: CandidateManager
    // Thao tác: Bấm getAllCandidates() để kiểm tra kết quả tổng kết
    // Kết quả mong đợi: Trả về: Ứng viên 0 (Obama) = 2 votes, Ứng viên 1 (Trump) = 0 votes
    // =========================================================================
    function test_18_TC_RES_01_getAllCandidates() public {
        candidateMgr.addCandidate("Obama", "Party A", "Mo ta");
        candidateMgr.addCandidate("Trump", "Party B", "Mo ta");
        voterReg.registerVoter(address(user1));
        voterReg.registerVoter(address(user2));
        scheduler.startElection();

        currentTarget = address(votingCore);
        (bool ok1, ) = address(user1).call(abi.encodeWithSignature("vote(uint256)", 0));
        (bool ok2, ) = address(user2).call(abi.encodeWithSignature("vote(uint256)", 0));
        Assert.equal(ok1 && ok2, true, "TC_RES_01 Voting Failed");

        scheduler.endElection();

        CandidateManager.Candidate[] memory candidates = candidateMgr.getAllCandidates();
        Assert.equal(candidates[0].voteCount, 2, "TC_RES_01 Candidate 0 Failed");
        Assert.equal(candidates[1].voteCount, 0, "TC_RES_01 Candidate 1 Failed");
    }

    // =========================================================================
    // STT: 19 | Mã TC: TC_SEC_05 | Chức năng: vote (Đi muộn) | Contract: VotingCore
    // Thao tác: Cử tri mới cố tình vote(0) sau khi Admin đã bấm endElection()
    // Kết quả mong đợi: Hệ thống chặn: 'Cuoc bau cu chua bat dau hoac da ket thuc'
    // =========================================================================
    function test_19_TC_SEC_05_vote_Late() public {
        candidateMgr.addCandidate("Obama", "Party A", "Mo ta");
        voterReg.registerVoter(address(user1));
        scheduler.startElection();
        scheduler.endElection();

        currentTarget = address(votingCore);
        (bool ok, ) = address(user1).call(abi.encodeWithSignature("vote(uint256)", 0));
        Assert.equal(ok, false, "TC_SEC_05 Failed");
    }
}
