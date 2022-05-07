// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract Meta4Swap {
    uint256 public itemCount = 0;
    uint256 public orderCount = 0;
    uint256 public disputeCount = 0;

    //marketplace variables

    address owner;
    uint256 earnings;
    uint256 fee; //percentage
    uint256 disputeWindow; //window for dispute voting
    uint256 voteThreshold; //number of votes needed for dispute
    uint256 minFee; // the minimum order size to earn rewards

    struct Item {
        uint256 id;
        string metadata;
        bool isLive;
        uint256 price;
        address owner;
        uint256 ratingSum;
        uint256 ratingCount;
    }

    struct Order {
        uint256 id;
        uint256 itemId;
        uint256[] paymentInfo;
        uint8[] state;
        address[] counterparts;
        bool isLive;
        uint256 created;
    }

    struct Dispute {
        string buyerResponse;
        string sellerResponse;
        uint256 buyerVotes;
        uint256 sellerVotes;
        uint256 created;
        bool isLive;
        uint8 winner;
    }

    struct Profile {
        uint256 cancelled;
        uint256 disputeWin;
        uint256 disputeLose;
        uint256 ratingSum;
        uint256 ratingCount;
        uint256 completed;
        uint256 earnings;
        uint256 paid;
    }

    // itemId to Item struct mapping
    mapping(uint256 => Item) public itemInfo;

    // orderId to Order struct mapping
    mapping(uint256 => Order) public orderInfo;

    //orderId to Dispute struct mapping
    mapping(uint256 => Dispute) public disputeInfo;

    //vote check
    mapping(address => mapping(uint256 => bool)) voteCheck;

    //user to Profile struct mapping
    mapping(address => Profile) public userProfile;

    //rating check
    mapping(address => mapping(uint256 => bool)) ratingCheck;

    AggregatorV3Interface internal priceFeed;

    constructor() {
        priceFeed = AggregatorV3Interface(
            0x8A753747A1Fa494EC906cE90E9f37563A8AF630e
        );
        fee = 2500000000000000000;
        disputeWindow = 45500;
        minFee = 5000000000000000000;
        voteThreshold = 5;
    }

    event ItemCreated(uint256 _itemId);
    event ItemUpdated(uint256 _itemId);
    event OrderCreated(uint256 _orderId);
    event OrderUpdated(uint256 _orderId);
    event DisputeCreated(uint256 _orderId);
    event DisputeUpdated(uint256 _orderId);
    event RatingUpdated(
        address _rater,
        address _ratee,
        uint256 _rating,
        uint256 _orderId
    );

    modifier onlyCounterpart(uint256 _orderId) {
        require(
            orderInfo[_orderId].counterparts[0] == msg.sender ||
                orderInfo[_orderId].counterparts[1] == msg.sender,
            "Not authorized. Buyer or Seller only."
        );
        _;
    }

    modifier onlyOwner() {
        require(owner == msg.sender);
        _;
    }

    function createItem(
        string memory _metadata,
        bool _live,
        uint256 _price
    ) public returns (uint256) {
        Item memory _item;
        _item.id = itemCount + 1;
        _item.metadata = _metadata;
        _item.isLive = _live;
        _item.price = _price;
        _item.owner = msg.sender;

        itemInfo[_item.id] = _item;

        itemCount += 1;

        emit ItemCreated(_item.id);

        return _item.id;
    }

    function createOrder(uint256 _itemId, uint8 _qty)
        public
        payable
        returns (uint256)
    {
        require(
            itemInfo[_itemId].isLive == true,
            "Item not for sale or doesn't exist."
        );

        Order memory _order;

        _order.paymentInfo[0] = uint256(getLatestPrice());

        uint256 total = (fee *
            ((itemInfo[_itemId].price / _order.paymentInfo[0]) * _qty)) +
            ((itemInfo[_itemId].price / _order.paymentInfo[0]) * _qty);

        require(msg.value >= total, "Amount paid is less than total");

        _order.id = orderCount + 1;
        _order.itemId = _itemId;
        _order.paymentInfo[1] = msg.value; //amountPaid
        _order.paymentInfo[2] = _qty; // quantityOrdered
        _order.paymentInfo[3] = itemInfo[_itemId].price; //item price at time of order
        _order.isLive = true;
        _order.counterparts[0] = msg.sender; //buyer address
        _order.counterparts[1] = itemInfo[_itemId].owner; //seller address
        _order.created = block.number;

        orderInfo[_order.id] = _order;
        orderCount += 1;

        if (msg.value > total) {
            // add safe math here
            //send refund back to the user
            payable(msg.sender).call{value: (msg.value - total)};
        }

        emit OrderCreated(_order.id);

        return _order.id;
    }

    //changing order states

    function complete(uint256 _orderId) public onlyCounterpart(_orderId) {
        require(orderInfo[_orderId].isLive == true, "Order isn't active");

        if (msg.sender == orderInfo[_orderId].counterparts[0]) {
            orderInfo[_orderId].state[0] = 1;
        } else if (msg.sender == orderInfo[_orderId].counterparts[1]) {
            orderInfo[_orderId].state[1] = 1;
        }

        if (
            orderInfo[_orderId].state[0] == 1 &&
            orderInfo[_orderId].state[1] == 1
        ) {
            orderInfo[_orderId].isLive == false;
            payable(orderInfo[_orderId].counterparts[1]).call{
                value: (orderInfo[_orderId].paymentInfo[1] -
                    (orderInfo[_orderId].paymentInfo[1] * fee))
            };
            earnings += orderInfo[_orderId].paymentInfo[1] * fee;
            orderInfo[_orderId].paymentInfo[4] = fee;

            userProfile[orderInfo[_orderId].counterparts[0]].completed += 1;
            userProfile[orderInfo[_orderId].counterparts[0]].paid += orderInfo[
                _orderId
            ].paymentInfo[1];

            userProfile[orderInfo[_orderId].counterparts[1]].completed += 1;
            userProfile[orderInfo[_orderId].counterparts[1]].earnings +=
                (orderInfo[_orderId].paymentInfo[1]) -
                (orderInfo[_orderId].paymentInfo[1] * fee);
        }

        emit OrderUpdated(_orderId);
    }

    function cancel(uint256 _orderId) public {
        require(
            msg.sender == orderInfo[_orderId].counterparts[1],
            "Only seller can cancel"
        );
        require(orderInfo[_orderId].isLive == true, "Order isn't active");
        orderInfo[_orderId].state[1] = 2;
        orderInfo[_orderId].state[0] = 2;
        orderInfo[_orderId].isLive = false;

        userProfile[orderInfo[_orderId].counterparts[1]].cancelled += 1;

        payable(orderInfo[_orderId].counterparts[0]).call{
            value: orderInfo[_orderId].paymentInfo[1]
        };

        emit OrderUpdated(_orderId);
    }

    //disputes

    function dispute(uint256 _orderId) public onlyCounterpart(_orderId) {
        require(orderInfo[_orderId].isLive == true, "Order isn't active");
        orderInfo[_orderId].state[1] = 3;
        orderInfo[_orderId].state[0] = 3;
        orderInfo[_orderId].isLive = false;

        Dispute memory _dispute;
        _dispute.created = block.number;
        _dispute.isLive = true;

        disputeInfo[_orderId] = _dispute;

        emit DisputeCreated(_orderId);
    }

    function updateDispute(uint256 _orderId, string memory _ipfsHash)
        public
        onlyCounterpart(_orderId)
    {
        require(disputeInfo[_orderId].isLive == true, "Dispute isn't live");
        if (msg.sender == orderInfo[_orderId].counterparts[0]) {
            disputeInfo[_orderId].buyerResponse = _ipfsHash;
        } else if (msg.sender == orderInfo[_orderId].counterparts[1]) {
            disputeInfo[_orderId].sellerResponse = _ipfsHash;
        }

        emit DisputeUpdated(_orderId);
    }

    function vote(uint256 _orderId, uint256 _vote) public {
        require(disputeInfo[_orderId].isLive == true, "Dispute isn't live");
        require(voteCheck[msg.sender][_orderId] == false, "User already voted");

        //add logic so only users with gov tokens can vote

        //buyer == 0
        if (_vote == 0) {
            disputeInfo[_orderId].buyerVotes += 1;
        }
        //seller == 1
        else if (_vote == 1) {
            disputeInfo[_orderId].sellerVotes += 1;
        }

        voteCheck[msg.sender][_orderId] == true;
    }

    function resolve(uint256 _orderId) public {
        require(
            disputeInfo[_orderId].isLive == true,
            "Dispute isn't live or is already resolved."
        );
        require(
            disputeInfo[_orderId].buyerVotes +
                disputeInfo[_orderId].sellerVotes >
                voteThreshold,
            "Not enough votes"
        );
        require(
            (block.number - disputeInfo[_orderId].created) > disputeWindow,
            "Window for voting still open"
        );
        require(
            disputeInfo[_orderId].buyerVotes !=
                disputeInfo[_orderId].sellerVotes,
            "Voting can't end in tie"
        );

        if (
            disputeInfo[_orderId].buyerVotes > disputeInfo[_orderId].sellerVotes
        ) {
            //transfer money back to buyer
            payable(orderInfo[_orderId].counterparts[0]).call{
                value: orderInfo[_orderId].paymentInfo[1]
            };

            userProfile[orderInfo[_orderId].counterparts[0]].disputeWin += 1;
            userProfile[orderInfo[_orderId].counterparts[1]].disputeLose += 1;
        } else {
            //transfer money to selller
            payable(orderInfo[_orderId].counterparts[1]).call{
                value: (orderInfo[_orderId].paymentInfo[1] -
                    (orderInfo[_orderId].paymentInfo[1] * fee))
            };
            earnings += orderInfo[_orderId].paymentInfo[1] * fee;
            userProfile[orderInfo[_orderId].counterparts[0]].disputeLose += 1;
            userProfile[orderInfo[_orderId].counterparts[1]].disputeWin += 1;
        }

        orderInfo[_orderId].state[1] = 4;
        orderInfo[_orderId].state[1] = 4;

        disputeInfo[_orderId].isLive = false;

        emit DisputeUpdated(_orderId);
    }

    //edit Protocol

    function editRules(uint256 _variable, uint256 _value) public onlyOwner {
        if (_variable == 0) {
            //edit fee
            fee = _value;
        } else if (_variable == 1) {
            //edit disputeWindow
            disputeWindow = _value;
        } else if (_variable == 2) {
            voteThreshold = _value;
        } else if (_variable == 3) {
            voteThreshold = _value;
        }
    }

    function transferOwner(address _newOwner) public onlyOwner {
        owner = _newOwner;
    }

    //rate order
    function rate(uint256 _orderId, uint8 _rating)
        public
        onlyCounterpart(_orderId)
    {
        require(_rating > 0 && _rating < 6, "rating needs to be between 1-5");
        require(
            ratingCheck[msg.sender][_orderId] = false,
            "Rating already left"
        );

        if (msg.sender == orderInfo[_orderId].counterparts[0]) {
            itemInfo[orderInfo[_orderId].itemId].ratingSum += _rating;
            itemInfo[orderInfo[_orderId].itemId].ratingCount += 1;
            userProfile[orderInfo[_orderId].counterparts[1]]
                .ratingSum += _rating;
            userProfile[orderInfo[_orderId].counterparts[1]].ratingCount += 1;
            ratingCheck[msg.sender][_orderId] = true;
            emit RatingUpdated(
                msg.sender,
                orderInfo[_orderId].counterparts[1],
                _rating,
                _orderId
            );
        } else if (msg.sender == orderInfo[_orderId].counterparts[1]) {
            userProfile[orderInfo[_orderId].counterparts[0]]
                .ratingSum += _rating;
            userProfile[orderInfo[_orderId].counterparts[0]].ratingCount += 1;
            ratingCheck[msg.sender][_orderId] = true;
            emit RatingUpdated(
                msg.sender,
                orderInfo[_orderId].counterparts[0],
                _rating,
                _orderId
            );
        }
    }

    //edit Item
    function editPrice(uint256 _itemId, uint256 _value) public {
        require(
            msg.sender == itemInfo[_itemId].owner,
            "Only item owner can edit"
        );

        itemInfo[_itemId].price = _value;
    }

    function editMeta(uint256 _itemId, string memory _metadata) public {
        require(
            msg.sender == itemInfo[_itemId].owner,
            "Only item owner can edit"
        );

        itemInfo[_itemId].metadata = _metadata;
    }

    function editState(uint256 _itemId, bool _isLive) public {
        require(
            msg.sender == itemInfo[_itemId].owner,
            "Only item owner can edit"
        );

        itemInfo[_itemId].isLive = _isLive;
    }

    function getLatestPrice() public view returns (int256) {
        (
            ,
            /*uint80 roundID*/
            int256 price, /*uint startedAt*/ /*uint timeStamp*/ /*uint80 answeredInRound*/
            ,
            ,

        ) = priceFeed.latestRoundData();
        return price;
    }
}
