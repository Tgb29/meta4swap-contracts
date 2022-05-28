import PropTypes from "prop-types";

function Headlines({ text, content }) {
  const page = window.location.href;
  return (
    <>
      {page.includes("category") || page.includes("shop") ? (
        ""
      ) : (
        <div className="divider"></div>
      )}

      <div
        className="container mx-20 md:mx-4"
        style={{
          display: "flex",
          alignItems: "center",
        }}
      >
        <h1 className="homeHeader text-5xl justify-center "> {text}</h1>
      </div>
      <div
        className="container items-center mx-auto justify-center pb-3"
        style={{
          display: "flex",
          alignItems: "center",
        }}
      >
        <h2 className="homeHeader2 text-3xl "> {content}</h2>
      </div>
    </>
  );
}

Headlines.propTypes = {
  text: PropTypes.string,
  content: PropTypes.string,
};
export default Headlines;
