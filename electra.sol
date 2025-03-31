// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract HederaVoterRegistry {
    address public admin;
    
    struct Voter {
        bool isRegistered;
        bytes32 voterId; // A hashed unique identifier for voter
        bytes solanaCredential; // Credential linking to Solana voting
    }
    
    mapping(address => Voter) private voters;
    
    event VoterRegistered(address indexed voter, bytes32 voterId, uint256 timestamp);
    event VoterReset(address indexed voter, uint256 timestamp);
    event SolanaCredentialIssued(address indexed voter, bytes solanaCredential);

    constructor() {
        admin = msg.sender; // Set contract deployer as admin
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action");
        _;
    }

    // Function to register a voter
    function registerVoter(address _voter, bytes32 _voterId, bytes calldata _solanaCredential) external onlyAdmin {
        require(!voters[_voter].isRegistered, "Voter already registered");

        voters[_voter] = Voter(true, _voterId, _solanaCredential);
        
        emit VoterRegistered(_voter, _voterId, block.timestamp);
        emit SolanaCredentialIssued(_voter, _solanaCredential);
    }

    // Function to check voter registration status
    function isRegistered(address _voter) external view returns (bool) {
        return voters[_voter].isRegistered;
    }

    // Function to retrieve Solana credential
    function getSolanaCredential(address _voter) external view returns (bytes memory) {
        require(voters[_voter].isRegistered, "Voter not registered");
        return voters[_voter].solanaCredential;
    }

    // Admin-only function to reset a voter's registration
    function resetVoter(address _voter) external onlyAdmin {
        require(voters[_voter].isRegistered, "Voter not registered");
        delete voters[_voter];
        emit VoterReset(_voter, block.timestamp);
    }
}