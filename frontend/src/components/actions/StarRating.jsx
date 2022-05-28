import React from "react";
import { FaStar } from "react-icons/fa";
import { useState } from "react";

function StarRating() {
  const [rating, setRating] = useState(0);
  const [hover, setHover] = useState(null);

  return (
    <>
      <p>{`Avg. Rating is: ${rating} ${rating < 2 ? "star" : "stars"}`}</p>
      <div className="ratingFeature pb-4">
        {[...Array(5)].map((star, i) => {
          const ratingValue = i + 1;

          return (
            <div key={ratingValue}>
              <label>
                <input
                  type="radio"
                  name="rating"
                  value={ratingValue}
                  onClick={() => setRating(ratingValue)}
                  className="ratingRadio"
                />
                <FaStar
                  onMouseEnter={() => setHover(ratingValue)}
                  onMouseLeave={() => setHover(null)}
                  className="star"
                  color={
                    ratingValue <= (hover || rating) ? "#35AEF1" : "#D3D3D3"
                  }
                  size={25}
                />
              </label>
            </div>
          );
        })}
      </div>
      <button className="btn btn-sm">Rate Product</button>
    </>
  );
}

export default StarRating;
