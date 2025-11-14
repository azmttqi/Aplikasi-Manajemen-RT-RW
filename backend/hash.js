// hash.js
import bcrypt from "bcrypt";

const run = async () => {
  const plain = "123456";
  const hash = await bcrypt.hash(plain, 10);
  console.log("Hash untuk 123456:", hash);
};

run();
