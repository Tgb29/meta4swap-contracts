// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract Invoices {

    uint256 public invoiceCount;
    uint256 public fee; //2.5 == 250
    
    //admin
    address public admin;
    address public priceFeed;

    struct Invoice {
        string metadata;
        bool status;
        uint256 price;
        uint256 oraclePrice;
        uint256 created;
        uint256 paid;
        address creator;
    }

    mapping(uint256 => Invoice) public invoices; // invoice id to invoice data

    constructor(address _priceFeed) {
        fee = 100;
        priceFeed = _priceFeed;
    }

    event InvoiceCreated(
        uint256 invoiceId,
        address creator,
        string metadata
    );
    event InvoiceUpdated(
        uint256 invoiceId
    );
    event InvoicePaid(
        uint256 invoiceId
    );

    modifier onlyCreator(uint256 _invoiceId) {
        require(
            invoices[_invoiceId].creator == msg.sender ,
            "Not authorized. Creator only."
        );
        _;
    }

    function create(
        string memory _metadata,
        uint256 _price
    ) public returns (uint256) {

        invoiceCount++;

        Invoice memory _invoice;

        _invoice.metadata = _metadata;
        _invoice.price = _price;
        _invoice.creator = msg.sender;
        _invoice.status = true;
        _invoice.created = block.number;

        invoice[invoiceCount] = _invoice;

        emit InvoiceCreated(
            invoiceCount,
            _invoice.creator,
            _invoice.metadata
        );

        return invoiceCount;
    }

    function pay(uint256 _invoiceId)
        public
        payable
    {
        require(
            invoices[_invoiceId].status == true,
            "Invoice not open."
        );


        invoices[_invoiceId].oraclePrice = uint256(getLatestPrice());

        uint256 invoiceTotal = ((invoices[_invoiceId].price / invoices[_invoiceId].oraclePrice) *
            10**8);
        uint256 invoiceFee = (fee * invoiceTotal) / 10000;

        require(msg.value >= invoiceTotal, "Amount paid is less than total");

        _invoice.paid = block.number;
        _invoice.status = false;
        

        if (msg.value > invoiceTotal) {
            //send refund back to the user
            (bool sent,) = msg.sender.call{
                value: (msg.value - invoiceTotal)
            }("");
            require(sent, "Failed to Send Ether");
        }

        emit InvoicePaid(
            _invoiceId
        );

        //add forwarding payment to creator
        //better way to know if invoice is paid other than status being true or false

    }


    //DAO controls
    function updateRules(uint256 _variable, uint256 _value)
        public
        returns (bool)
    {
        require(dao == msg.sender);
        if (_variable == 0) {
            //edit fee
            marketplaceFee = _value;
        } 

        return true;
    }

    //Admin controls
    function updateAddress(uint256 _value, address _newAddress) public {
        require(msg.sender == admin, "Only company can change address");
        if (_value == 0) {
            //DAO Address
            dao = _newAddress;
        } else if (_value == 1) {
            //Token Address
            admin = _newAddress;
        }else if (_value == 2) {
            //Token Address
            m4sToken = _newAddress;
        } else if (_value == 3) {
            //Price Feed Address
            priceFeed = _newAddress;
        }
    }



    //edit Item
    function editPrice(uint256 _itemId, uint256 _value) public {
        require(
            msg.sender == itemInfo[_itemId].owner,
            "Only item owner can edit"
        );

        itemInfo[_itemId].price = _value;

        emit ItemUpdated(_itemId);
    }

    function editMetadata(uint256 _itemId, string memory _metadata) public {
        require(
            msg.sender == itemInfo[_itemId].owner,
            "Only item owner can edit"
        );

        itemInfo[_itemId].metadata = _metadata;

        emit ItemUpdated(_itemId);
    }

    function editState(uint256 _itemId, bool _isLive) public {
        require(
            msg.sender == itemInfo[_itemId].owner,
            "Only item owner can edit"
        );

        itemInfo[_itemId].isLive = _isLive;

        emit ItemUpdated(_itemId);
    }

    //internal
    function _transferEarnings(uint256 _amount) internal {
        (bool sent, bytes memory data) = dao.call{value: _amount}("");
        data;
        require(sent, "Failed to Send Ether");
    }

    //get Chain Link Price
    function getLatestPrice() public view returns (int256) {
        (
            ,
            /*uint80 roundID*/
            int256 price, /*uint startedAt*/ /*uint timeStamp*/ /*uint80 answeredInRound*/
            ,
            ,

        ) = AggregatorV3Interface(priceFeed).latestRoundData();
        // avax main net 0x0A77230d17318075983913bC2145DB16C7366156
        //avax test net 0x5498BB86BC934c8D34FDA08E81D444153d0D06aD
        return price;
    }
}
