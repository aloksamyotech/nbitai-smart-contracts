// This setup uses Hardhat Ignition to manage smart contract deployments.
// Learn more about it at https://hardhat.org/ignition

import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
const TestUsdtModule = buildModule("TestUsdtModule", (m) => {
  const TestUsdt = m.contract("TestUsdt");
  return { testUsdt: TestUsdt };
});

export default TestUsdtModule;
