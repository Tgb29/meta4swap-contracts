import React from "react";

import avalanche from "../assets/avalanche-avax-logo.png";
import { useState, useEffect } from "react";

import { Link } from "react-router-dom";
import m4sAbi from "../abi/m4s_abi.json";
import Web3 from "web3/dist/web3.min.js";

function DisplayTransactions({ listing, id }) {
  const avaxSym = <img className="eth" src={avalanche} alt="matic" />;
  const price = listing.price / 10 ** 18;
  const [listingData, setListingData] = useState([]);
  const [loading, setLoading] = useState(true);

  const completeOrder = async (e) => {
    e.preventDefault();
    const web3 = new Web3(window.ethereum);
    await window.ethereum.enable();
    const accounts = await window.ethereum.request({
      method: "eth_requestAccounts",
    });
    var account = accounts[0];

    const M4SContract = new web3.eth.Contract(
      m4sAbi,
      "0xb4e61D08721007e0BA357B8AAF24D4B87b2649E1",
      {
        from: account,
      }
    );

    const orderId = listing.orderId;
    console.log(orderId);

    M4SContract.methods.complete(orderId).send();
  };

  const cancelOrder = async (e) => {
    e.preventDefault();
    const web3 = new Web3(window.ethereum);
    await window.ethereum.enable();
    const accounts = await window.ethereum.request({
      method: "eth_requestAccounts",
    });
    var account = accounts[0];

    const M4SContract = new web3.eth.Contract(
      m4sAbi,
      "0xb4e61D08721007e0BA357B8AAF24D4B87b2649E1",
      {
        from: account,
      }
    );

    const orderId = listing.orderId;
    console.log(orderId);

    M4SContract.methods.cancel(orderId).send();
  };

  const disputeOrder = async (e) => {
    e.preventDefault();
    const web3 = new Web3(window.ethereum);
    await window.ethereum.enable();
    const accounts = await window.ethereum.request({
      method: "eth_requestAccounts",
    });
    var account = accounts[0];

    const M4SContract = new web3.eth.Contract(
      m4sAbi,
      "0xb4e61D08721007e0BA357B8AAF24D4B87b2649E1",
      {
        from: account,
      }
    );

    const orderId = listing.orderId;
    console.log(orderId);

    M4SContract.methods.dispute(orderId).send();
  };
  const getItem = async () => {
    const itemId = listing.itemId;
    const web3 = new Web3(
      new Web3.providers.HttpProvider(
        "https://api.avax-test.network/ext/bc/C/rpc"
      )
    );
    const M4SContract = new web3.eth.Contract(
      m4sAbi,
      "0xb4e61D08721007e0BA357B8AAF24D4B87b2649E1"
    );

    const itemInfo = await M4SContract.methods.itemInfo(itemId).call();

    console.log(itemInfo["id"]);
    console.log(itemInfo["metadata"]);
    fetch(itemInfo["metadata"])
      .then((response) => response.json())
      .then((data) => {
        setListingData(data);
        setLoading(false);
      });
  };
  useEffect(() => {
    getItem();

    setLoading(false);
  }, []);
  return (
    <>
      <div className="overflow-x-auto w-full">
        <table className="table w-full">
          <tbody>
            <tr>
              <td>
                <div className="flex mx-10 ">
                  <div>
                    <div className="font-bold">{id}</div>
                    <div className="badge badge-ghost badge-sm">
                      {listing.category}
                    </div>
                  </div>
                </div>
              </td>
              <td>
                {listing.productName}
                <br />
              </td>
              <td>
                {" "}
                <div className="pl-20 pr-5">
                  <div className="font-bold">{`$ ${listing.price}`}</div>
                  <div className="text-sm opacity-50">
                    {" "}
                    (
                    {(
                      (((listing.price * 10 ** 18) / window.ethPrice) *
                        10 ** 8) /
                      10 ** 18
                    ).toFixed(3)}{" "}
                    {avaxSym})
                  </div>
                </div>
              </td>
              <th className="px-10">
                <ul className="menu menu-compact ">
                  <li>
                    <button
                      className="compBtn modal-button"
                      onClick={completeOrder}
                    >
                      Complete
                    </button>
                  </li>
                  <li>
                    <button className="canBtn" onClick={cancelOrder}>
                      Cancel
                    </button>
                  </li>
                  <li>
                    <button className="disputeBtn" onClick={disputeOrder}>
                      Dispute
                    </button>
                  </li>
                </ul>
              </th>
            </tr>
          </tbody>
        </table>
      </div>
    </>
  );
}

export default DisplayTransactions;
