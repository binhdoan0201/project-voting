// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ElectionScheduler {

    // ==========================================
    // 2. State variables
    // ==========================================
    enum ElectionState { NotStarted, InProgress, Ended }

    ElectionState public currentState;
    address public admin;
    uint256 public startTime;
    uint256 public endTime;

    // ==========================================
    // 3. Events
    // ==========================================
    event ElectionStarted(uint256 startTime);
    event ElectionEnded(uint256 endTime);
    event StateChanged(ElectionState newState);

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
        currentState = ElectionState.NotStarted;
    }

    // ==========================================
    // 6. External/public functions
    // ==========================================

    /// @notice Báº¯t Ä‘áº§u cuá»™c báº§u cá»­
    /// @dev Chuyá»ƒn tráº¡ng thÃ¡i sang InProgress vÃ  ghi nháº­n thá»i gian
    function startElection() public onlyAdmin {
        require(currentState == ElectionState.NotStarted, "Cuoc bau cu da bat dau hoac ket thuc");

        currentState = ElectionState.InProgress;
        startTime = block.timestamp;

        emit ElectionStarted(startTime);
        emit StateChanged(currentState);
    }

    /// @notice Káº¿t thÃºc cuá»™c báº§u cá»­
    /// @dev Chuyá»ƒn tráº¡ng thÃ¡i sang Ended vÃ  ghi nháº­n thá»i gian
    function endElection() public onlyAdmin {
        require(currentState == ElectionState.InProgress, "Cuoc bau cu chua dien ra hoac da ket thuc");

        currentState = ElectionState.Ended;
        endTime = block.timestamp;

        emit ElectionEnded(endTime);
        emit StateChanged(currentState);
    }

    // ==========================================
    // 8. View/pure functions
    // ==========================================

    /// @notice Kiá»ƒm tra xem cuá»™c báº§u cá»­ cÃ³ Ä‘ang diá»…n ra khÃ´ng
    /// @return Tráº£ vá» true náº¿u Ä‘ang diá»…n ra, ngÆ°á»£c láº¡i lÃ  false
    function isElectionActive() public view returns (bool) {
        return currentState == ElectionState.InProgress;
    }
}
