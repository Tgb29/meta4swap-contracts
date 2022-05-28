import { useState } from "react";

export default function useMetaMaskAccount() {
  const [defaultAccount, setDefaultAccount] = useState(null);
  // Asking if metamask is already present or not
  if (window.ethereum) {
    // res[0] for fetching a first wallet
    window.ethereum
      .request({ method: "eth_requestAccounts" })
      .then((result) => {
        accountChangedHandler(result[0]);
      });
  } else {
    alert("install metamask extension!!");
  }
  const accountChangedHandler = (newAccount) => {
    setDefaultAccount(newAccount);
  };

  console.log(defaultAccount);

  return defaultAccount;
}
