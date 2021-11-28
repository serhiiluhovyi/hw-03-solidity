const SerhiiLCoin = artifacts.require('SerhiiLCoin')
const SerhiiLCoin_ICO = artifacts.require('SerhiiLCoin_ICO')

module.exports = async function(deployer) {
  
  // Deploy Token
  await deployer.deploy(SerhiiLCoin)
  const SLC = await SerhiiLCoin.deployed()

  // Deploy ICO
  await deployer.deploy(SerhiiLCoin_ICO)
  const SLC_ICO = await SerhiiLCoin_ICO.deployed()

}
