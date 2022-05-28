import React from "react";
import Headlines from "./Headlines";
import { useEffect, useState, useCallback } from "react";
import ListingItem from "../layout/ListingItem";
import Spinner from "../shared/Spinner";

const Moralis = require("moralis");
function FeaturedService() {
  const [listings, setListings] = useState([]);
  const [loading, setLoading] = useState(true);

  const getServices = useCallback(async () => {
    try {
      let services = [];
      const serverUrl = "https://gu15uqsbipep.usemoralis.com:2053/server";
      const appId = "F28xSksEmA0YDFTQskgodpG3W5JSZK0uBm9Abnde";
      const masterKey = "G5799rbYbzVEjmd9B2tFNfgX184JryV3ntW283dy";
      await Moralis.start({ serverUrl, appId, masterKey });
      const Item = Moralis.Object.extend("ItemCreated");
      const query = new Moralis.Query(Item);
      query.equalTo("productType", "1");
      query.limit(8);
      const results = await query.find();
      await Promise.all(
        results.map(async (item) => {
          const metadata = item.get("metadata");
          const itemId = item.get("itemId");
          const ipfsURL = metadata;
          const response = await fetch(ipfsURL)
            .then((resp) => resp.json())
            .then((response) => response);
          services.push({ id: itemId, data: response });
        })
      );
      setListings(services);
      setLoading(false);
    } catch (error) {
      console.log("error");
    }
  }, [setLoading, setListings]);

  useEffect(() => {
    getServices();

    console.log(listings);

    setLoading(false);
  }, []);

  return (
    <div className="category">
      <Headlines text="Featured Services" content="Latest Services" />
      {loading ? (
        <Spinner />
      ) : listings && listings.length > 0 ? (
        <>
          <div
            className="container items-center"
            style={{
              display: "flex",
              alignItems: "center",
              justifyContent: "space-evenly",
            }}
          >
            <div className=" grid grid-cols-1 md:grid-cols-3 lg:grid-cols-4 xl:grid-cols-4 ">
              {listings.map((listing) => (
                <ListingItem
                  listing={listing.data}
                  id={listing.id}
                  key={listing.id}
                />
              ))}{" "}
            </div>
          </div>
        </>
      ) : (
        <Spinner />
      )}
    </div>
  );
}

export default FeaturedService;
