// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "remix_tests.sol";
import "remix_accounts.sol";

import "../contracts/ElectionScheduler.sol";
import "../contracts/VoterRegistry.sol";

contract VoterRegistryTest {

    VoterRegistry registry;
    ElectionScheduler scheduler;

    // ==========================================
    // 1. Setup
    // ==========================================

    function beforeEach() public {
        scheduler = new ElectionScheduler();

        registry = new VoterRegistry(
            address(scheduler)
        );
    }

    // ==========================================
    // 2. Test đăng ký cử tri
    // ==========================================

    // 1. Đăng ký cử tri trước bầu cử
    function testRegisterVoterBeforeElection() public {
        address voter =
            TestsAccounts.getAccount(1);

        registry.registerVoter(voter);

        Assert.equal(
            registry.isRegistered(voter),
            true,
            "Voter phai duoc dang ky"
        );

        Assert.equal(
            registry.totalVoters(),
            uint(1),
            "Tong voter phai bang 1"
        );
    }

    // ==========================================
    // 3. Test địa chỉ không hợp lệ
    // ==========================================

    // 2. Không đăng ký địa chỉ 0
    function testCannotRegisterZeroAddress() public {
        (bool success, ) = address(registry).call(
            abi.encodeWithSignature(
                "registerVoter(address)",
                address(0)
            )
        );

        Assert.equal(
            success,
            false,
            "Khong duoc dang ky address 0"
        );

        Assert.equal(
            registry.totalVoters(),
            uint(0),
            "Tong voter phai bang 0"
        );
    }

    // 3. Không đăng ký trùng
    function testCannotRegisterDuplicateVoter() public {
        address voter =
            TestsAccounts.getAccount(1);

        registry.registerVoter(voter);

        (bool success, ) = address(registry).call(
            abi.encodeWithSignature(
                "registerVoter(address)",
                voter
            )
        );

        Assert.equal(
            success,
            false,
            "Khong duoc dang ky voter trung"
        );

        Assert.equal(
            registry.totalVoters(),
            uint(1),
            "Tong voter khong duoc tang"
        );

        Assert.equal(
            registry.isRegistered(voter),
            true,
            "Voter van phai o trang thai da dang ky"
        );
    }

    // ==========================================
    // 4. Test batch đăng ký
    // ==========================================

    // 4. Batch đăng ký cử tri
    function testBatchRegisterVoters() public {
        address[] memory voters =
            new address[](3);

        voters[0] = TestsAccounts.getAccount(1);
        voters[1] = TestsAccounts.getAccount(2);
        voters[2] = TestsAccounts.getAccount(3);

        registry.batchRegisterVoters(voters);

        Assert.equal(
            registry.totalVoters(),
            uint(3),
            "Phai co 3 voter"
        );

        Assert.equal(
            registry.isRegistered(voters[0]),
            true,
            "Voter 1 phai duoc dang ky"
        );

        Assert.equal(
            registry.isRegistered(voters[1]),
            true,
            "Voter 2 phai duoc dang ky"
        );

        Assert.equal(
            registry.isRegistered(voters[2]),
            true,
            "Voter 3 phai duoc dang ky"
        );
    }

    // 5. Không batch danh sách rỗng
    function testCannotBatchRegisterEmptyList() public {
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

        Assert.equal(
            registry.totalVoters(),
            uint(0),
            "Tong voter phai van bang 0"
        );
    }

    // ==========================================
    // 5. Test thời điểm đăng ký
    // ==========================================

    // 6. Không đăng ký sau khi bầu cử bắt đầu
    function testCannotRegisterAfterElectionStarted() public {
        scheduler.startElection();

        address voter =
            TestsAccounts.getAccount(1);

        (bool success, ) = address(registry).call(
            abi.encodeWithSignature(
                "registerVoter(address)",
                voter
            )
        );

        Assert.equal(
            success,
            false,
            "Khong duoc dang ky sau khi bau cu bat dau"
        );

        Assert.equal(
            registry.totalVoters(),
            uint(0),
            "Khong duoc them voter"
        );

        Assert.equal(
            registry.isRegistered(voter),
            false,
            "Voter khong duoc dang ky"
        );
    }

    // 7. Không batch đăng ký sau khi bầu cử bắt đầu
    function testCannotBatchRegisterAfterElectionStarted() public {
        scheduler.startElection();

        address[] memory voters =
            new address[](2);

        voters[0] = TestsAccounts.getAccount(1);
        voters[1] = TestsAccounts.getAccount(2);

        (bool success, ) = address(registry).call(
            abi.encodeWithSignature(
                "batchRegisterVoters(address[])",
                voters
            )
        );

        Assert.equal(
            success,
            false,
            "Khong duoc batch register sau khi bau cu bat dau"
        );

        Assert.equal(
            registry.totalVoters(),
            uint(0),
            "Khong duoc them voter"
        );
    }

    // 8. Không đăng ký sau khi bầu cử kết thúc
    function testCannotRegisterAfterElectionEnded() public {
        scheduler.startElection();
        scheduler.endElection();

        address voter =
            TestsAccounts.getAccount(1);

        (bool success, ) = address(registry).call(
            abi.encodeWithSignature(
                "registerVoter(address)",
                voter
            )
        );

        Assert.equal(
            success,
            false,
            "Khong duoc dang ky sau khi bau cu ket thuc"
        );

        Assert.equal(
            registry.totalVoters(),
            uint(0),
            "Khong duoc them voter"
        );
    }

    // ==========================================
    // 6. Test kiểm tra trạng thái cử tri
    // ==========================================

    // 9. Kiểm tra isRegistered
    function testIsRegistered() public {
        address voter =
            TestsAccounts.getAccount(1);

        Assert.equal(
            registry.isRegistered(voter),
            false,
            "Voter chua dang ky phai la false"
        );

        registry.registerVoter(voter);

        Assert.equal(
            registry.isRegistered(voter),
            true,
            "Voter da dang ky phai la true"
        );
    }
}