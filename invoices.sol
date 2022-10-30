// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Invoices {

    uint256 public invoiceCount;
    uint256 public fee; //2.5 == 250
    
    address public admin;
    address public oracle;

    struct Invoice {
        string metadata;
        bool open;
        uint256 price;
        uint256 oraclePrice;
        uint256 created;
        uint256 closed;
        uint256 paid;
        address creator;
    }

    mapping(uint256 => Invoice) public invoices; // invoiceId => Invoice

    constructor(address _oracle) {
        fee = 100;
        oracle = _oracle;
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
        uint256 _price //in USD
    ) public returns (uint256) {

        invoiceCount++;

        Invoice memory _invoice;

        _invoice.metadata = _metadata;
        _invoice.price = _price;
        _invoice.creator = msg.sender;
        _invoice.open = true;
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
            invoices[_invoiceId].open == true,
            "Invoice not open."
        );


        invoices[_invoiceId].oraclePrice = uint256(getLatestPrice());

        uint256 invoiceTotal = ((invoices[_invoiceId].price / invoices[_invoiceId].oraclePrice) *
            10**8);
        uint256 invoiceFee = (fee * invoiceTotal) / 10000;

        require(msg.value >= invoiceTotal, "Amount paid is less than total");

        _invoice.paid = true;
        _invoice.open = false;
        _invoice.closed = block.number;
        

        if (msg.value > invoiceTotal) {
            //send refund back to the user
            (bool sent,) = msg.sender.call{
                value: (msg.value - invoiceTotal)
            }("");
            require(sent, "Failed to Send Extra Ether back to Payer");
        }

        //pay creator
        (bool sent,) = _invoice.creator.call{
            value: (invoiceTotal)
            }("");
        require(sent, "Failed to Send Ether to Invoice Creator");

        //pay fee
        (bool sent,) = owner.call{
            value: (invoiceFee)
            }("");
        require(sent, "Failed to Send Ether fee to Contract Owner");


        emit InvoicePaid(
            _invoiceId
        );


    }

    //edit Settings
    //update fee
    function updateFee(uint256 _fee) public onlyOwner returns (bool) {
        fee = _fee
        return true;
    }

    //update oracle address
    function updateOracle(uint256 _oracle)
        public
        onlyOwner
        returns (bool)
    {
        oracle = _oracle;
        return true;
    }

    //edit Invoice
    function editPrice(uint256 _itemId, uint256 _price) public onlyCreator {
        invoices[_invoiceId].price = _price;
        emit InvoiceUpdated(_invoiceId);
    }

    function editMetadata(uint256 _invoiceId, string memory _metadata) public onlyCreator {
        invoices[_invoiceId].metadata = _metadata;
        emit InvoiceUpdated(_invoiceId);
    }

    function editState(uint256 _invoiceId, bool _open) public onlyCreator {
        invoices[_invoiceId].open = _open;
        emit InvoiceUpdated(_invoiceId);
    }

    //get Native Asset Price from Chain Link Oracle
    function getLatestPrice() public view returns (int256) {
        (
            ,
            /*uint80 roundID*/
            int256 price, /*uint startedAt*/ /*uint timeStamp*/ /*uint80 answeredInRound*/
            ,
            ,

        ) = AggregatorV3Interface(oracle).latestRoundData();
        // avax main net 0x0A77230d17318075983913bC2145DB16C7366156
        //avax test net 0x5498BB86BC934c8D34FDA08E81D444153d0D06aD
        return price;
    }
}
