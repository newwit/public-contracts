// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "erc721a-upgradeable/contracts/ERC721AUpgradeable.sol";
import "erc721a-upgradeable/contracts/extensions/ERC721AQueryableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol";

/**
 * @title Newwit NFT Collection contract.
 * @dev Character and outfi collection of Newwit which utilized ERC721A library.
 * @dev This smart contract is upgradable.
 * @author Peter Sun
 */
contract ERC721ACollection is
    ERC721AUpgradeable,
    OwnableUpgradeable,
    ERC721AQueryableUpgradeable
{
    using StringsUpgradeable for uint256;

    // The prefix string of NFT URI
    string public uriPrefix;
    // The suffix string of NFT URI
    string public uriSuffix;
    // Pause flag
    bool public paused;
    // Gap storage
    uint256[50] private __gap;

    /**
     * @notice Emitted when the uri prefix string is changed.
     * @dev If the uri prefix string is changed in _setUriPrefix function, this event should be emitted.
     * @param oldURIPrefix The old prefix uri string before changing.
     * @param newURIPrefix The new prefix uri string after changing.
     */
    event SetUriPrefix(string oldURIPrefix, string newURIPrefix);

    /**
     * @notice Emitted when the uri suffix string is changed.
     * @dev If the uri prefix string is changed in _setUriSuffix function, this event should be emitted.
     * @param oldURISuffix The old suffix uri string before changing.
     * @param newURISuffix The new suffix uri string after changing.
     */
    event SetUriSuffix(string oldURISuffix, string newURISuffix);

    /**
     * @notice Emitted when the status of the pause flag is changed.
     * @dev If the status of the puase flag is changed in setPaused function, this event should be emitted.
     * @param oldState The old status of the pause flag before changing.
     * @param newState The new status of the pause flag after changing.
     */
    event SetPaused(bool oldState, bool newState);

    /**
     * @notice Reverted if the uri prefix string is empty.
     * @dev If the uri prefix string is empty, this error should be reverted.
     */
    error URIPrefixEmpty();

    /**
     * @notice Reverted if the uri suffix string is empty.
     * @dev If the uri suffix string is empty, this error should be reverted.
     */
    error URISuffixEmpty();

    /**
     * @notice Reverted if the pause flag is set as true.
     * @dev If the pause flag is set as true in safeMint function, this error should be reverted.
     */
    error MintPaused();

    /**
     * @notice Reverted if the pause flag is set as the same status.
     * @dev If the puase flag is set as same state in setPaused function, this error should be reverted.
     */
    error PauseSameFlag();

    /**
     * @notice Reverted if the address is '0x0'.
     * @dev if the address of token recevier is 0x0 in safeMint function, this error should be reverted.
     */
    error IncorrectAddress();

    /**
     * @notice Reverted if the quantity of token to mint is zero.
     * @dev If the quantity of token to mint is zero in safeMint function, this error should be reverted.
     */
    error InvalidQuantity();

    modifier mintStarted() {
        if (paused) revert MintPaused();
        _;
    }

    /**
     * @dev Protect initialize functionce from inherited contracts.
     * @custom:oz-upgrades-unsafe-allow constructor
     */
    constructor() {
        _disableInitializers();
    }

    /**
     * @dev initialize the contract invoked by the proxy contract.
     * @param _name name of token.
     * @param _symbol symbol of token.
     * @param _uriPrefix The prefix string of NFT URI.
     * @param _uriSuffix The suffix string of NFT URI.
     */
    function initialize(
        string memory _name,
        string memory _symbol,
        string memory _uriPrefix,
        string memory _uriSuffix
    ) public initializerERC721A initializer {
        __ERC721A_init(_name, _symbol);
        __Ownable_init();

        _setUriPrefix(_uriPrefix);
        _setUriSuffix(_uriSuffix);
    }

    /**
     * @dev mint NFT to the user.
     * @param to the address of token receiver.
     * @param quantity quantity of NFT.
     */
    function mintTo(
        address to,
        uint256 quantity
    ) external onlyOwner mintStarted {
        if (to == address(0)) revert IncorrectAddress();
        if (quantity <= 0) revert InvalidQuantity();
        _safeMint(to, quantity);
    }

    /**
     * @dev get the token URI.
     * @param _tokenId The token Id.
     */
    function tokenURI(
        uint256 _tokenId
    ) public view virtual override returns (string memory) {
        if (!_exists(_tokenId)) revert URIQueryForNonexistentToken();

        string memory currentBaseURI = _baseURI();
        return
            bytes(currentBaseURI).length > 0
                ? string(
                    abi.encodePacked(
                        currentBaseURI,
                        _tokenId.toString(),
                        uriSuffix
                    )
                )
                : "";
    }

    /**
     * @dev set prefix string of NFT URI by only collection owner.
     * @param _uriPrefix The prefix string.
     */
    function setUriPrefix(string memory _uriPrefix) public onlyOwner {
        _setUriPrefix(_uriPrefix);
    }

    /**
     * @dev set suffic string of NFT URI by only collection owner.
     * @param _uriSuffix The suffix string.
     */
    function setUriSuffix(string memory _uriSuffix) public onlyOwner {
        _setUriSuffix(_uriSuffix);
    }

    function _setUriPrefix(string memory _uriPrefix) internal virtual {
        if (bytes(_uriPrefix).length == 0) revert URIPrefixEmpty();

        emit SetUriPrefix(uriPrefix, _uriPrefix);

        uriPrefix = _uriPrefix;
    }

    function _setUriSuffix(string memory _uriSuffix) internal virtual {
        if (bytes(_uriSuffix).length == 0) revert URISuffixEmpty();

        emit SetUriSuffix(uriSuffix, _uriSuffix);

        uriSuffix = _uriSuffix;
    }

    /**
     * @dev set Pause flag by only collection owner.
     * @param _state the flag.
     */
    function setPaused(bool _state) external onlyOwner {
        if (paused == _state) revert PauseSameFlag();

        emit SetPaused(paused, _state);

        paused = _state;
    }

    /**
     * @dev Get the NFT base URI (overrided).
     * @return Return uri prefix string.
     */
    function _baseURI() internal view virtual override returns (string memory) {
        return uriPrefix;
    }
}