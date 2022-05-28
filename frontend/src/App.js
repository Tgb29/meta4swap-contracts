import { BrowserRouter as Router, Routes, Route } from "react-router-dom";
import Navbar from "./components/layout/Navbar";
import Footer from "./components/layout/Footer";
import Home from "./components/pages/Home";
import Create from "./components/pages/Create";
import Shop from "./components/pages/Shop";
import Product from "./components/pages/Product";
import Order from "./components/pages/Order";
import { useState, useEffect } from "react";
import UserPage from "./components/pages/UserPage";
import Transactions from "./components/pages/Transactions";
import Web3 from "web3/dist/web3.min.js";
import m4sAbi from "./abi/m4s_abi.json";
import CategoryProducts from "./components/pages/CategoryProducts";
import CategoryService from "./components/pages/CategoryService";

async function checkIfWalletIsConnected(onConnected) {
  if (window.ethereum) {
    const accounts = await window.ethereum.request({
      method: "eth_accounts",
    });

    if (accounts.length > 0) {
      const account = accounts[0];
      onConnected(account);
      return;
    }
  }
}

const fetchEthPrice = async () => {
  const web3 = new Web3(
    new Web3.providers.HttpProvider(
      "https://api.avax-test.network/ext/bc/C/rpc"
    )
  );
  const M4SContract = new web3.eth.Contract(
    m4sAbi,
    "0xb4e61D08721007e0BA357B8AAF24D4B87b2649E1"
  );

  const ethPrice = await M4SContract.methods.getLatestPrice().call();

  console.log(ethPrice);
  window.ethPrice = ethPrice;
};

function App() {
  const [userAddress, setUserAddress] = useState("");
  const [connected, setConnected] = useState(false);

  useEffect(() => {
    checkIfWalletIsConnected(setUserAddress);
    fetchEthPrice();
  }, []);

  useEffect(() => {
    if (userAddress !== "") {
      setConnected(true);
    }
  }, [userAddress]);

  console.log(connected);
  return (
    <Router>
      <div className="flex flex-col">
        <Navbar connected={connected} userAddress={userAddress} />
        <main>
          <Routes>
            <Route path="/" element={<Home />} />
            <Route path="/category/products" element={<CategoryProducts />} />
            <Route path="/category/services" element={<CategoryService />} />
            <Route
              path="/create"
              element={
                <Create connected={connected} userAddress={userAddress} />
              }
            />
            <Route path="/shop" element={<Shop />} />
            <Route
              path="/category/:categoryName/:listingId"
              element={<Product userAddress={userAddress} />}
            />
            <Route
              path="/user/:userId"
              element={<UserPage userAddress={userAddress} />}
            />
            <Route
              path="/user/listings/:userId"
              element={<Order userAddress={userAddress} />}
            />
            <Route
              path="/transactions/:userId"
              element={<Transactions userAddress={userAddress} />}
            />
          </Routes>
        </main>

        <Footer />
      </div>
    </Router>
  );
}

export default App;
