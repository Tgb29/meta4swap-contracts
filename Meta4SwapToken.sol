// contracts/GLDToken.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Meta4SwapToken is ERC20 {
    mapping(address => bool) public marketplaces;
    address public dao;

    constructor(uint256 initialSupply, address _dao) ERC20("Meta4Swap", "M4S") {
        _mint(msg.sender, initialSupply);
        dao = _dao;
    }

    //only marketplaces can mint
    function mintReward(
        address _buyer,
        address _seller,
        address _company,
        uint256[] _rewardRates
    ) public {
        if (marketplaces[msg.sender] == true) {
            _mint(_buyer, _rewardRates[0]);
            _mint(_seller, _rewardRates[1]);
            _mint(_company, _rewardRates[2]);
        } else {}
    }

    function updateMarketplaces(address _marketplace, bool _approved) {
        require(msg.sender == dao, "Only the DAO can update marketplaces");
        marketplaces[_marketplace] = _approved;
    }

    function updateDao(address _marketplace, bool _approved) {
        require(msg.sender == dao, "Only the DAO can replace itself.");
        dao = _dao;
    }

    function redeem(address _redeemer, uint256 _amount) public {
        require(msg.sender == dao, "Only the DAO can call call redeem.");
        _burn(_amount);
    }
}
