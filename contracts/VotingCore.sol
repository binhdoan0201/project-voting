// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// 1. Pragma & import
import "./VoterRegistry.sol";
import "./CandidateManager.sol";
import "./ElectionScheduler.sol";

// Hợp nhất các module
contract VotingCore is VoterRegistry, CandidateManager, ElectionScheduler {
    
    // 2. State variables
    
    // 3. Events
    
    // 4. Modifiers
    
    // 5. Constructor
    constructor() {}

    // 6. External/public functions
    
    /// @notice Ghi nhận 1 phiếu bầu cho ứng viên được chỉ định
    /// @param _candidateId ID của ứng viên trong mảng candidates
    function vote(uint _candidateId) external {
        // TODO: Nhóm 1 và 2 sẽ ráp logic vào đây sau
    }

    // 7. Internal/private functions
    
    // 8. View/pure functions
}