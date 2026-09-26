// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "remix_tests.sol";
import "remix_accounts.sol";

import "../contracts/ElectionScheduler.sol";

contract ElectionSchedulerTest {

    ElectionScheduler scheduler;

    // ==========================================
    // 1. Setup
    // ==========================================

    function beforeEach() public {
        scheduler = new ElectionScheduler();
    }

    // ==========================================
    // 2. Test trạng thái ban đầu
    // ==========================================

    // 1. Trạng thái ban đầu
    function testInitialState() public {
        Assert.equal(
            uint(scheduler.currentState()),
            uint(ElectionScheduler.ElectionState.NotStarted),
            "Trang thai ban dau phai la NotStarted"
        );

        Assert.equal(
            scheduler.isElectionActive(),
            false,
            "Bau cu chua duoc dien ra"
        );

        Assert.equal(
            scheduler.startTime(),
            uint(0),
            "startTime ban dau phai bang 0"
        );

        Assert.equal(
            scheduler.endTime(),
            uint(0),
            "endTime ban dau phai bang 0"
        );
    }

    // ==========================================
    // 3. Test bắt đầu bầu cử
    // ==========================================

    // 2. Bắt đầu bầu cử
    function testStartElection() public {
        scheduler.startElection();

        Assert.equal(
            uint(scheduler.currentState()),
            uint(ElectionScheduler.ElectionState.InProgress),
            "Trang thai phai la InProgress"
        );

        Assert.equal(
            scheduler.isElectionActive(),
            true,
            "Cuoc bau cu phai dang hoat dong"
        );

        Assert.equal(
            scheduler.startTime() > 0,
            true,
            "Phai ghi nhan startTime"
        );

        Assert.equal(
            scheduler.endTime(),
            uint(0),
            "endTime chua duoc ghi nhan"
        );
    }

    // ==========================================
    // 4. Test không thể bắt đầu lại
    // ==========================================

    // 3. Không thể bắt đầu lại
    function testCannotStartElectionAgain() public {
        scheduler.startElection();

        (bool success, ) = address(scheduler).call(
            abi.encodeWithSignature(
                "startElection()"
            )
        );

        Assert.equal(
            success,
            false,
            "Khong duoc bat dau bau cu lan 2"
        );
    }

    // ==========================================
    // 5. Test kết thúc bầu cử
    // ==========================================

    // 4. Kết thúc bầu cử
    function testEndElection() public {
        scheduler.startElection();

        scheduler.endElection();

        Assert.equal(
            uint(scheduler.currentState()),
            uint(ElectionScheduler.ElectionState.Ended),
            "Trang thai phai la Ended"
        );

        Assert.equal(
            scheduler.isElectionActive(),
            false,
            "Cuoc bau cu phai ngung hoat dong"
        );

        Assert.equal(
            scheduler.endTime() > 0,
            true,
            "Phai ghi nhan endTime"
        );

        Assert.equal(
            scheduler.endTime() >= scheduler.startTime(),
            true,
            "endTime phai lon hon hoac bang startTime"
        );
    }

    // ==========================================
    // 6. Test không thể kết thúc trước khi bắt đầu
    // ==========================================

    // 5. Không thể kết thúc khi chưa bắt đầu
    function testCannotEndBeforeStart() public {
        (bool success, ) = address(scheduler).call(
            abi.encodeWithSignature(
                "endElection()"
            )
        );

        Assert.equal(
            success,
            false,
            "Khong duoc ket thuc khi chua bat dau"
        );

        Assert.equal(
            uint(scheduler.currentState()),
            uint(ElectionScheduler.ElectionState.NotStarted),
            "Trang thai van phai la NotStarted"
        );
    }

    // ==========================================
    // 7. Test không thể kết thúc lần 2
    // ==========================================

    // 6. Không thể kết thúc lần 2
    function testCannotEndElectionAgain() public {
        scheduler.startElection();

        scheduler.endElection();

        (bool success, ) = address(scheduler).call(
            abi.encodeWithSignature(
                "endElection()"
            )
        );

        Assert.equal(
            success,
            false,
            "Khong duoc ket thuc bau cu lan 2"
        );

        Assert.equal(
            uint(scheduler.currentState()),
            uint(ElectionScheduler.ElectionState.Ended),
            "Trang thai van phai la Ended"
        );
    }
}