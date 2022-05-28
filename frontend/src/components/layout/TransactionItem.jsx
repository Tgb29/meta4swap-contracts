import React from "react";
import { useState, useEffect } from "react";
const TransactionItem = ({ id, listings }) => {
  return (
    <>
      <div className="overflow-x-auto w-full">
        <table className="table w-full">
          <tbody>
            <tr>
              <th>
                <label>
                  <input type="checkbox" className="checkbox" />
                </label>
              </th>

              <td>
                <div className="flex ">
                  <div>
                    <div className="font-bold">Item Id</div>
                    <div className="text-sm opacity-50">Date</div>
                  </div>
                </div>
              </td>
              <td>
                {`${id.substring(0, 5)}...${id.substring(id.length - 4)}`}
                <br />
              </td>
              <td>
                {" "}
                <div>
                  <div className="font-bold">$100</div>
                  <div className="text-sm opacity-50">{`(0.051 avax)`}</div>
                </div>
              </td>
              <th className="px-1">
                <ul className="menu menu-compact ">
                  <li>
                    <button
                      for="complete-modal"
                      className="compBtn modal-button"
                    >
                      Complete
                    </button>
                  </li>
                  <li>
                    <button className="canBtn">Cancel</button>
                  </li>
                  <li>
                    <button className="disputeBtn">Dispute</button>
                  </li>
                </ul>
              </th>
            </tr>
          </tbody>
        </table>
      </div>
    </>
  );
};

export default TransactionItem;
