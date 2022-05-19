// contracts/GLDToken.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Meta4SwapToken is ERC20 {
    mapping(address => bool) public marketplaces;
    address public dao;

    constructor(uint256 initialSupply, address _dao) ERC20("Meta4Swap", "M4S") {
        _mint(msg.sender, initialSupply);
        //dao is company on contract launch
        dao = _dao;
    }

    //only marketplaces can mint
    function mintReward(
        address _buyer,
        address _seller,
        address _company,
        uint256[] calldata _rewardRates
    ) public returns (bool) {
        if (marketplaces[msg.sender] == true) {
            _mint(_buyer, _rewardRates[0]);
            _mint(_seller, _rewardRates[1]);
            _mint(_company, _rewardRates[2]);
        }
        return true;
    }

    function burn(address _redeemer, uint256 _amount) public returns (bool) {
        require(msg.sender == dao, "Only the DAO can burn.");
        _burn(_redeemer, _amount);
        return true;
    }

    //update functions
    function updateMarketplaces(address _marketplace, bool _approved) public {
        require(msg.sender == dao, "Only the DAO can update marketplaces");
        marketplaces[_marketplace] = _approved;
    }

    function updateDao(address _newDao) public {
        require(msg.sender == dao, "Only the DAO can replace itself.");
        dao = _newDao;
    }
}
