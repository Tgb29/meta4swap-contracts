// contracts/GLDToken.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

//deploy this contract first

contract Meta4SwapToken is ERC20 {
    mapping(address => bool) public marketplaces;
    address public admin;

    constructor(uint256 initialSupply) ERC20("Meta4Swap", "M4S") {
        _mint(msg.sender, initialSupply);
        admin = msg.sender;
    }

    //only marketplaces can mint
    function mintReward(address _receiver, uint256 _rewardRate)
        public
        returns (bool)
    {
        if (marketplaces[msg.sender] == true) {
            _mint(_receiver, _rewardRate);
        }
        return true;
    }

    function burn(address _redeemer, uint256 _amount) public returns (bool) {
        _burn(_redeemer, _amount);
        return true;
    }

    //This enables Meta4Swap.sol to call functions in this contract
    function updateMarketplaces(address _marketplace, bool _approved) public {
        require(msg.sender == admin, "Only the admin can update marketplaces");
        marketplaces[_marketplace] = _approved;
    }

    function updateAdmin(address _newAddress) public {
        require(msg.sender == admin, "Only admin can change address");
        admin = _newAddress;
    }
}
