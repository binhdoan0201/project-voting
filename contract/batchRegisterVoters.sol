// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ElectionScheduler.sol";

contract VoterRegistry {
    // ==========================================
    // 1. State variables
    // ==========================================

    address public admin;
    ElectionScheduler public electionScheduler;

    // true: dia chi da duoc dang ky bo phieu.
    mapping(address => bool) public registeredVoters;

    uint256 public totalVoters;

    // ==========================================
    // 2. Events
    // ==========================================

    event VoterRegistered(address indexed voter);

    // ==========================================
    // 3. Modifiers
    // ==========================================

    modifier onlyAdmin() {
        require(
            msg.sender == admin,
            "Chi admin moi duoc thuc hien"
        );
        _;
    }

    modifier onlyBeforeElection() {
        require(
            electionScheduler.currentState() ==
                ElectionScheduler.ElectionState.NotStarted,
            "Chi duoc dang ky truoc khi bau cu bat dau"
        );
        _;
    }

    // ==========================================
    // 4. Constructor
    // ==========================================

    /// @param _electionSchedulerAddress Dia chi contract
    /// ElectionScheduler da deploy.
    constructor(address _electionSchedulerAddress) {
        require(
            _electionSchedulerAddress != address(0),
            "Dia chi ElectionScheduler khong hop le"
        );

        admin = msg.sender;

        electionScheduler = ElectionScheduler(
            _electionSchedulerAddress
        );

        require(
            electionScheduler.currentState() ==
                ElectionScheduler.ElectionState.NotStarted,
            "Cuoc bau cu da bat dau hoac ket thuc"
        );
    }

    // ==========================================
    // 5. External/public functions
    // ==========================================

    /// @notice Admin dang ky mot cu tri.
    /// @param _voter Dia chi vi cua cu tri.
    function registerVoter(address _voter)
        public
        onlyAdmin
        onlyBeforeElection
    {
        _registerVoter(_voter);
    }

    // Nguoi E bo sung batchRegisterVoters tai day.
    // Ham batch phai su dung:
    // - onlyAdmin
    // - onlyBeforeElection
    // - _registerVoter(...) cho tung dia chi.
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

        for (uint256 i = 0; i < length; ) {
            // Tai su dung kiem tra dia chi rong, trung,
            // tang totalVoters va phat event.
            _registerVoter(_voters[i]);

            // An toan vi i < length nen i chua the la uint256 max.
            unchecked {
                ++i;
            }
        }
    }
    // ==========================================
    // 6. Internal functions
    // ==========================================

    /// @dev Logic dung chung cho dang ky don va hang loat.
    function _registerVoter(address _voter) internal {
        require(
            _voter != address(0),
            "Dia chi cu tri khong hop le"
        );

        require(
            !registeredVoters[_voter],
            "Cu tri da duoc dang ky"
        );

        registeredVoters[_voter] = true;
        totalVoters++;

        emit VoterRegistered(_voter);
    }

    // ==========================================
    // 7. View/pure functions
    // ==========================================

    /// @notice Kiem tra dia chi da duoc dang ky hay chua.
    function isRegistered(address _voter)
        public
        view
        returns (bool)
    {
        return registeredVoters[_voter];
    }
}