// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract NameRegisteringSystem is Ownable {
  using SafeERC20 for IERC20;

  struct NameInfo {
    string name;
    bytes32 nameHash;
    uint256 startingDisclosure;
  }

  struct NameStatus {
    address owner;
    uint256 expiration;
  }

  mapping(address => NameInfo) internal names;

  mapping(bytes32 => NameStatus) internal namesStatus;

  mapping(bytes32 => bool) public isNameHashUsed;

  uint256 public totalFeeAmount;

  uint256 public immutable minDisclosingPeriod;

  uint256 public immutable lockingPeriod;

  IERC20 public immutable token;

  uint256 public immutable lockingAmount;

  uint256 public immutable maxNameSize;

  uint256 public immutable byteFee;

  event RegisterName(address _owner, string name, uint256 startingTime, uint256 endingTime);

  constructor(
    uint256 _minDisclosingPeriod,
    uint256 _lockingPeriod,
    IERC20 _token,
    uint256 _lockingAmount,
    uint256 _maxNameSize,
    uint256 _byteFee,
    address _owner
  ) {
    require(_minDisclosingPeriod > 0, "Minimum number of disclosing blocks is zero");
    require(_lockingPeriod > 0, "Minimum number of locking blocks is zero");
    require(_lockingAmount > 0, "Locking amount is zero");
    require(_maxNameSize > 0, "Name size is zero");
    require(_byteFee > 0, "Null fe per byte");
    require(_owner != address(0), "Owner is 0x address");
    minDisclosingPeriod = _minDisclosingPeriod;
    lockingPeriod = _lockingPeriod;
    token = _token;
    lockingAmount = _lockingAmount;
    maxNameSize = _maxNameSize;
    byteFee = _byteFee;
    transferOwnership(_owner);
  }

  function proposeName(bytes32 _nameHash) external {
    require(!isNameHashUsed[_nameHash], "HashName already used");
    NameInfo storage nameInfo = names[msg.sender];
    require(bytes(nameInfo.name).length == 0, "Your name already registered");
    isNameHashUsed[_nameHash] = true;
    nameInfo.nameHash = _nameHash;
    nameInfo.startingDisclosure = block.number + minDisclosingPeriod;
  }

  function discloseName(string calldata _name, string calldata _salt) external {
    bytes32 bytesName = keccak256(abi.encodePacked(_name));
    NameStatus storage nameStatus = namesStatus[bytesName];
    address nameOwner = nameStatus.owner;
    require(
      nameOwner == address(0) || block.number >= nameStatus.expiration,
      "Name already in use"
    );
    NameInfo storage nameInfo = names[msg.sender];
    require(
      block.number >= nameInfo.startingDisclosure,
      "Starting time for disclosure not reached"
    );
    require(bytes(nameInfo.name).length == 0, "Your name already registered");
    require(keccak256(abi.encodePacked(_name, _salt)) == nameInfo.nameHash, "Wrong name disclosed");
    uint256 nameSize = bytes(_name).length;
    require(nameSize <= maxNameSize, "Name size overcome the limit");
    nameInfo.name = _name;
    uint256 expiration = block.number + lockingPeriod;
    namesStatus[bytesName] = NameStatus(msg.sender, block.number + lockingPeriod);
    if (nameOwner != address(0)) {
      _unlock(nameOwner);
    }
    uint256 feeToPay = nameSize * byteFee;
    totalFeeAmount = totalFeeAmount + feeToPay;
    token.safeTransferFrom(msg.sender, address(this), lockingAmount + feeToPay);
    emit RegisterName(msg.sender, _name, block.number, expiration);
  }

  function unlock() external {
    string memory name = names[msg.sender].name;
    require(bytes(name).length > 0, "Your name is not registered");
    bytes32 bytesName = keccak256(abi.encodePacked(name));
    require(block.number >= namesStatus[bytesName].expiration, "Locking period not expired");
    _unlock(msg.sender);
    delete namesStatus[bytesName];
  }

  function keepName() external {
    string memory name = names[msg.sender].name;
    require(bytes(name).length > 0, "Your name is not registered");
    bytes32 bytesName = keccak256(abi.encodePacked(name));
    uint256 expiration = block.number + lockingPeriod;
    namesStatus[bytesName].expiration = expiration;
    emit RegisterName(msg.sender, name, block.number, expiration);
  }

  function claimFees() external onlyOwner {
    token.safeTransfer(msg.sender, totalFeeAmount);
    delete totalFeeAmount;
  }

  function getName(address _owner) external view returns (string memory, uint256) {
    string memory name = names[_owner].name;
    bytes32 bytesName = keccak256(abi.encodePacked(name));
    uint256 expiration = namesStatus[bytesName].expiration;
    require(bytes(name).length > 0 && expiration > block.number, "Owner has not registered a name");
    return (name, expiration);
  }

  function getNameInfo(string calldata _name) external view returns (address, uint256) {
    bytes32 bytesName = keccak256(abi.encodePacked(_name));
    NameStatus memory nameStatus = namesStatus[bytesName];
    address owner = nameStatus.owner;
    uint256 expiration = nameStatus.expiration;
    require(owner != address(0) && expiration > block.number, "Name not registered");
    return (owner, expiration);
  }

  function _unlock(address _owner) internal {
    token.safeTransfer(_owner, lockingAmount);
    delete names[_owner];
  }
}
