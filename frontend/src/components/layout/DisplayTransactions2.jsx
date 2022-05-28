import React from "react";
import { useState, useEffect } from "react";
import avalanche from "../assets/avalanche-avax-logo.png";

import { Link } from "react-router-dom";
import m4sAbi from "../abi/m4s_abi.json";
import Web3 from "web3/dist/web3.min.js";
function DisplayTransactions2({ listing, id }) {
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
                <div className="mx-5 ">
                  <div className=" pr-10 px-8">
                    <Link
                      to={`/category/${listingData.category}/${listing.itemId}`}
                      className="font-bold"
                    >
                      {listing.itemId}
                    </Link>
                  </div>
                  <div className="badge badge-ghost badge-sm">
                    {listingData.category}
                  </div>
                </div>
              </td>
              <td>
                <div className="flex mx-10 ">
                  <div>
                    <div className="smallHeader pl-10 pt-5">
                      {listing.orderId}
                    </div>
                 
                  </div>
                </div>
                <br />
              </td>
              <td>
                {" "}
                <div className="pl-20 pr-5">
                  <div className="font-bold">{`$ ${(price*window.ethPrice/10**8).toFixed(2)}`}</div>
                  <div className="text-sm opacity-50">
                    {" "}
                    (
                      {price.toFixed(4)}{" "}
                    {avaxSym})
                  </div>
                </div>
              </td>
              <th className="px-10">
                <ul className="menu menu-compact ">
                  <li>
                    <button
                      for="complete-modal"
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

export default DisplayTransactions2;
