import logo from "../assets/logo3.png";
import { Link } from "react-router-dom";
function Footer() {
  return (
    <div className="Foot">
      <footer className="footer items-center p-4 bg-secondary text-neutral-content">
        <div className="items-center grid-flow-col">
          <Link to="/" className="flex ml-5 ">
            <img src={logo} alt="" className="logo" />
          </Link>
          <p className="ml-3 mt-3">Copyright © 2022 - All right reserved</p>
        </div>
        <div className="justify-self-end">
          <p className="mr-5"> Powered by TheoDAOs</p>
        </div>
      </footer>
    </div>
  );
}

export default Footer;
