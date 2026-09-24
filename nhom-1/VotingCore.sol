// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// 1. Pragma & import
import "./CandidateManager.sol";
import "./ElectionScheduler.sol";

contract VotingCore {
    
    // ==========================================
    // 2. State variables
    // ==========================================
    CandidateManager public candidateManager;
    ElectionScheduler public electionScheduler;

    address public admin;
    mapping(address => bool) public hasVoted;
    uint256 public totalVotesCast;

    // ==========================================
    // 3. Events
    // ==========================================
    event Voted(address indexed voter, uint256 candidateId);

    // ==========================================
    // 5. Constructor
    // ==========================================
    constructor(address _candidateManagerAddress, address _electionSchedulerAddress) {
        admin = msg.sender;
        candidateManager = CandidateManager(_candidateManagerAddress);
        electionScheduler = ElectionScheduler(_electionSchedulerAddress);
    }

    // ==========================================
    // 6. External/public functions
    // ==========================================

    /// @notice Ghi nhận 1 phiếu bầu cho ứng viên được chỉ định
    /// @param _candidateId ID của ứng viên trong mảng candidates
    /// @dev Điều kiện là cuộc bầu cử đang diễn ra và cử tri chưa bầu
    function vote(uint _candidateId) public {
        require(electionScheduler.isElectionActive(), "Cuoc bau cu chua bat dau hoac da ket thuc");
        require(!hasVoted[msg.sender], "Ban da tham gia bau cu roi");
        
        candidateManager.incrementVote(_candidateId);
        
        hasVoted[msg.sender] = true;
        totalVotesCast++;

        emit Voted(msg.sender, _candidateId);
    }

    // ==========================================
    // 8. View/pure functions
    // ==========================================

    /// @notice Kiểm tra xem một địa chỉ đã bầu cử chưa
    /// @param _voter Địa chỉ ví của cử tri cần kiểm tra
    /// @return Trả về true nếu đã bầu, false nếu chưa
    function checkHasVoted(address _voter) public view returns (bool) {
        return hasVoted[_voter];
    }
}
