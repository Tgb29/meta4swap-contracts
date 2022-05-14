// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface Meta4SwapToken {
    function burn(address _address, uint256 _amount) external returns (bool);

    function balanceOf(address _address) external returns (uint256);

    function totalSupply() external returns (uint256);
}

contract Meta4SwapDAO {
    address public m4sToken;
    uint256 public proposalCount;

    constructor(address _address) {
        m4sToken = _address;
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

    function createProposalB(uint256 _variable, uint256 _value) public {
        //require token balance > X
        //change fee
        //change disputeWindow
        //change voteThreshold
        //change minFee for reward minting
        //change rewardRates for buyer,seller, company
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
