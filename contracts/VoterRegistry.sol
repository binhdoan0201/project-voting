// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ElectionScheduler.sol";

contract VoterRegistry {
    address public admin;
    ElectionScheduler public electionScheduler;
    mapping(address => bool) public registeredVoters;
    uint256 public totalVoters;

    event VoterRegistered(address indexed voter);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Chi admin moi duoc thuc hien");
        _;
    }

    modifier onlyBeforeElection() {
        require(
            electionScheduler.currentState() == ElectionScheduler.ElectionState.NotStarted,
            "Chi duoc dang ky truoc khi bau cu bat dau"
        );
        _;
    }

    constructor(address _electionSchedulerAddress) {
        require(
            _electionSchedulerAddress != address(0),
            "Dia chi ElectionScheduler khong hop le"
        );

        admin = msg.sender;
        electionScheduler = ElectionScheduler(_electionSchedulerAddress);

        require(
            electionScheduler.currentState() == ElectionScheduler.ElectionState.NotStarted,
            "Cuoc bau cu da bat dau hoac ket thuc"
        );
    }

    /// @notice Admin dang ky mot cu tri.
    /// @param _voter Dia chi vi cua cu tri.
    function registerVoter(address _voter) external onlyAdmin onlyBeforeElection {
        _registerVoter(_voter);
    }

    /// @notice Admin dang ky nhieu cu tri trong mot giao dich.
    /// @param _voters Mang dia chi vi cua cac cu tri.
    /// @dev Neu mot dia chi khong hop le, toan bo giao dich bi huy.
    function batchRegisterVoters(address[] calldata _voters)
        external
        onlyAdmin
        onlyBeforeElection
    {
        uint256 length = _voters.length;
        require(length > 0, "Danh sach cu tri khong duoc rong");

        for (uint256 index = 0; index < length; ) {
            _registerVoter(_voters[index]);
            unchecked {
                ++index;
            }
        }
    }

    function _registerVoter(address _voter) internal {
        require(_voter != address(0), "Dia chi cu tri khong hop le");
        require(!registeredVoters[_voter], "Cu tri da duoc dang ky");

        registeredVoters[_voter] = true;
        totalVoters++;
        emit VoterRegistered(_voter);
    }

    /// @notice Kiem tra dia chi da duoc dang ky hay chua.
    /// @param _voter Dia chi vi can kiem tra.
    /// @return true neu dia chi da dang ky.
    function isRegistered(address _voter) external view returns (bool) {
        return registeredVoters[_voter];
    }
}
