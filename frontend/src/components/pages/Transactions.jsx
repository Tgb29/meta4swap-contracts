import React from "react";
import Switch from "../actions/Switch";
import { useEffect, useState, useCallback } from "react";
import { useParams, Link } from "react-router-dom";
import Spinner from "../shared/Spinner";

import DisplayTransactions2 from "../layout/DisplayTransactions2";

const Moralis = require("moralis");

function Transactions({ userAddress }) {
  const [listingsBuyer, setListingsBuyer] = useState([]);
  const [listingsSeller, setListingsSeller] = useState([]);
  const [loading, setLoading] = useState(true);
  const [value, setValue] = useState(false);
  const params = useParams();
  const page = window.location.href;

  const getOrdersBuyer = useCallback(async () => {
    let ordersBuyer = [];
    try {
      const serverUrl = "https://gu15uqsbipep.usemoralis.com:2053/server";
      const appId = "F28xSksEmA0YDFTQskgodpG3W5JSZK0uBm9Abnde";
      const masterKey = "G5799rbYbzVEjmd9B2tFNfgX184JryV3ntW283dy";
      await Moralis.start({ serverUrl, appId, masterKey });
      const Item = Moralis.Object.extend("OrderCreatedBuyer");
      const query = new Moralis.Query(Item);
      //replace my address with user's address
      const user = params.userId;
      query.equalTo("buyer", user);
      const results = await query.find();
      console.log(results.length);
      for (let i = 0; i < results.length; i++) {
        const object = results[i];
        const orderId = object.get("orderId");
        const itemId = object.get("itemId");
        const price = object.get("price");
        console.log(orderId);
        console.log(itemId);
        console.log(price);

        ordersBuyer.push({ orderId: orderId, itemId: itemId, price: price });
      }
      setListingsBuyer(ordersBuyer);
      setLoading(false);
    } catch (error) {
      console.log("error");
    }
  }, [setLoading, setListingsBuyer, params.userId]);

  const getOrdersSeller = useCallback(async () => {
    let ordersSeller = [];
    try {
      const serverUrl = "https://gu15uqsbipep.usemoralis.com:2053/server";
      const appId = "F28xSksEmA0YDFTQskgodpG3W5JSZK0uBm9Abnde";
      const masterKey = "G5799rbYbzVEjmd9B2tFNfgX184JryV3ntW283dy";
      await Moralis.start({ serverUrl, appId, masterKey });
      const Item = Moralis.Object.extend("OrderCreatedSeller");
      const query = new Moralis.Query(Item);
      //replace my address with user's address
      const user = params.userId;
      query.equalTo("seller", user);
      const results = await query.find();
      console.log(results.length);
      for (let i = 0; i < results.length; i++) {
        const object = results[i];
        const orderId = object.get("orderId");
        const itemId = object.get("itemId");
        const price = object.get("price");
        console.log(orderId);
        console.log(itemId);
        console.log(price);

        ordersSeller.push({ orderId: orderId, itemId: itemId, price: price });
      }
      setListingsSeller(ordersSeller);
      setLoading(false);
    } catch (error) {
      console.log("error");
    }
  }, [setLoading, setListingsSeller, params.userId]);
  useEffect(() => {
    getOrdersBuyer();
    getOrdersSeller();

    setLoading(false);
  }, []);

  return (
    <div className="category mb-10">
      {loading ? (
        <Spinner />
      ) : listingsBuyer && listingsBuyer.length > 0 ? (
        <>
          <div>
            {userAddress !== params.userId ? (
              ""
            ) : (
              <header className="infoHeader">
                <ul className=" mt-3 menu menu-horizontal  rounded-box items-">
                  <li>
                    <Link
                      to={`/user/listings/${params.userId}`}
                      disabled={true}
                    >
                      Listings
                    </Link>
                  </li>
                  <div class="divider divider-horizontal"></div>
                  <li>
                    <a href={`/transactions/${params.userId}`}>Transactions</a>
                  </li>
                </ul>
              </header>
            )}
            <h1 className="infoHeader2 text-2xl mt-2">{`${
              page.includes("transactions")
                ? "Recent Transactions"
                : "Recently Created Listings"
            }`}</h1>
            <Switch isOn={value} handleToggle={() => setValue(!value)} />

            <div className={value === true ? "hidden" : ""}>
              <div className=" infoHeader mt-5">Items Purchased</div>
              <div className=" flex justify-center">
                <div className="overflow-x-auto ">
                  <thead className="table  ">
                    <tr>
                      <th className="pl-10 pr-10">Item Id.</th>
                      <th className="pl-20 pr-20">{`${
                        page.includes("transactions") ? "Order #" : "Item Name"
                      }`}</th>
                      <th className="pl-10 pr-10">Price</th>
                      <th className="pl-20 pr-5">Actions</th>
                    </tr>
                  </thead>
                  <table className="table">
                    <main>
                      <ul>
                        {listingsBuyer.map((listing) => (
                          <DisplayTransactions2
                            listing={listing}
                            id={listing.orderId}
                            key={listing.orderId}
                          />
                        ))}
                      </ul>
                    </main>
                  </table>
                </div>
              </div>
            </div>
          </div>
          <div className=" infoHeader mt-8">Items Sold</div>
          <div className=" flex justify-center">
            <div className="overflow-x-auto ">
              <thead className="table  ">
                <tr>
                  <th className="pl-10 pr-10">Item Id.</th>
                  <th className="pl-20 pr-20">{`${
                    page.includes("transactions") ? "Order #" : "Item Name"
                  }`}</th>
                  <th className="pl-10 pr-10">Price</th>
                  <th className="pl-20 pr-5">Actions</th>
                </tr>
              </thead>
              <table className="table">
                <main>
                  <ul>
                    {listingsSeller.map((listing) => (
                      <DisplayTransactions2
                        listing={listing}
                        id={listing.orderId}
                        key={listing.orderId}
                      />
                    ))}
                  </ul>
                </main>
              </table>
            </div>
          </div>
        </>
      ) : (
        <Spinner />
      )}
    </div>
  );
}

export default Transactions;
