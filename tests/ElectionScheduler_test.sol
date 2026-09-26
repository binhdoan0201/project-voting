// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "remix_tests.sol";
import "remix_accounts.sol";

import "../contracts/ElectionScheduler.sol";

contract ElectionSchedulerTest {

    ElectionScheduler scheduler;

    function beforeEach() public {
        scheduler = new ElectionScheduler();
    }

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
    }

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
    }

    // 3. Không thể bắt đầu lại
    function testCannotStartElectionAgain() public {
        scheduler.startElection();

        (bool success, ) = address(scheduler).call(
            abi.encodeWithSignature("startElection()")
        );

        Assert.equal(
            success,
            false,
            "Khong duoc bat dau bau cu lan 2"
        );
    }

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
    }

    // 5. Không thể kết thúc khi chưa bắt đầu
    function testCannotEndBeforeStart() public {
        (bool success, ) = address(scheduler).call(
            abi.encodeWithSignature("endElection()")
        );

        Assert.equal(
            success,
            false,
            "Khong duoc ket thuc khi chua bat dau"
        );
    }

    // 6. Không thể kết thúc lần 2
    function testCannotEndElectionAgain() public {
        scheduler.startElection();
        scheduler.endElection();

        (bool success, ) = address(scheduler).call(
            abi.encodeWithSignature("endElection()")
        );

        Assert.equal(
            success,
            false,
            "Khong duoc ket thuc bau cu lan 2"
        );
    }
}