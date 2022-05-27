// contracts/GLDToken.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Meta4SwapToken is ERC20 {
    mapping(address => bool) public marketplaces;
    address public dao;
    address public company;

    constructor(uint256 initialSupply) ERC20("Meta4Swap", "M4S") {
        _mint(msg.sender, initialSupply);
        company = msg.sender;
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

    //update functions
    function updateMarketplaces(address _marketplace, bool _approved) public {
        require(msg.sender == company, "Only the DAO can update marketplaces");
        marketplaces[_marketplace] = _approved;
    }

    function updateAddress(uint256 _value, address _newAddress) public {
        require(msg.sender == company, "Only company can change address");
        if (_value == 0) {
            //Company Address
            company = _newAddress;
        } else if (_value == 1) {
            //DAO Address
            dao = _newAddress;
        }
    }
}
