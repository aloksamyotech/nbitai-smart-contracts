import { ethers } from "hardhat";
import Decimal from "decimal.js";
import { NbitaiTokenSale__factory } from "../typechain-types";

async function main() {
  const [owner] = await ethers.getSigners();

  const token = "0x30e4ba6867a9232E8f65fDE161297F9486424Ba5"; // ERC20 Token address to purchase Nbitai tokens
  const rate = 16.666666667; // Exchange rate with this token - Ex. 1 Nbitai = 0.06 USDT (Or Any other token) Then rate = 1/0.06 = 16.666666667

  const sale = NbitaiTokenSale__factory.connect(
    "0x059918235416cCB7616ec059fAFA435b789Cc917", // NbitaiTokenSale Address
    owner
  );

  const exchangeRate = new Decimal(rate)
    .mul((await sale.INVERSE_BASIS_POINT()).toString())
    .toDP(0)
    .toString();
  const response = await sale.setRate(token, exchangeRate);

  const tx = await response.wait();
  console.log("Tx", tx);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
