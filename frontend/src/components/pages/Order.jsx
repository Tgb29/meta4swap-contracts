import React from "react";
import { useEffect, useState, useCallback } from "react";
import { useParams, Link } from "react-router-dom";
import Spinner from "../shared/Spinner";

import DisplayTransactions from "../layout/DisplayTransactions";

const Moralis = require("moralis");
function Order({ userAddress }) {
  const [listings, setListings] = useState([]);
  const [loading, setLoading] = useState(true);
  const params = useParams();
  const getUserItems = useCallback(async () => {
    try {
      let userItems = [];
      const serverUrl = "https://gu15uqsbipep.usemoralis.com:2053/server";
      const appId = "F28xSksEmA0YDFTQskgodpG3W5JSZK0uBm9Abnde";
      const masterKey = "G5799rbYbzVEjmd9B2tFNfgX184JryV3ntW283dy";
      await Moralis.start({ serverUrl, appId, masterKey });
      const Item = Moralis.Object.extend("ItemCreated");
      const query = new Moralis.Query(Item);

      query.equalTo("creator", userAddress);
      const results = await query.find();
      await Promise.all(
        results.map(async (item) => {
          const metadata = item.get("metadata");
          const itemId = item.get("itemId");
          const ipfsURL = metadata;
          const response = await fetch(ipfsURL)
            .then((resp) => resp.json())
            .then((response) => response);
          userItems.push({ id: itemId, data: response });
        })
      );
      setListings(userItems);
      setLoading(false);
    } catch (error) {
      console.log("error");
    }
  }, [setLoading, setListings, userAddress]);

  useEffect(() => {
    getUserItems();

    console.log(listings);

    setLoading(false);
  }, []);
  return (
    <div className="category mb-10">
      {loading ? (
        <Spinner />
      ) : listings && listings.length > 0 ? (
        <>
          <header className="infoHeader">
            <ul className=" mt-3 menu menu-horizontal  rounded-box items-">
              <li>
                <Link to={`/user/listings/${userAddress}`} disabled={true}>
                  Listings
                </Link>
              </li>
              <div className="divider divider-horizontal"></div>
              <li>
                <a href={`/transactions/${params.userId}`}>Transactions</a>
              </li>
            </ul>
          </header>
          <h1 className="infoHeader2 text-2xl">Recently Created Listings</h1>
          <div className=" flex justify-center">
            <div className="overflow-x-auto ">
              <thead className="table  ">
                <tr>
                  <th className="pl-10 pr-10">Item Id.</th>
                  <th className="pl-10 pr-20">Item Name</th>
                  <th className="pl-10 pr-10">Price</th>
                  <th className="pl-20 pr-5">Actions</th>
                </tr>
              </thead>
              <table className="table">
                <main>
                  <ul>
                    {listings.map((listing) => (
                      <DisplayTransactions
                        listing={listing.data}
                        id={listing.id}
                        key={listing.id}
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

export default Order;
