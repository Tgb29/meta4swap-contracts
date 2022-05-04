// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract Meta4Swap {
    uint256 public itemCount = 0;
    uint256 public orderCount = 0;

    //fee percentage for every order
    uint256 fee;

    struct Item {
        uint256 id;
        string metadata;
        uint256 quantity;
        bool isLive;
        uint256 price;
        uint256 unit;
        uint256 rating;
        address owner;
    }

    struct Order {
        uint256 id;
        uint256 itemId;
        uint256 amountPaid;
        uint256 quantityOrdered;
        uint256 ppu;
        uint256 exchangeRate;
        uint256 buyerState;
        uint256 sellerState;
        bool isLive;
        address buyer;
    }

    constructor(uint256 _fee) {
        fee = _fee;
    }

    // Owner to itemId[] mapping
    mapping(address => uint256[]) public myItems;
    // itemId to Item struct mapping
    mapping(uint256 => Item) public itemInfo;
    // Array of all items created
    uint256[] public items;

    // orderId to Order struct mapping
    mapping(uint256 => Order) public orderInfo;







    function createItem(
        string memory _metadata,
        bool _live,
        uint256 _price,
        uint256 _unit,
        uint256 _rating
    ) public returns (uint256) {
        Item memory _item;
        _item.id = itemCount + 1;
        _item.metadata = _metadata;
        _item.isLive = _live;
        _item.price = _price;
        _item.unit = _unit;
        _item.owner = msg.sender;

        myItems[msg.sender].push(_item.id);
        itemInfo[_item.id] = _item;
        items.push(_item.id);

        itemCount += 1;

        return _item.id;
    }

    function createOrder(uint256 _itemId, uint256 _qtyOrdered)
        public
        payable
        returns (uint256)
    {
        require(itemInfo[_itemId].isLive == true, "Item not for sale");

        uint256 chainLinkPrice; //call chain link node here
        uint256 orderPrice = itemInfo[_itemId].price *
            chainLinkPrice *
            _qtyOrdered;
        uint256 total = (fee * orderPrice) + orderPrice;

        require(msg.value >= total, "Amount paid is less than total");

        Order memory _order;
        _order.id = orderCount + 1;
        _order.itemId = _itemId;
        _order.amountPaid = msg.value;
        _order.quantityOrdered = _qtyOrdered;
        _order.ppu = itemInfo[_itemId].price * chainLinkPrice;
        _order.exchangeRate = chainLinkPrice;
        _order.buyerState = 0;
        _order.sellerState = 0;
        _order.isLive = true;
        _order.buyer = msg.sender;

        orderCount += 1;

        if (msg.value > total) {
            uint256 cashBack = msg.value - total;
            //send refund back to the user
            payable(msg.sender).call{value: cashBack};
        }

        return orderCount;
    }

    //changing order states

    //0 == active
    //1 == complete
    //2 = counter
    //3 == update
    //4 == cancel
    //5 == dispute

    function complete(uint256 _orderId) public {
        require(orderInfo[_orderId].isLive == true, "Order no longer active");
        require(orderInfo[_orderId].buyerState != 5, "Order in dispute");
        require(orderInfo[_orderId].buyer == msg.sender || )

        

    }

    //require that order is active and not in dispute
    //if buyer and seller are both state complete, end order and pay
    //

    function counter(uint256 _orderId) public {}

    function dispute(uint256 _orderId) public {}

    function update(uint256 _orderId) public {}

    function cancel(uint256 _orderId) public {}

    //arbitration

    function vote(uint256 _orderId) public {}

    function resolve(uint256 _orderId) public {}

    //edit Protocol

    //edit fee
    function editRules() public {}

    //other actions

    //rate order
    function rate() public {}
    //mint token for dao

    //edit order
    function editItem() public {}
}
