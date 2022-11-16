// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/presets/ERC20PresetMinterPauserUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

/**
 * @title Newwit ERC20 token contract
 * @dev Governance and in-game token for tokenomics of Newwit
 * @dev This smart contract is upgradable
 * @author Peter Sun
 */
contract ERC20Token is
    Initializable,
    UUPSUpgradeable,
    OwnableUpgradeable,
    ERC20PresetMinterPauserUpgradeable
{
    // Max supply of token
    uint256 public maxSupply;
    // Gap storage
    uint256[50] private __gap;

    /**
     * @notice Reverted if the initial supply is greater than max supply.
     * @dev While initialzing the contract, if the initial supply is greater than max supply, this error should be reverted.
     */
    error InvalidInitialSupply();

    /**
     * @notice Reverted if the address is '0x0'.
     * @dev if the address of token recevier is 0x0 in mint function, this error should be reverted.
     */
    error IncorrectAddress();

    /**
     * @notice Reverted if the amount of token is zero.
     * @dev if the amount of token is zero in mint function, this error should be reverted.
     */
    error InvalidAmount();

    /**
     * @notice Reverted if total supply is greater than max supply.
     * @dev if the amount of token to mint plus total supply is greater than max supply in mint function, this error should be reverted.
     */
    error CapExceed();

    /**     
     * @dev Token will be burned by only burn() function.
     */
    error InvalidBurn();

    /**
     * @dev Protect initialize functionce from inherited contracts.
     * @custom:oz-upgrades-unsafe-allow constructor
     */
    constructor() {
        _disableInitializers();
    }

    /**
     * @dev Initialize the contract invoked by the proxy contract.
     * @param _name name of token
     * @param _symbol symbol of token.
     * @param _maxSupply max supply of token.
     * @param _initialSupply initial supply of token.
     */
    function initialize(
        string memory _name,
        string memory _symbol,
        uint256 _maxSupply,
        uint256 _initialSupply
    ) public virtual initializer {
        if (_maxSupply != 0 && _maxSupply < _initialSupply)
            revert InvalidInitialSupply();
        maxSupply = _maxSupply;
        _mint(_msgSender(), _initialSupply);
        __Ownable_init();
        __UUPSUpgradeable_init();
        super.initialize(_name, _symbol);
    }

    function _authorizeUpgrade(
        address newImplementation
    ) internal override onlyOwner {}

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override(ERC20PresetMinterPauserUpgradeable) {
        super._beforeTokenTransfer(from, to, amount);
    }

    /**
     * @dev The max supply of token.
     * @dev If max supply is zero, return maximum integer of uint256 type.
     */
    function cap() public view returns (uint256) {
        return maxSupply == 0 ? type(uint256).max : maxSupply;
    }

    /**
     * @dev Mint token to a specific user.
     * @param to address of token receiver.
     * @param amount amount of token to mint.
     */
    function mint(address to, uint256 amount) public override onlyOwner {
        if (to == address(0)) revert IncorrectAddress();
        if (amount == 0) revert InvalidAmount();
        if (maxSupply > 0 && ((totalSupply() + amount) > maxSupply))
            revert CapExceed();

        _mint(to, amount);
    }

    /**
     * @dev Burn owner's token
     * @param amount amount of token to mint.
     */
    function burn(uint256 amount) public override onlyOwner {        
        if (amount == 0) revert InvalidAmount();       
        if (amount > balanceOf(msg.sender)) revert InvalidAmount();        

        _burn(msg.sender, amount);
    }

    /**
     * @dev Disable burnFrom function
     * @param account address of user's account
     * @param amount amount of token to mint.
     */
    function burnFrom(address account, uint256 amount) public override {
        revert InvalidBurn();
    }
}