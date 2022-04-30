// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract Meta4Swap {
    uint256 public itemCount = 0;

    struct Item {
        uint256 id;
        string metadata;
        uint256 quantity;
        bool live;
        uint256 price;
        bool hourly;
        uint256 rating;
        address owner;
    }

    mapping(uint256 => address) public itemOwner;
    mapping(address => uint256[]) public myItems;
    mapping(uint256 => Item) public itemInfo;
    uint256[] public items;

    function createItem(
        string memory _metadata,
        uint256 _quantity,
        bool _live,
        uint256 _price,
        bool _hourly,
        uint256 _rating
    ) public {
        Item memory _item;
        _item.id = itemCount + 1;
        _item.metadata = _metadata;
        _item.quantity = _quantity;
        _item.live = _live;
        _item.price = _price;
        _item.hourly = _hourly;
        _item.owner = msg.sender;

        itemInfo[_item.id] = _item;
        items.push(_item.id);
        myItems[msg.sender].push(_item.id);

        return;
    }
}
