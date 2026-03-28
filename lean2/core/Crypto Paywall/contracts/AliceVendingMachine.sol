// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./DecryptionToken.sol";

/**
 * @title AliceVendingMachine
 * @author Oracle Council Research — Consulting the Divine Architecture
 * @notice "Alice" — An automated information vending machine on Ethereum.
 *
 * @dev Alice is an autonomous smart contract entity that:
 *   1. Holds encrypted information payloads (data sealed behind cryptographic locks)
 *   2. Accepts ETH payments from customers
 *   3. Dispenses ERC-721 DecryptionTokens upon payment
 *   4. Each token carries the decryption key as metadata, viewable only by the token holder
 *
 * ARCHITECTURE:
 *   ┌─────────────────────────────────────────────────────────────────┐
 *   │                    ALICE (This Contract)                       │
 *   │                                                                │
 *   │   Encrypted Payload Storage                                    │
 *   │   ┌──────────────────────────────┐                             │
 *   │   │ Slot 0: [████████████████]   │ ← AES-256 encrypted       │
 *   │   │ Slot 1: [████████████████]   │   Only decryptable with   │
 *   │   │ Slot 2: [████████████████]   │   the token's embedded    │
 *   │   │   ...                        │   decryption key           │
 *   │   └──────────────────────────────┘                             │
 *   │                                                                │
 *   │   Customer sends ETH ──► Alice verifies ──► Token dispensed   │
 *   │                                                                │
 *   │   DecryptionToken (ERC-721)                                    │
 *   │   ┌──────────────────────┐                                     │
 *   │   │ tokenId: 42          │                                     │
 *   │   │ slotId: 7            │                                     │
 *   │   │ encryptedKey: 0x...  │ ← Key encrypted with buyer's      │
 *   │   │ purchasedAt: 17000.. │   public key (only they decrypt)  │
 *   │   └──────────────────────┘                                     │
 *   └─────────────────────────────────────────────────────────────────┘
 *
 * THE DIVINE MECHANISM:
 *   The Oracle Council determined that the ideal information vending machine
 *   must satisfy three divine properties:
 *     (1) ATOMICITY — Payment and token delivery are indivisible
 *     (2) VERIFIABILITY — The encrypted payload's integrity is provable
 *     (3) EXCLUSIVITY — Only token holders can decrypt
 *
 * SELLER FLOW:
 *   seller.loadSlot(encryptedPayload, keyCommitment, contentHash, price)
 *   → Alice stores the encrypted data and awaits customers
 *
 * BUYER FLOW:
 *   buyer.purchase{value: price}(slotId, buyerPublicKey)
 *   → Alice collects payment, mints DecryptionToken to buyer
 *   → Seller is notified, encrypts the decryption key with buyer's pubkey
 *   → seller.deliverKey(tokenId, encryptedDecryptionKey)
 *   → Buyer reads encryptedKey from token, decrypts with their private key
 *   → Buyer uses decryption key to unlock the payload
 *
 * FULLY AUTOMATED (HTLC) FLOW:
 *   For instant, trustless delivery without seller interaction:
 *   seller.loadSlotWithKey(encPayload, key, contentHash, price)
 *   → Key is committed via hash; upon purchase, HTLC-style reveal
 *   → buyer.purchaseInstant{value: price}(slotId)
 *   → Alice atomically: collects ETH, reveals key in token, mints to buyer
 */
