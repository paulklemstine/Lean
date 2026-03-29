// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title DecryptionToken (ERC-721)
 * @author Oracle Council Research
 * @notice Non-fungible access tokens dispensed by Alice (the Vending Machine)
 *
 * @dev Each token represents purchased access to one encrypted information slot.
 *      The token serves as cryptographic proof of purchase:
 *        - Token ID uniquely identifies the purchase event
 *        - Slot ID links to the encrypted content
 *        - Timestamp records when access was granted
 *        - The token holder can use their purchase receipt to decrypt
 *
 *      This is a minimal ERC-721 implementation optimized for the vending machine
 *      use case. Only the AliceVendingMachine contract can mint tokens.
 *
 *   ┌─────────────────────────────────────┐
 *   │     DECRYPTION TOKEN #42            │
 *   │                                     │
 *   │  ┌─────────────────────────────┐    │
 *   │  │  🔐 ACCESS GRANTED         │    │
 *   │  │                             │    │
 *   │  │  Slot: "Quantum Dataset"    │    │
 *   │  │  Purchased: 2024-01-15      │    │
 *   │  │  Buyer: 0xAbCd...1234       │    │
 *   │  │                             │    │
 *   │  │  Present this token to      │    │
 *   │  │  receive your decryption    │    │
 *   │  │  key from the seller.       │    │
 *   │  └─────────────────────────────┘    │
 *   │                                     │
 *   │  ERC-721 • Ethereum Mainnet         │
 *   └─────────────────────────────────────┘
 */
contract DecryptionToken {

    // ═══════════════════════════════════════════════════════════════════
    //                          TYPES
    // ═══════════════════════════════════════════════════════════════════

    struct TokenData {
        uint256 slotId;       // Which information slot this grants access to
        address originalBuyer; // Who originally purchased (for provenance)
        uint256 mintedAt;     // When the token was minted
    }

    // ═══════════════════════════════════════════════════════════════════
    //                         STORAGE
    // ═══════════════════════════════════════════════════════════════════

    /// @notice ERC-721 contract name
    string public constant name = "Alice Decryption Token";
    /// @notice ERC-721 contract symbol
    string public constant symbol = "DECRYPT";

    /// @notice The AliceVendingMachine contract (only minter)
    address public immutable vendingMachine;

    /// @notice Next token ID to mint
    uint256 public nextTokenId;

    /// @notice Token ID → owner
    mapping(uint256 => address) private _owners;

    /// @notice Owner → token count
    mapping(address => uint256) private _balances;

    /// @notice Token ID → approved address
    mapping(uint256 => address) private _tokenApprovals;

    /// @notice Owner → operator → approved
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    /// @notice Token ID → metadata
    mapping(uint256 => TokenData) public tokenData;

    // ═══════════════════════════════════════════════════════════════════
    //                          EVENTS
    // ═══════════════════════════════════════════════════════════════════

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    // ═══════════════════════════════════════════════════════════════════
    //                          ERRORS
    // ═══════════════════════════════════════════════════════════════════

    error NotVendingMachine();
    error TokenDoesNotExist(uint256 tokenId);
    error NotOwnerOrApproved();
    error TransferToZeroAddress();
    error ApprovalToCurrentOwner();
    error InvalidReceiver();

    // ═══════════════════════════════════════════════════════════════════
    //                       CONSTRUCTOR
    // ═══════════════════════════════════════════════════════════════════

    constructor(address _vendingMachine) {
        vendingMachine = _vendingMachine;
    }

    // ═══════════════════════════════════════════════════════════════════
    //                     MINTING (Only Alice)
    // ═══════════════════════════════════════════════════════════════════

    /**
     * @notice Mint a new DecryptionToken — only callable by AliceVendingMachine
     * @param _to The buyer receiving the token
     * @param _slotId The information slot this token grants access to
     * @return tokenId The newly minted token ID
     */
    function mint(address _to, uint256 _slotId) external returns (uint256 tokenId) {
        if (msg.sender != vendingMachine) revert NotVendingMachine();

        tokenId = nextTokenId++;

        _owners[tokenId] = _to;
        _balances[_to]++;

        tokenData[tokenId] = TokenData({
            slotId: _slotId,
            originalBuyer: _to,
            mintedAt: block.timestamp
        });

        emit Transfer(address(0), _to, tokenId);
    }

    // ═══════════════════════════════════════════════════════════════════
    //                    ERC-721 STANDARD
    // ═══════════════════════════════════════════════════════════════════

    function balanceOf(address _owner) external view returns (uint256) {
        return _balances[_owner];
    }

    function ownerOf(uint256 _tokenId) public view returns (address) {
        address tokenOwner = _owners[_tokenId];
        if (tokenOwner == address(0)) revert TokenDoesNotExist(_tokenId);
        return tokenOwner;
    }

    function approve(address _to, uint256 _tokenId) external {
        address tokenOwner = ownerOf(_tokenId);
        if (_to == tokenOwner) revert ApprovalToCurrentOwner();
        if (msg.sender != tokenOwner && !_operatorApprovals[tokenOwner][msg.sender]) {
            revert NotOwnerOrApproved();
        }
        _tokenApprovals[_tokenId] = _to;
        emit Approval(tokenOwner, _to, _tokenId);
    }

    function getApproved(uint256 _tokenId) public view returns (address) {
        if (_owners[_tokenId] == address(0)) revert TokenDoesNotExist(_tokenId);
        return _tokenApprovals[_tokenId];
    }

    function setApprovalForAll(address _operator, bool _approved) external {
        _operatorApprovals[msg.sender][_operator] = _approved;
        emit ApprovalForAll(msg.sender, _operator, _approved);
    }

    function isApprovedForAll(address _owner, address _operator) public view returns (bool) {
        return _operatorApprovals[_owner][_operator];
    }

    function transferFrom(address _from, address _to, uint256 _tokenId) public {
        if (_to == address(0)) revert TransferToZeroAddress();

        address tokenOwner = ownerOf(_tokenId);
        if (tokenOwner != _from) revert NotOwnerOrApproved();

        bool isApproved = (
            msg.sender == _from ||
            msg.sender == _tokenApprovals[_tokenId] ||
            _operatorApprovals[_from][msg.sender]
        );
        if (!isApproved) revert NotOwnerOrApproved();

        // Clear approval
        delete _tokenApprovals[_tokenId];

        _balances[_from]--;
        _balances[_to]++;
        _owners[_tokenId] = _to;

        emit Transfer(_from, _to, _tokenId);
    }

    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external {
        transferFrom(_from, _to, _tokenId);
    }

    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes calldata) external {
        transferFrom(_from, _to, _tokenId);
    }

    // ═══════════════════════════════════════════════════════════════════
    //                     VIEW FUNCTIONS
    // ═══════════════════════════════════════════════════════════════════

    function totalSupply() external view returns (uint256) {
        return nextTokenId;
    }

    function getTokenSlot(uint256 _tokenId) external view returns (uint256) {
        if (_owners[_tokenId] == address(0)) revert TokenDoesNotExist(_tokenId);
        return tokenData[_tokenId].slotId;
    }

    function supportsInterface(bytes4 interfaceId) external pure returns (bool) {
        return
            interfaceId == 0x80ac58cd || // ERC-721
            interfaceId == 0x01ffc9a7;   // ERC-165
    }
}
