import { Link } from "react-router-dom";
import Logo from "../assets/logo2.png";
import accountIcon from "../assets/user-286 (1).svg";

function Navbar({ connected, userAddress }) {
  const isConnected = connected;
  const reloadPage = () => {
    window.location.reload();
  };

  const btnhandler = () => {
    if (window.ethereum) {
      window.ethereum
        .request({ method: "eth_requestAccounts" })
        .then((result) => {
          if (result[0] !== "") {
            reloadPage();
          } else {
            alert("Sign into MetaMask to create and buy with Meta4Swap");
          }
        });
    } else {
      alert("install metamask extension!!");
    }
  };

  return (
    <nav className=" mb-3 shadow-lg ">
      <Link to="/" className="flex ml-5 ">
        <img src={Logo} alt="" className="logo" />
      </Link>

      <div className="nav2 ">
        <div className="dropdown dropdown-hover">
          <button className="btn btn-link  ">
            <Link
              to="/shop"
              className="navShop text-2xl font-bold rounded-btn mr-12 "
            >
              Shop
            </Link>
          </button>
          <ul
            tabIndex="0"
            className="dropdown-content menu p-2 shadow bg-base-100 rounded-box w-52"
          >
            <li>
              <a href="/category/products">Products</a>
            </li>
            <li>
              <a href="/category/services">Services</a>
            </li>
          </ul>
        </div>
        <button className="btn btn-link">
          <Link
            to="/create"
            className="navShop text-2xl font-bold rounded-btn mr-12"
          >
            Create
          </Link>
        </button>
        {isConnected ? (
          <Link to={`/user/${userAddress}`}>
            {" "}
            <img src={accountIcon} alt="account" className="accountIcon" />
          </Link>
        ) : (
          <button
            className="btnConnect text-white text-2xl mr-2"
            onClick={btnhandler}
          >
            Connect
          </button>
        )}
      </div>
    </nav>
  );
}

export default Navbar;
