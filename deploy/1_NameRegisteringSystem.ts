import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
import data from "../deployment-data/migration_data.json";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments, getNamedAccounts, getChainId } = hre;
  const { deploy } = deployments;
  const { deployer, owner } = await getNamedAccounts();
  const generalData: any = data;
  const migrationData: any = generalData[await getChainId()];
  console.log(deployer, owner);
  await deploy("NameRegisteringSystem", {
    from: deployer,
    args: [
      migrationData.minDisclosingPeriod,
      migrationData.lockingPeriod,
      migrationData.token,
      migrationData.lockingAmount,
      migrationData.maxNameSize,
      migrationData.byteFee,
      owner,
    ],
    log: true,
  });
};
export default func;
func.tags = ["name_registering_system"];
