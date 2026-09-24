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

    /// @notice CÃ i Ä‘áº·t Ä‘á»‹a chá»‰ cho Voting Core contract
    /// @param _coreAddress Äá»‹a chá»‰ cá»§a VotingCore contract
    function setVotingCore(address _coreAddress) public onlyAdmin {
        votingCoreAddress = _coreAddress;
        emit CoreContractSet(_coreAddress);
    }

    /// @notice ThÃªm má»™t á»©ng viÃªn má»›i vÃ o danh sÃ¡ch
    /// @param _name TÃªn á»©ng viÃªn
    /// @param _party Äáº£ng phÃ¡i cá»§a á»©ng viÃªn
    /// @param _description MÃ´ táº£ thÃªm
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

    /// @notice Cáº­p nháº­t thÃ´ng tin cá»§a má»™t á»©ng viÃªn Ä‘Ã£ cÃ³
    /// @param _id ID cá»§a á»©ng viÃªn
    /// @param _newName TÃªn má»›i cá»§a á»©ng viÃªn
    /// @param _newParty Äáº£ng phÃ¡i má»›i
    /// @param _newDescription MÃ´ táº£ má»›i
    function updateCandidate(uint _id, string memory _newName, string memory _newParty, string memory _newDescription) public onlyAdmin candidatesNotLocked {
        require(_id < candidates.length, "Ung vien khong ton tai");
        require(candidates[_id].isActive, "Ung vien da bi xoa");

        candidates[_id].name = _newName;
        candidates[_id].party = _newParty;
        candidates[_id].description = _newDescription;

        emit CandidateUpdated(_id, _newName, _newParty);
    }

    /// @notice XÃ³a má»m má»™t á»©ng viÃªn (áº©n Ä‘i chá»© khÃ´ng xÃ³a khá»i máº£ng)
    /// @param _id ID cá»§a á»©ng viÃªn cáº§n xÃ³a
    function deleteCandidate(uint _id) public onlyAdmin candidatesNotLocked {
        require(_id < candidates.length, "Ung vien khong ton tai");
        require(candidates[_id].isActive, "Ung vien da bi xoa roi");

        candidates[_id].isActive = false;
        emit CandidateDeleted(_id);
    }

    /// @notice KhÃ³a danh sÃ¡ch á»©ng viÃªn khÃ´ng cho thao tÃ¡c ná»¯a
    /// @dev Cáº§n Ã­t nháº¥t 1 á»©ng viÃªn há»£p lá»‡ Ä‘á»ƒ khÃ³a
    function lockCandidates() public onlyAdmin candidatesNotLocked {
        require(getValidCandidatesCount() > 0, "Phai co it nhat 1 ung vien de khoa");
        candidatesLocked = true;

        emit CandidatesLocked();
    }

    /// @notice TÄƒng sá»‘ phiáº¿u báº§u cho á»©ng viÃªn (Chá»‰ dÃ nh cho Core)
    /// @param _id ID cá»§a á»©ng viÃªn
    function incrementVote(uint _id) public onlyCore {
        require(_id < candidates.length, "Ung vien khong ton tai");
        require(candidates[_id].isActive, "Ung vien khong hop le hoac bi xoa");
        candidates[_id].voteCount++;
    }

    // ==========================================
    // 8. View/pure functions
    // ==========================================

    /// @notice Äáº¿m sá»‘ lÆ°á»£ng á»©ng viÃªn há»£p lá»‡
    /// @return count Sá»‘ lÆ°á»£ng á»©ng viÃªn chÆ°a bá»‹ xÃ³a
    function getValidCandidatesCount() public view returns (uint) {
        uint count = 0;
        for (uint i = 0; i < candidates.length; i++) {
            if (candidates[i].isActive) {
                count++;
            }
        }
        return count;
    }

    /// @notice Láº¥y thÃ´ng tin cá»§a má»™t á»©ng viÃªn
    /// @param _id ID cá»§a á»©ng viÃªn
    /// @return Struct Candidate tÆ°Æ¡ng á»©ng
    function getCandidate(uint _id) public view returns (Candidate memory) {
        require(_id < candidates.length, "Ung vien khong ton tai");
        return candidates[_id];
    }

    /// @notice Láº¥y toÃ n bá»™ máº£ng á»©ng viÃªn
    /// @return Máº£ng chá»©a táº¥t cáº£ Candidate structs
    function getAllCandidates() public view returns (Candidate[] memory) {
        return candidates;
    }
}
