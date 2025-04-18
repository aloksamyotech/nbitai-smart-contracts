// This setup uses Hardhat Ignition to manage smart contract deployments.
// Learn more about it at https://hardhat.org/ignition

import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const NbitaiTokenModule = buildModule("NbitaiTokenModule", (m) => {
  const owner = m.getParameter("owner", m.getAccount(0));

  const NbitaiTokenImpl = m.contract("NbitaiToken", [], {
    id: "NbitaiTokenImpl",
  });
  const NbitaiTokenProxy = m.contract(
    "ERC1967Proxy",
    [
      NbitaiTokenImpl,
      m.encodeFunctionCall(NbitaiTokenImpl, "initialize", [owner]),
    ],
    { id: "NbitaiTokenProxy" }
  );

  return { proxy: NbitaiTokenProxy };
});

export default NbitaiTokenModule;
