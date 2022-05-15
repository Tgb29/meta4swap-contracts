// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface Meta4SwapToken {
    function burn(address _address, uint256 _amount) external returns (bool);

    function balanceOf(address account) external view returns (uint256);

    function totalSupply() external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

interface Meta4Swap {
    function updateRules(uint256 _variable, uint256 _value)
        external
        returns (bool);
}

contract Meta4SwapDAO {
    address public m4sToken;
    address public m4s;
    address public company;

    uint256 public proposalCount;

    uint256 public proposalThreshold; //tokens needed to submit proposal
    uint256 public proposalWindow;
    uint256 public votingThreshold; // total votes needed to pass

    struct Proposal {
        uint256 id;
        uint256 yesVotes;
        uint256 noVotes;
        uint256 created;
        bool passed;
        bool isLive;
        address proposer;
        uint256[2] proposition;
    }

    struct Vote {
        bool voted;
        uint256 votes;
        bool withdrawn;
    }

    mapping(uint256 => Proposal) proposals;
    mapping(address => mapping(uint256 => Vote)) voteHistory;

    event ProposalCreated(address _creator, uint256 _proposalId);

    constructor() {
        company = msg.sender;
        proposalWindow = 45500;
        proposalThreshold = 1 ether;
        votingThreshold = 1 ether;
    }

    //for any token holder to use
    function redeem(uint256 _amount) public {
        require(
            Meta4SwapToken(m4sToken).balanceOf(msg.sender) >= _amount,
            "User balance too low"
        );
        payable(msg.sender).call{
            value: (address(this).balance /
                Meta4SwapToken(m4sToken).totalSupply()) * _amount
        };
        Meta4SwapToken(m4sToken).burn(msg.sender, _amount);
    }

    function createProposal(uint256 _variable, uint256 _value)
        public
        returns (uint256)
    {
        require(
            Meta4SwapToken(m4sToken).balanceOf(msg.sender) > proposalThreshold,
            "User doesn't have enough tokens"
        );

        Proposal memory _proposal;
        _proposal.id = proposalCount + 1;
        _proposal.proposer = msg.sender;
        _proposal.proposition = [_variable, _value];
        _proposal.created = block.number;
        _proposal.isLive = true;

        proposalCount += 1;

        emit ProposalCreated(msg.sender, _proposal.id);

        return _proposal.id;
    }

    function voteProposal(
        uint256 _proposalId,
        bool _support,
        uint256 _amount
    ) public {
        require(
            Meta4SwapToken(m4sToken).balanceOf(msg.sender) >= _amount,
            "User doesn't have enough tokens"
        );
        require(proposals[_proposalId].isLive == true, "Proposal not live");
        require(
            block.number - proposals[_proposalId].created < proposalWindow,
            "Window closed"
        );

        Meta4SwapToken(m4sToken).transferFrom(
            msg.sender,
            address(this),
            _amount
        );

        Vote memory _vote;
        _vote.voted = true;
        _vote.votes = _amount;
        voteHistory[msg.sender][_proposalId] = _vote;

        if (_support) {
            proposals[_proposalId].yesVotes = _amount;
        } else {
            proposals[_proposalId].noVotes = _amount;
        }
    }

    function withdrawVotes(uint256 _proposalId) public {
        require(
            proposals[_proposalId].isLive == false,
            "Voting not closed yet"
        );
        require(
            voteHistory[msg.sender][_proposalId].voted == true,
            "User didn't vote on this proposal"
        );
        require(
            voteHistory[msg.sender][_proposalId].withdrawn == false,
            "User already withdrew"
        );

        Meta4SwapToken(m4sToken).transfer(
            msg.sender,
            voteHistory[msg.sender][_proposalId].votes
        );
        voteHistory[msg.sender][_proposalId].votes = 0;
        voteHistory[msg.sender][_proposalId].withdrawn = true;
    }

    function executeProposal(uint256 _proposalId) public {
        require(
            proposals[_proposalId].isLive == true,
            "Proposal already executed"
        );
        require(
            block.number - proposals[_proposalId].created > proposalWindow,
            "Window still open"
        );

        if (
            proposals[_proposalId].yesVotes + proposals[_proposalId].noVotes >
            votingThreshold &&
            proposals[_proposalId].yesVotes > proposals[_proposalId].noVotes
        ) {
            proposals[_proposalId].passed = true;
            Meta4Swap(m4s).updateRules(
                proposals[_proposalId].proposition[0],
                proposals[_proposalId].proposition[1]
            );
        }

        proposals[_proposalId].isLive = false;
    }

    //Company controls
    function updateAddress(uint256 _value, address _newAddress) public {
        require(msg.sender == company, "Only company can change address");
        if (_value == 0) {
            //Company Address
            company = _newAddress;
        } else if (_value == 1) {
            //Meta4Swap Address
            m4s = _newAddress;
        } else if (_value == 2) {
            //Meta4Swap Token Address
            m4sToken = _newAddress;
        }
    }
}
