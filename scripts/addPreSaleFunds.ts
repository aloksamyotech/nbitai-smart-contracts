import { ethers } from "hardhat";
import {
  NbitaiToken__factory,
  NbitaiTokenSale__factory,
} from "../typechain-types";

async function main() {
  const [owner] = await ethers.getSigners();

  const amount = 1_000_000; // Pre sale token supply

  const token = NbitaiToken__factory.connect(
    "0x109F56ADaDE483e95e152d44a2c05729E0f2F5e2", // NbitaiToken Proxy Address
    owner
  );

  const sale = NbitaiTokenSale__factory.connect(
    "0x059918235416cCB7616ec059fAFA435b789Cc917", // NbitaiTokenSale Address
    owner
  );

  const approveResponse = await token.approve(
    await sale.getAddress(),
    ethers.parseEther(amount.toString())
  );

  const approveTx = await approveResponse.wait();
  console.log("Approval Tx", approveTx);

  const addSupplyResponse = await sale.addSupply(
    owner.address,
    ethers.parseEther(amount.toString())
  );

  const addSupplyTx = await addSupplyResponse.wait();
  console.log("Add Supply Tx", addSupplyTx);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
