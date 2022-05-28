import Hero from "../layout/Hero";
import Content from "../layout/Content";
import FeaturedProduct from "../layout/FeaturedProduct";
import FeaturedService from "../layout/FeaturedService";

function Home() {
  return (
    <>
      <Hero />
      <FeaturedProduct />
      <FeaturedService />
      <Content />
    </>
  );
}

export default Home;
