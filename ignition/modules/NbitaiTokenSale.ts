// This setup uses Hardhat Ignition to manage smart contract deployments.
// Learn more about it at https://hardhat.org/ignition

import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const JAN_31ST_2025 = 1738367999;

const NbitaiTokenSaleModule = buildModule("NbitaiTokenSaleModule", (m) => {
  const token = m.getParameter(
    "token",
    "0x109F56ADaDE483e95e152d44a2c05729E0f2F5e2" // Replace with your deployed token proxy address
  ); // Nbitai Token address
  const claimTime = m.getParameter("claimTime", JAN_31ST_2025); // Update claim time as per your needs

  const NbitaiTokenSale = m.contract("NbitaiTokenSale", [token, claimTime]);

  return { nbitaiTokenSale: NbitaiTokenSale };
});

export default NbitaiTokenSaleModule;
