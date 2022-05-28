// Import the functions you need from the SDKs you need
import { initializeApp } from "firebase/app";
import { getFirestore } from "firebase/firestore";
// TODO: Add SDKs for Firebase products that you want to use
// https://firebase.google.com/docs/web/setup#available-libraries

// Your web app's Firebase configuration
const firebaseConfig = {
  apiKey: "AIzaSyBgr0Xplp-Um88o6Owr1SBMD4ziPz21skA",
  authDomain: "meta4swap.firebaseapp.com",
  projectId: "meta4swap",
  storageBucket: "meta4swap.appspot.com",
  messagingSenderId: "739996283014",
  appId: "1:739996283014:web:342a7d2f1879ed2a44e107",
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);
export const db = getFirestore();
