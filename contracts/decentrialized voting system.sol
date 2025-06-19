// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title DecentralizedVotingSystem
 * @dev A smart contract for conducting transparent and secure voting
 */
contract DecentralizedVotingSystem {
    
    // Struct to represent a candidate
    struct Candidate {
        string name;
        uint256 voteCount;
    }
    
    // Struct to represent a voter
    struct Voter {
        bool isRegistered;
        bool hasVoted;
    }
    
    // State variables
    address public owner;
    bool public votingActive;
    uint256 public totalVotes;
    uint256 public candidateCount;
    
    // Mappings
    mapping(uint256 => Candidate) public candidates;
    mapping(address => Voter) public voters;
    
    // Events
    event VoterRegistered(address voter);
    event VoteCast(address voter, uint256 candidateId);
    event CandidateAdded(string name);
    
    // Modifiers
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner allowed");
        _;
    }
    
    modifier votingIsActive() {
        require(votingActive, "Voting not active");
        _;
    }
    
    /**
     * @dev Constructor
     */
    constructor() {
        owner = msg.sender;
        votingActive = false;
    }
    
    /**
     * @dev Core Function 1: Register a voter
     */
    function registerVoter(address _voter) public onlyOwner {
        require(!votingActive, "Cannot register during voting");
        require(!voters[_voter].isRegistered, "Already registered");
        
        voters[_voter].isRegistered = true;
        emit VoterRegistered(_voter);
    }
    
    /**
     * @dev Core Function 2: Cast a vote
     */
    function castVote(uint256 _candidateId) public votingIsActive {
        require(voters[msg.sender].isRegistered, "Not registered");
        require(!voters[msg.sender].hasVoted, "Already voted");
        require(_candidateId > 0 && _candidateId <= candidateCount, "Invalid candidate");
        
        voters[msg.sender].hasVoted = true;
        candidates[_candidateId].voteCount++;
        totalVotes++;
        
        emit VoteCast(msg.sender, _candidateId);
    }
    
    /**
     * @dev Core Function 3: Get results
     */
    function getResults() public view returns (string[] memory names, uint256[] memory votes) {
        names = new string[](candidateCount);
        votes = new uint256[](candidateCount);
        
        for (uint256 i = 1; i <= candidateCount; i++) {
            names[i-1] = candidates[i].name;
            votes[i-1] = candidates[i].voteCount;
        }
    }
    
    /**
     * @dev Add candidate
     */
    function addCandidate(string memory _name) public onlyOwner {
        require(!votingActive, "Cannot add during voting");
        require(bytes(_name).length > 0, "Name required");
        
        candidateCount++;
        candidates[candidateCount] = Candidate(_name, 0);
        emit CandidateAdded(_name);
    }
    
    /**
     * @dev Start voting
     */
    function startVoting() public onlyOwner {
        require(!votingActive, "Already active");
        require(candidateCount > 0, "No candidates");
        votingActive = true;
    }
    
    /**
     * @dev End voting
     */
    function endVoting() public onlyOwner {
        require(votingActive, "Not active");
        votingActive = false;
    }
}
