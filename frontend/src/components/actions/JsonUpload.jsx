import { useState } from "react";
import { v4 as uuidv4 } from "uuid";
import { create } from "ipfs-http-client";
import m4sAbi from "../abi/m4s_abi.json";
import Web3 from "web3/dist/web3.min.js";
import { db } from "../../firebase.config";
import { setDoc, doc, serverTimestamp } from "firebase/firestore";
import { useNavigate } from "react-router-dom";

const client = create("https://ipfs.infura.io:5001/api/v0");
const abi = m4sAbi;
export const JsonUpload = ({
  disabled,
  metaData2,
  imageUrl,
  id,
  userAddress,
}) => {
  const metaData = {
    id: id,
    ...metaData2,
    imageUrl: imageUrl,
    timestamp: serverTimestamp(),
    date: new Intl.DateTimeFormat("en-US", {
      year: "numeric",
      month: "2-digit",
      day: "2-digit",
      hour: "2-digit",
      minute: "2-digit",
      second: "2-digit",
    }).format(Date.now()),
  };
  const metaDataJSONString = JSON.stringify(metaData);
  const [uploaded, setUploaded] = useState(false);
  const [metaDataUrl, setMetaDataUrl] = useState("");
  const [live, setLive] = useState(true);
  const [price, setPrice] = useState(0);
  const [btnDisabled, setbtnDisabled] = useState(true);
  const [productType, setProductType] = useState(0);
  const navigate = useNavigate();

  console.log(price, live, metaDataUrl, productType);

  const onClick = async (e) => {
    e.preventDefault();
    const web3 = new Web3(window.ethereum);
    await window.ethereum.enable();
    const accounts = await window.ethereum.request({
      method: "eth_requestAccounts",
    });
    var account = accounts[0];

    const M4SContract = new web3.eth.Contract(
      abi,
      "0xb4e61D08721007e0BA357B8AAF24D4B87b2649E1",
      {
        from: account,
      }
    );
    //insert product type here
    M4SContract.methods
      .createItem(metaDataUrl, live, web3.utils.toWei(price), productType)
      .send()
      .on("receipt", function () {
        navigate(`/user/${userAddress}`);
      });
  };

  const uploadText = async (e) => {
    e.preventDefault();
    const docId = uuidv4();
    try {
      const added = await client.add(metaDataJSONString);
      const url = `https://ipfs.infura.io/ipfs/${added.path}`;
      setMetaDataUrl(url);
      console.log(metaDataUrl);
      setUploaded(true);
      console.log(uploaded);
      setPrice(metaData.price);
      setLive(true);
      if (metaData.category === "service") {
        setProductType(1);
      }
      setbtnDisabled(false);
      await setDoc(doc(db, "listings", docId), metaData);
    } catch (err) {
      console.log("Error uploading the file : ", err);
    }
  };

  return (
    <div>
      <button
        className="btn btn-primary"
        onClick={uploadText}
        disabled={disabled}
      >
        Upload Metadata
      </button>
      <br />
      <a
        href={metaDataUrl}
        target="_blank"
        rel="noopener noreferrer"
        className="text-primary"
      >
        {metaDataUrl === ""
          ? ""
          : `MetaData Url ${metaDataUrl.substring(0, 44)}...`}
      </a>
      <button
        className="btn btn-primary"
        onClick={onClick}
        disabled={btnDisabled}
      >
        Create on Blockchain
      </button>
    </div>
  );
};
