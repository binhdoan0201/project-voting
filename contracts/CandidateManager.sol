// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CandidateManager {

    // ==========================================
    // 2. State variables
    // ==========================================
    struct Candidate {
        uint id;
        string name;
        string party;
        string description;
        uint voteCount;
        bool isActive;
    }

    Candidate[] public candidates;
    bool public candidatesLocked = false;
    address public admin;
    address public votingCoreAddress;

    // ==========================================
    // 3. Events
    // ==========================================
    event CandidateAdded(uint candidateId, string name, string party);
    event CandidateUpdated(uint candidateId, string newName, string newParty);
    event CandidateDeleted(uint candidateId);
    event CandidatesLocked();
    event CoreContractSet(address coreAddress);

    // ==========================================
    // 4. Modifiers
    // ==========================================
    modifier onlyAdmin() {
        require(msg.sender == admin, "Chi admin moi duoc thuc hien");
        _;
    }

    modifier onlyCore() {
        require(msg.sender == votingCoreAddress, "Chi VotingCore moi duoc goi ham nay");
        _;
    }

    modifier candidatesNotLocked() {
        require(!candidatesLocked, "Danh sach ung vien da bi khoa");
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

    /// @notice Cài đặt địa chỉ cho Voting Core contract
    /// @param _coreAddress Địa chỉ của VotingCore contract
    function setVotingCore(address _coreAddress) public onlyAdmin {
        votingCoreAddress = _coreAddress;
        emit CoreContractSet(_coreAddress);
    }
    
    /// @notice Thêm một ứng viên mới vào danh sách
    /// @param _name Tên ứng viên
    /// @param _party Đảng phái của ứng viên
    /// @param _description Mô tả thêm
    function addCandidate(string memory _name, string memory _party, string memory _description) public onlyAdmin candidatesNotLocked {
        uint _candidateId = candidates.length;
        candidates.push(Candidate({
            id: _candidateId, 
            name: _name, 
            party: _party,
            description: _description,
            voteCount: 0, 
            isActive: true
        }));
        
        emit CandidateAdded(_candidateId, _name, _party);
    }

    /// @notice Cập nhật thông tin của một ứng viên đã có
    /// @param _id ID của ứng viên
    /// @param _newName Tên mới của ứng viên
    /// @param _newParty Đảng phái mới
    /// @param _newDescription Mô tả mới
    function updateCandidate(uint _id, string memory _newName, string memory _newParty, string memory _newDescription) public onlyAdmin candidatesNotLocked {
        require(_id < candidates.length, "Ung vien khong ton tai");
        require(candidates[_id].isActive, "Ung vien da bi xoa");
        
        candidates[_id].name = _newName;
        candidates[_id].party = _newParty;
        candidates[_id].description = _newDescription;
        
        emit CandidateUpdated(_id, _newName, _newParty);
    }

    /// @notice Xóa mềm một ứng viên (ẩn đi chứ không xóa khỏi mảng)
    /// @param _id ID của ứng viên cần xóa
    function deleteCandidate(uint _id) public onlyAdmin candidatesNotLocked {
        require(_id < candidates.length, "Ung vien khong ton tai");
        require(candidates[_id].isActive, "Ung vien da bi xoa roi");
        
        candidates[_id].isActive = false; 
        emit CandidateDeleted(_id);
    }

    /// @notice Khóa danh sách ứng viên không cho thao tác nữa
    /// @dev Cần ít nhất 1 ứng viên hợp lệ để khóa
    function lockCandidates() public onlyAdmin candidatesNotLocked {
        require(getValidCandidatesCount() > 0, "Phai co it nhat 1 ung vien de khoa"); 
        candidatesLocked = true;
        
        emit CandidatesLocked();
    }

    /// @notice Tăng số phiếu bầu cho ứng viên (Chỉ dành cho Core)
    /// @param _id ID của ứng viên
    function incrementVote(uint _id) public onlyCore {
        require(_id < candidates.length, "Ung vien khong ton tai");
        require(candidates[_id].isActive, "Ung vien khong hop le hoac bi xoa");
        candidates[_id].voteCount++;
    }

    // ==========================================
    // 8. View/pure functions
    // ==========================================

    /// @notice Đếm số lượng ứng viên hợp lệ
    /// @return count Số lượng ứng viên chưa bị xóa
    function getValidCandidatesCount() public view returns (uint) {
        uint count = 0;
        for (uint i = 0; i < candidates.length; i++) {
            if (candidates[i].isActive) {
                count++;
            }
        }
        return count;
    }

    /// @notice Lấy thông tin của một ứng viên
    /// @param _id ID của ứng viên
    /// @return Struct Candidate tương ứng
    function getCandidate(uint _id) public view returns (Candidate memory) {
        require(_id < candidates.length, "Ung vien khong ton tai");
        return candidates[_id];
    }

    /// @notice Lấy toàn bộ mảng ứng viên
    /// @return Mảng chứa tất cả Candidate structs
    function getAllCandidates() public view returns (Candidate[] memory) {
        return candidates;
    }
}
