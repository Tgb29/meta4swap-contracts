// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface Meta4SwapToken {
    function burn(address _address, uint256 _amount) external returns (bool);
}

contract Meta4SwapDAO {
    Meta4SwapToken m4s;

    uint256 public proposalCount;

    constructor(address _address) {
        m4s = Meta4SwapToken(_address);
    }

    //for any token holder to use
    function redeem(uint256 _amount) public {
        m4s.burn(msg.sender, _amount);
        //based on reserve value, burn tokens and transfer earnings
    }

    function createProposalA() public {
        //require token balance > X

        //change owner
        //change marketplace

        proposalCount += 1;
    }

    function createProposalB(uint256 _variable, uint256 _value) public {
        //require token balance > X

        //change fee
        //change disputeWindow
        //change voteThreshold
        //change minFee for reward minting
        //change rewardRates for buyer,seller, company

        proposalCount += 1;
    }

    function createProposalC(uint256 _variable, uint256 _value) public {
        //require token balance > X

        //tokenThreshold to create proposals
        //min votes needed for proposal to pass
        //proposal Window

        proposalCount += 1;
    }

    function voteProposal() public {}

    function executeProposal() public {}
}
