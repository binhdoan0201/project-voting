// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ICandidateManager {
    function getValidCandidatesCount() external view returns (uint);
    function candidatesLocked() external view returns (bool);
}

interface IVoterRegistry {
    function totalVoters() external view returns (uint256);
}

contract ElectionScheduler {

    // ==========================================
    // 2. State variables
    // ==========================================
    enum ElectionState { NotStarted, InProgress, Ended }

    address public admin;
    uint256 public startTime;
    uint256 public endTime;
    uint256 public electionDuration; // Thoi luong bau cu (tinh bang giay)
    
    ICandidateManager public candidateManager;
    IVoterRegistry public voterRegistry;

    // ==========================================
    // 3. Events
    // ==========================================
    event DependenciesSet(address candidateManager, address voterRegistry);
    event DurationSet(uint256 durationInSeconds);
    event ElectionStarted(uint256 startTime, uint256 endTime);
    event ElectionEndedManually(uint256 endTime);

    // ==========================================
    // 4. Modifiers
    // ==========================================
    modifier onlyAdmin() {
        require(msg.sender == admin, "Chi admin moi duoc thuc hien");
        _;
    }

    // ==========================================
    // 5. Constructor
    // ==========================================
    constructor() {
        admin = msg.sender;
    }

    // ==========================================
    // 6. External/public functions
    // ==========================================

    /// @notice Cai dat dia chi cac contract khac de kiem tra du lieu truoc khi mo bau cu
    function setDependencies(address _candidateManager, address _voterRegistry) public onlyAdmin {
        require(currentState() == ElectionState.NotStarted, "Khong the doi dependencies sau khi bau cu bat dau");
        require(_candidateManager != address(0) && _voterRegistry != address(0), "Dia chi khong hop le");
        candidateManager = ICandidateManager(_candidateManager);
        voterRegistry = IVoterRegistry(_voterRegistry);
        emit DependenciesSet(_candidateManager, _voterRegistry);
    }

    /// @notice Buoc 1: Cai dat thoi luong bau cu (tinh bang giay). Vi du: 3600 = 1 tieng.
    function setElectionDuration(uint256 _durationInSeconds) public onlyAdmin {
        require(currentState() == ElectionState.NotStarted, "Chi duoc cai dat thoi luong truoc khi bau cu bat dau");
        require(_durationInSeconds > 0, "Thoi luong phai lon hon 0");
        
        electionDuration = _durationInSeconds;
        emit DurationSet(_durationInSeconds);
    }

    /// @notice Buoc 2: Admin bam de BAT DAU bau cu ngay lap tuc. Se tu dong ket thuc sau (electionDuration) giay.
    function startElection() public onlyAdmin {
        require(address(candidateManager) != address(0) && address(voterRegistry) != address(0), "Vui long setDependencies truoc");
        require(candidateManager.candidatesLocked(), "Phai khoa danh sach ung vien (lockCandidates) truoc");
        require(candidateManager.getValidCandidatesCount() >= 1, "Phai co it nhat 1 ung vien de bau cu");
        require(voterRegistry.totalVoters() >= 1, "Phai co it nhat 1 cu tri de bau cu");
        require(currentState() == ElectionState.NotStarted, "Cuoc bau cu da bat dau hoac da ket thuc");
        require(electionDuration > 0, "Vui long cai dat thoi luong (setElectionDuration) truoc");

        startTime = block.timestamp;
        endTime = block.timestamp + electionDuration; // Tu dong cong don thoi gian de ra thoi diem ket thuc

        emit ElectionStarted(startTime, endTime);
    }

    /// @notice Admin co the tat (ket thuc) bau cu bat cu luc nao minh muon (tat som).
    function endElection() public onlyAdmin {
        require(currentState() == ElectionState.InProgress, "Cuoc bau cu chua dien ra hoac da ket thuc roi");

        endTime = block.timestamp; // E'p thoi gian ket thuc thanh thoi gian hien tai -> Khoa bau cu ngay lap tuc
        emit ElectionEndedManually(endTime);
    }

    // ==========================================
    // 8. View/pure functions
    // ==========================================

    /// @notice Tu dong tinh toan trang thai hien tai dua vao thoi gian thuc
    function currentState() public view returns (ElectionState) {
        if (startTime == 0 || endTime == 0) {
            return ElectionState.NotStarted;
        }
        if (block.timestamp >= startTime && block.timestamp < endTime) {
            return ElectionState.InProgress; // Dang trong khoang thoi gian cho phep
        }
        return ElectionState.Ended; // Da het thoi luong hoac bi Admin tat som
    }

    /// @notice Kiem tra xem cuoc bau cu co dang dien ra khong de cho phep vote
    function isElectionActive() public view returns (bool) {
        return currentState() == ElectionState.InProgress;
    }
}