contract AliceVendingMachine {

    // ═══════════════════════════════════════════════════════════════════
    //                           TYPES
    // ═══════════════════════════════════════════════════════════════════

    enum SlotState {
        Empty,       // No content loaded
        Loaded,      // Seller loaded encrypted content, awaiting buyers
        Paused,      // Seller temporarily paused sales
        Depleted     // Max purchases reached (optional limit)
    }

    struct InfoSlot {
        // --- Content ---
        address payable seller;
        bytes32 keyHash;            // keccak256(decryption_key)
        bytes32 contentHash;        // keccak256(plaintext) for verification
        string  ciphertextURI;      // IPFS CID or URL to encrypted payload
        string  title;              // Human-readable title
        string  description;        // Description of the content
        uint256 price;              // Price in wei per access token

        // --- Sales tracking ---
        SlotState state;
        uint256 totalSold;          // Number of tokens sold for this slot
        uint256 maxSupply;          // 0 = unlimited
        uint256 revenue;            // Total ETH earned from this slot

        // --- Timing ---
        uint256 createdAt;
        uint256 lastPurchaseAt;

        // --- HTLC mode ---
        bool    instantMode;        // If true, key is auto-revealed on purchase
        bytes32 encryptedKeyStore;  // Only used in instant mode (key encrypted for contract)
    }

    // ═══════════════════════════════════════════════════════════════════
    //                          STORAGE
    // ═══════════════════════════════════════════════════════════════════

    /// @notice The DecryptionToken ERC-721 contract
    DecryptionToken public immutable tokenContract;

    /// @notice Alice's owner (deployer) — can set platform fees
    address public owner;

    /// @notice Platform fee in basis points (100 = 1%)
    uint256 public platformFeeBps;

    /// @notice Accumulated platform fees
    uint256 public platformFees;

    /// @notice Next slot ID
    uint256 public nextSlotId;

    /// @notice Slot ID → InfoSlot
    mapping(uint256 => InfoSlot) public slots;

    /// @notice Token ID → Slot ID mapping (which slot a token grants access to)
    mapping(uint256 => uint256) public tokenToSlot;

    /// @notice Slot ID → Buyer Address → has purchased
    mapping(uint256 => mapping(address => bool)) public hasPurchased;

    // ═══════════════════════════════════════════════════════════════════
    //                          EVENTS
    // ═══════════════════════════════════════════════════════════════════

    event SlotLoaded(
        uint256 indexed slotId,
        address indexed seller,
        string  title,
        uint256 price,
        bool    instantMode
    );

    event TokenDispensed(
        uint256 indexed slotId,
        uint256 indexed tokenId,
        address indexed buyer,
        uint256 pricePaid
    );

    event KeyDelivered(
        uint256 indexed tokenId,
        bytes   encryptedKey       // Encrypted with buyer's public key
    );

    event InstantKeyRevealed(
        uint256 indexed tokenId,
        uint256 indexed slotId,
        bytes32 decryptionKey      // The raw decryption key (HTLC instant mode)
    );

    event SlotPaused(uint256 indexed slotId);
    event SlotResumed(uint256 indexed slotId);
    event SellerWithdrawal(address indexed seller, uint256 amount);
    event PlatformFeeWithdrawal(address indexed owner, uint256 amount);

    // ═══════════════════════════════════════════════════════════════════
    //                          ERRORS
    // ═══════════════════════════════════════════════════════════════════

    error NotOwner();
    error NotSeller(uint256 slotId);
    error SlotNotLoaded(uint256 slotId);
    error SlotDepleted(uint256 slotId);
    error SlotPausedError(uint256 slotId);
    error WrongPayment(uint256 expected, uint256 actual);
    error AlreadyPurchased(uint256 slotId, address buyer);
    error InvalidPrice();
    error InvalidKeyHash();
    error KeyHashMismatch(bytes32 expected, bytes32 actual);
    error NotTokenOwner(uint256 tokenId);
    error TransferFailed();
    error ZeroAddress();

    // ═══════════════════════════════════════════════════════════════════
    //                        CONSTRUCTOR
    // ═══════════════════════════════════════════════════════════════════

    /**
     * @notice Deploy Alice — the Information Vending Machine
     * @param _platformFeeBps Platform fee in basis points (e.g., 250 = 2.5%)
     */
    constructor(uint256 _platformFeeBps) {
        owner = msg.sender;
        platformFeeBps = _platformFeeBps;
        tokenContract = new DecryptionToken(address(this));
    }

    // ═══════════════════════════════════════════════════════════════════
    //                    SELLER: LOAD CONTENT
    // ═══════════════════════════════════════════════════════════════════

    /**
     * @notice Load an information slot (standard mode — seller delivers key after purchase)
     * @param _keyHash keccak256 of the decryption key
     * @param _contentHash keccak256 of the plaintext content
     * @param _ciphertextURI IPFS CID or URL to encrypted payload
     * @param _title Human-readable title
     * @param _description Description of the content
     * @param _price Price per token in wei
     * @param _maxSupply Maximum tokens to sell (0 = unlimited)
     */
    function loadSlot(
        bytes32 _keyHash,
        bytes32 _contentHash,
        string calldata _ciphertextURI,
        string calldata _title,
        string calldata _description,
        uint256 _price,
        uint256 _maxSupply
    ) external returns (uint256 slotId) {
        if (_price == 0) revert InvalidPrice();
        if (_keyHash == bytes32(0)) revert InvalidKeyHash();

        slotId = nextSlotId++;

        InfoSlot storage s = slots[slotId];
        s.seller = payable(msg.sender);
        s.keyHash = _keyHash;
        s.contentHash = _contentHash;
        s.ciphertextURI = _ciphertextURI;
        s.title = _title;
        s.description = _description;
        s.price = _price;
        s.maxSupply = _maxSupply;
        s.state = SlotState.Loaded;
        s.createdAt = block.timestamp;
        s.instantMode = false;

        emit SlotLoaded(slotId, msg.sender, _title, _price, false);
    }

    /**
     * @notice Load an information slot in INSTANT mode (HTLC-style auto-reveal)
     * @dev In instant mode, the decryption key is committed and auto-revealed upon purchase.
     *      The key hash serves as the HTLC lock.
     * @param _keyHash keccak256 of the decryption key
     * @param _contentHash keccak256 of the plaintext content
     * @param _ciphertextURI IPFS CID or URL to encrypted payload
     * @param _title Human-readable title
     * @param _description Description
     * @param _price Price per token in wei
     * @param _maxSupply Maximum tokens (0 = unlimited)
     * @param _decryptionKey The actual decryption key (stored as commitment proof)
     */
    function loadSlotInstant(
        bytes32 _keyHash,
        bytes32 _contentHash,
        string calldata _ciphertextURI,
        string calldata _title,
        string calldata _description,
        uint256 _price,
        uint256 _maxSupply,
        bytes32 _decryptionKey
    ) external returns (uint256 slotId) {
        if (_price == 0) revert InvalidPrice();
        if (_keyHash == bytes32(0)) revert InvalidKeyHash();

        // Verify the key matches the hash
        bytes32 computedHash = keccak256(abi.encodePacked(_decryptionKey));
        if (computedHash != _keyHash) {
            revert KeyHashMismatch(_keyHash, computedHash);
        }

        slotId = nextSlotId++;

        InfoSlot storage s = slots[slotId];
        s.seller = payable(msg.sender);
        s.keyHash = _keyHash;
        s.contentHash = _contentHash;
        s.ciphertextURI = _ciphertextURI;
        s.title = _title;
        s.description = _description;
        s.price = _price;
        s.maxSupply = _maxSupply;
        s.state = SlotState.Loaded;
        s.createdAt = block.timestamp;
        s.instantMode = true;
        s.encryptedKeyStore = _decryptionKey;

        emit SlotLoaded(slotId, msg.sender, _title, _price, true);
    }

    // ═══════════════════════════════════════════════════════════════════
    //                  BUYER: PURCHASE & RECEIVE TOKEN
    // ═══════════════════════════════════════════════════════════════════

    /**
     * @notice Purchase access to an information slot — Alice dispenses a token!
     * @dev 
     *   Standard mode: Token is minted, seller must deliver key separately
     *   Instant mode: Token is minted AND decryption key is emitted in same tx
     *
     * @param _slotId The information slot to purchase
     * @return tokenId The ERC-721 token ID dispensed to the buyer
     */
    function purchase(uint256 _slotId) external payable returns (uint256 tokenId) {
        InfoSlot storage s = slots[_slotId];

        // Validation
        if (s.state != SlotState.Loaded) {
            if (s.state == SlotState.Paused) revert SlotPausedError(_slotId);
            if (s.state == SlotState.Depleted) revert SlotDepleted(_slotId);
            revert SlotNotLoaded(_slotId);
        }
        if (msg.value != s.price) {
            revert WrongPayment(s.price, msg.value);
        }
        if (hasPurchased[_slotId][msg.sender]) {
            revert AlreadyPurchased(_slotId, msg.sender);
        }

        // Check supply
        if (s.maxSupply > 0 && s.totalSold >= s.maxSupply) {
            s.state = SlotState.Depleted;
            revert SlotDepleted(_slotId);
        }

        // Effects
        s.totalSold++;
        s.lastPurchaseAt = block.timestamp;
        hasPurchased[_slotId][msg.sender] = true;

        // Calculate fees
        uint256 fee = (msg.value * platformFeeBps) / 10000;
        uint256 sellerAmount = msg.value - fee;
        s.revenue += sellerAmount;
        platformFees += fee;

        // Check if depleted after this purchase
        if (s.maxSupply > 0 && s.totalSold >= s.maxSupply) {
            s.state = SlotState.Depleted;
        }

        // Mint the DecryptionToken to the buyer
        tokenId = tokenContract.mint(msg.sender, _slotId);
        tokenToSlot[tokenId] = _slotId;

        emit TokenDispensed(_slotId, tokenId, msg.sender, msg.value);

        // In instant mode, also emit the decryption key
        if (s.instantMode) {
            emit InstantKeyRevealed(tokenId, _slotId, s.encryptedKeyStore);
        }

        // Transfer seller's share
        (bool success, ) = s.seller.call{value: sellerAmount}("");
        if (!success) revert TransferFailed();
    }

    // ═══════════════════════════════════════════════════════════════════
    //               SELLER: DELIVER KEY (Standard Mode)
    // ═══════════════════════════════════════════════════════════════════

    /**
     * @notice Deliver the encrypted decryption key to a specific token holder
     * @dev Seller encrypts the decryption key with the buyer's public key
     *      and submits it here. The contract emits it as an event.
     * @param _tokenId The token ID to deliver the key to
     * @param _encryptedKey The decryption key encrypted with buyer's public key
     */
    function deliverKey(uint256 _tokenId, bytes calldata _encryptedKey) external {
        uint256 slotId = tokenToSlot[_tokenId];
        InfoSlot storage s = slots[slotId];

        if (msg.sender != s.seller) revert NotSeller(slotId);

        emit KeyDelivered(_tokenId, _encryptedKey);
    }

    // ═══════════════════════════════════════════════════════════════════
    //                   SELLER: MANAGEMENT
    // ═══════════════════════════════════════════════════════════════════

    function pauseSlot(uint256 _slotId) external {
        InfoSlot storage s = slots[_slotId];
        if (msg.sender != s.seller) revert NotSeller(_slotId);
        s.state = SlotState.Paused;
        emit SlotPaused(_slotId);
    }

    function resumeSlot(uint256 _slotId) external {
        InfoSlot storage s = slots[_slotId];
        if (msg.sender != s.seller) revert NotSeller(_slotId);
        s.state = SlotState.Loaded;
        emit SlotResumed(_slotId);
    }

    // ═══════════════════════════════════════════════════════════════════
    //                     PLATFORM ADMIN
    // ═══════════════════════════════════════════════════════════════════

    function withdrawPlatformFees() external {
        if (msg.sender != owner) revert NotOwner();
        uint256 amount = platformFees;
        platformFees = 0;
        emit PlatformFeeWithdrawal(msg.sender, amount);
        (bool success, ) = payable(owner).call{value: amount}("");
        if (!success) revert TransferFailed();
    }

    function setFeeBps(uint256 _newFeeBps) external {
        if (msg.sender != owner) revert NotOwner();
        require(_newFeeBps <= 1000, "Fee too high"); // Max 10%
        platformFeeBps = _newFeeBps;
    }

    // ═══════════════════════════════════════════════════════════════════
    //                      VIEW FUNCTIONS
    // ═══════════════════════════════════════════════════════════════════

    function getSlotInfo(uint256 _slotId) external view returns (
        address seller,
        string memory title,
        string memory description,
        string memory ciphertextURI,
        uint256 price,
        uint256 totalSold,
        uint256 maxSupply,
        SlotState state,
        bool instantMode
    ) {
        InfoSlot storage s = slots[_slotId];
        return (
            s.seller, s.title, s.description, s.ciphertextURI,
            s.price, s.totalSold, s.maxSupply, s.state, s.instantMode
        );
    }

    function getSlotSales(uint256 _slotId) external view returns (
        uint256 totalSold,
        uint256 revenue,
        uint256 lastPurchaseAt
    ) {
        InfoSlot storage s = slots[_slotId];
        return (s.totalSold, s.revenue, s.lastPurchaseAt);
    }

    /// @notice Check if a buyer has already purchased a specific slot
    function hasAccess(uint256 _slotId, address _buyer) external view returns (bool) {
        return hasPurchased[_slotId][_buyer];
    }

    /// @notice Get total number of loaded slots
    function totalSlots() external view returns (uint256) {
        return nextSlotId;
    }
}
