// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "remix_tests.sol";
import "remix_accounts.sol";

import "../contracts/ElectionScheduler.sol";
import "../contracts/VoterRegistry.sol";

contract BatchRegisterVoterTest {

    ElectionScheduler scheduler;
    VoterRegistry registry;

    function beforeEach() public {
        scheduler = new ElectionScheduler();

        registry = new VoterRegistry(
            address(scheduler)
        );
    }

    // 1. Batch đăng ký nhiều cử tri
    function testBatchRegister() public {
        address[] memory voters =
            new address[](4);

        voters[0] = TestsAccounts.getAccount(1);
        voters[1] = TestsAccounts.getAccount(2);
        voters[2] = TestsAccounts.getAccount(3);
        voters[3] = TestsAccounts.getAccount(4);

        registry.batchRegisterVoters(voters);

        Assert.equal(
            registry.totalVoters(),
            uint(4),
            "Phai dang ky du 4 voter"
        );
    }

    // 2. Batch rỗng
    function testBatchRegisterEmpty() public {
        address[] memory voters =
            new address[](0);

        (bool success, ) = address(registry).call(
            abi.encodeWithSignature(
                "batchRegisterVoters(address[])",
                voters
            )
        );

        Assert.equal(
            success,
            false,
            "Danh sach voter khong duoc rong"
        );
    }

    // 3. Batch có address 0
    function testBatchRegisterInvalidVoter() public {
        address[] memory voters =
            new address[](2);

        voters[0] = TestsAccounts.getAccount(1);
        voters[1] = address(0);

        (bool success, ) = address(registry).call(
            abi.encodeWithSignature(
                "batchRegisterVoters(address[])",
                voters
            )
        );

        Assert.equal(
            success,
            false,
            "Batch phai that bai khi co dia chi 0"
        );

        Assert.equal(
            registry.totalVoters(),
            uint(0),
            "Khong duoc dang ky mot phan"
        );
    }

    // 4. Batch có voter trùng
    function testBatchRegisterDuplicateVoter() public {
        address voter =
            TestsAccounts.getAccount(1);

        address[] memory voters =
            new address[](2);

        voters[0] = voter;
        voters[1] = voter;

        (bool success, ) = address(registry).call(
            abi.encodeWithSignature(
                "batchRegisterVoters(address[])",
                voters
            )
        );

        Assert.equal(
            success,
            false,
            "Batch phai that bai khi co voter trung"
        );

        Assert.equal(
            registry.totalVoters(),
            uint(0),
            "Khong duoc dang ky mot phan"
        );
    }

    // 5. Batch chỉ được thực hiện trước bầu cử
    function testBatchOnlyBeforeElection() public {
        address[] memory voters =
            new address[](2);

        voters[0] = TestsAccounts.getAccount(1);
        voters[1] = TestsAccounts.getAccount(2);

        registry.batchRegisterVoters(voters);

        Assert.equal(
            registry.totalVoters(),
            uint(2),
            "Batch phai thanh cong truoc bau cu"
        );

        scheduler.startElection();

        address[] memory newVoters =
            new address[](1);

        newVoters[0] =
            TestsAccounts.getAccount(3);

        (bool success, ) = address(registry).call(
            abi.encodeWithSignature(
                "batchRegisterVoters(address[])",
                newVoters
            )
        );

        Assert.equal(
            success,
            false,
            "Khong duoc batch register sau khi bat dau"
        );

        Assert.equal(
            registry.totalVoters(),
            uint(2),
            "Tong voter phai giu nguyen"
        );
    }
}