// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract Voting {
    struct Candidate {
        string name;
        address wallet;
        string imageUrl;
        uint256 voteCount;
    }

    address public owner;
    bool public votingOpen;

    Candidate[] public candidates;
    mapping(address => uint256) public voteCountOfAddress;
    mapping(address => bool) public isRegistered;
    mapping(address => mapping(uint256 => bool)) public hasVotedForCandidate;

    event CandidateRegistered(string name, address wallet);
    event Voted(address voter, uint256 candidateIndex);

    constructor() {
        owner = msg.sender;
        votingOpen = true;
    }

    function registerCandidate(string memory _name, string memory _imageUrl) public {
        require(votingOpen, "Voting is closed");
        require(!isRegistered[msg.sender], "Already registered");
        candidates.push(Candidate(_name, msg.sender, _imageUrl, 0));
        isRegistered[msg.sender] = true;
        emit CandidateRegistered(_name, msg.sender);
    }

    function vote(uint256 candidateIndex) public {
        require(votingOpen, "Voting is closed");
        require(voteCountOfAddress[msg.sender] < 3, "Max 3 votes allowed");
        require(!hasVotedForCandidate[msg.sender][candidateIndex], "Already voted for this candidate");
        require(candidateIndex < candidates.length, "Invalid candidate");
        candidates[candidateIndex].voteCount++;
        voteCountOfAddress[msg.sender]++;
        hasVotedForCandidate[msg.sender][candidateIndex] = true;
        emit Voted(msg.sender, candidateIndex);
    }

    function hasVoted(address voter) public view returns (bool) {
        return voteCountOfAddress[voter] >= 3;
    }

    function getCandidate(uint256 index) public view returns (string memory, address, string memory, uint256) {
        require(index < candidates.length, "Invalid candidate");
        return (candidates[index].name, candidates[index].wallet, candidates[index].imageUrl, candidates[index].voteCount);
    }

    function getCandidateCount() public view returns (uint256) {
        return candidates.length;
    }

    function toggleVoting() public {
        require(msg.sender == owner, "Only owner");
        votingOpen = !votingOpen;
    }
}
