import React from "react";

const Switch = ({ isOn, handleToggle }) => {
  return (
    <>
      <div className="flex  mt-5 infoHeader3">
        <input
          checked={isOn}
          onChange={handleToggle}
          className="react-switch-checkbox "
          id={`react-switch-new`}
          type="checkbox"
        />
        <label
          style={{ background: isOn && "#06D6A0" }}
          className="react-switch-label"
          htmlFor={`react-switch-new`}
        >
          <span className={`react-switch-button`} />
        </label>
        <p className="mx-3 mt-1"> Seller Listings </p>
      </div>
    </>
  );
};

export default Switch;
