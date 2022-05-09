from web3 import Web3
import json

w3 = Web3(Web3.HTTPProvider(
    'https://rinkeby.infura.io/v3/18c3956af9734c289bfed9eee03ee1a7'))


with open("m4s_abi.json") as f:
    abi = json.load(f)

meta4swap = w3.eth.contract(
    address='0x56540E5212525aA310c2025F498BE8EeD8399511', abi=abi)

tx_receipt = w3.eth.get_transaction_receipt(
    "0xeec7dc8a063c1756808d7c229a85ee067bea79b6970242676c832f194960c11d")

rich_logs = meta4swap.events.ItemCreated().processReceipt(tx_receipt)

print(rich_logs)

# print(meta4swap.events.ItemCreated())

# print(meta4swap.functions.getLatestPrice().call())

# print(meta4swap.events.ItemCreated.getLogs())
# print(dir(meta4swap.events.ItemCreated))


event_filter = meta4swap.events.ItemCreated().createFilter(fromBlock="0x0")

print(event_filter.get_all_entries())
