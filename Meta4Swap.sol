// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract Meta4Swap {
    uint256 public itemCount = 0;
    uint256 public orderCount = 0;
    uint256 public disputeCount = 0;

    //marketplace variables
    //fee percentage for every order
    uint256 fee;
    uint256 disputeWindow; //window for dispute voting
    uint256 voteThreshold; //number of votes needed for dispute

    struct Item {
        uint256 id;
        string metadata;
        uint256 quantity;
        bool isLive;
        uint256 price;
        uint256 unit;
        address owner;
        uint256 ratingSum;
        uint256 ratingCount;
    }

    struct Order {
        uint256 id;
        uint256 itemId;
        uint256 amountPaid; // in crypto
        uint256 quantityOrdered;
        uint256 ppu; // in fiat
        uint256 exchangeRate; // fiat to crypto
        uint256 buyerState;
        uint256 sellerState;
        bool isLive;
        address buyer;
        address seller;
        uint256 created;
    }

    struct Dispute {
        string buyerResponse;
        string sellerResponse;
        uint256 buyerVotes;
        uint256 sellerVotes;
        uint256 created; // when dispute created
        bool isLive; // is dispute open
        uint256 winner; //who won the vote
    }

    struct Rating {
        uint256 cancelled;
        uint256 disputeWin;
        uint256 disputeLose;
        uint256 ratingSum;
        uint256 ratingCount;
    }

    // itemId to Item struct mapping
    mapping(uint256 => Item) public itemInfo;
    // Owner to itemId[] mapping
    mapping(address => uint256[]) public myItems;

    // orderId to Order struct mapping
    mapping(uint256 => Order) public orderInfo;
    // Buyer/Seller to id[] mapping
    mapping(address => uint256[]) public myOrders;

    //orderId to Dispute struct mapping
    mapping(uint256 => Dispute) public disputeInfo;
    // Buyer/Seller to id[] mapping
    mapping(address => uint256[]) public myDisputes;

    constructor(uint256 _fee) {
        fee = _fee;
    }

    modifier onlyCounterpart(uint256 _orderId) {
        require(
            orderInfo[_orderId].buyer == msg.sender ||
                orderInfo[_orderId].seller == msg.sender,
            "Not authorized. Buyer or Seller only."
        );
        _;
    }

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
        _order.seller = itemInfo[_itemId].owner;
        _order.created = block.number;

        orderInfo[_order.id] = _order;
        myOrders[_order.buyer].push(_order.id);
        myOrders[_order.seller].push(_order.id);
        orderCount += 1;

        if (msg.value > total) {
            // add safe math here
            uint256 cashBack = msg.value - total;
            //send refund back to the user
            payable(msg.sender).call{value: cashBack};
        }

        return orderCount;
    }

    //changing order states

    function complete(uint256 _orderId) public onlyCounterpart(_orderId) {
        require(orderInfo[_orderId].isLive == true, "Order isn't active");

        if (msg.sender == orderInfo[_orderId].buyer) {
            orderInfo[_orderId].buyerState = 1;
        } else if (msg.sender == orderInfo[_orderId].seller) {
            orderInfo[_orderId].sellerState = 1;
        }

        if (
            orderInfo[_orderId].buyerState == 1 &&
            orderInfo[_orderId].sellerState == 1
        ) {
            orderInfo[_orderId].isLive == false;
            payable(orderInfo[_orderId].seller).call{
                value: orderInfo[_orderId].amountPaid
            };
        }
    }

    function cancel(uint256 _orderId) public {
        require(
            msg.sender == orderInfo[_orderId].seller,
            "Only seller can cancel"
        );
        // only seller can cancel
        //if someone cancels, both states go to cancel
    }

    //disputes

    function dispute(uint256 _orderId) public onlyCounterpart(_orderId) {
        require(orderInfo[_orderId].isLive == true, "Order isn't active");
        orderInfo[_orderId].sellerState = 3;
        orderInfo[_orderId].buyerState = 3;
        orderInfo[_orderId].isLive = false;

        Dispute memory _dispute;
        _dispute.created = block.number;
        _dispute.isLive = true;

        disputeInfo[_orderId] = _dispute;
        myDisputes[orderInfo[_orderId].buyer].push(_orderId);
        myDisputes[orderInfo[_orderId].seller].push(_orderId);

        //emit dispute event
    }

    function updateDispute(uint256 _orderId) public onlyCounterpart(_orderId) {
        //buyer or seller to update their positions
    }

    function vote(uint256 _orderId) public {
        require(disputeInfo[_orderId].isLive == true, "Dispute isn't live");
        //if min threshold isn't reached, ignore vote window and keep dispute open
    }

    function resolve(uint256 _orderId) public {
        require(disputeInfo[_orderId].isLive == true, "Dispute isn't live");
        //if min threshold is reached and window is closed, end.
    }

    //edit Protocol

    function editRules() public {
        //edit fee
        //edit disputeWindow
        //edit voteThreshold
    }

    //other actions

    //rate order
    function rate(uint256 _orderId) public onlyCounterpart(_orderId) {
        //buyer or seller rate the order
    }

    //mint token for dao

    //edit Item
    function editItem(uint256 _itemId) public {
        require(
            msg.sender == itemInfo[_itemId].owner,
            "Only item owner can edit"
        );
        //change price or state of the order
    }
}
