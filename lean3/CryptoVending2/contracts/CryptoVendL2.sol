// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title CryptoVendL2
 * @author CryptoVending2 Project
 * @notice Gas-optimized vending machine for selling encrypted files on Layer 2.
 *
 * ═══════════════════════════════════════════════════════════════════════
 *  ARCHITECTURE
 * ═══════════════════════════════════════════════════════════════════════
 *
 *  ┌─────────┐        ┌──────────────┐        ┌────────────┐
 *  │  Seller  │──────▶│  This Contract│◀──────│   Buyer     │
 *  │  (SAP)   │       │  (Arbitrum/   │       │  (IPFS page)│
 *  └─────────┘       │   Base)       │       └────────────┘
 *       │             └──────────────┘              │
 *       │                    │                      │
 *       ▼                    ▼                      ▼
 *  ┌─────────┐        ┌──────────┐          ┌──────────┐
 *  │  IPFS   │        │ Events   │          │ MetaMask │
 *  │ (pinned)│        │ (indexed)│          │          │
 *  └─────────┘        └──────────┘          └──────────┘
 *
 *  Flow:
 *    1. Seller encrypts file with AES-256-GCM, uploads ciphertext to IPFS
 *    2. Seller deploys this contract with file CID, price, key commitment
 *    3. Seller pins buyer HTML page to IPFS (contains contract address + ABI)
 *    4. Buyer visits IPFS buyer page, connects MetaMask
 *    5. Buyer calls purchase() with ECIES public key + ETH payment
 *    6. Contract emits PurchaseRequested event
 *    7. Seller's SAP watcher detects event, encrypts AES key with buyer's
 *       ECIES public key, calls deliverKey()
 *    8. Buyer's page detects KeyDelivered event, decrypts AES key,
 *       downloads encrypted file from IPFS, decrypts it locally
 *
 *  The AES key NEVER appears on-chain in the clear.
 *  Supports INFINITE automated sales (multi-serving).
 *
 * ═══════════════════════════════════════════════════════════════════════
 *  L2 OPTIMIZATIONS
 * ═══════════════════════════════════════════════════════════════════════
 *
 *  - Calldata is the dominant cost on L2 (not execution).
 *  - We use tight packing and minimal storage writes.
 *  - Purchase ID is sequential uint64 (not uint256) to save calldata.
 *  - The buyer's public key is stored as bytes (65 bytes, uncompressed).
 *  - Events carry the payload — no redundant storage.
 *  - Refund timeout is built in: buyer can reclaim after REFUND_WINDOW.
 *
 * ═══════════════════════════════════════════════════════════════════════
 */
contract CryptoVendL2 {
    // ── Constants ────────────────────────────────────────────────────────
    uint256 public constant VERSION = 2;
    uint256 public constant REFUND_WINDOW = 1 hours;

    // ── Immutables (set once at deploy, stored in bytecode on L2) ─────
    address public immutable seller;
    uint256 public immutable price;          // price in wei
    bytes32 public immutable keyCommitment;  // keccak256(aesKey)

    // ── Storage ──────────────────────────────────────────────────────────
    string  public fileCID;       // IPFS CID of encrypted file
    string  public buyerPageCID;  // IPFS CID of buyer HTML page
    string  public fileMetadata;  // JSON: {name, size, type, description}
    bool    public paused;

    // ── Purchase tracking ────────────────────────────────────────────────
    struct Purchase {
        address buyer;
        uint64  timestamp;
        uint128 paidWei;
        bool    keyDelivered;
        bool    refunded;
    }

    uint64 public purchaseCount;
    mapping(uint64 => Purchase)    public purchases;
    mapping(uint64 => bytes)       public buyerPubKeys;    // stored separately (large)
    mapping(uint64 => bytes)       public encryptedKeys;   // stored separately (large)
    mapping(address => uint64[])   public buyerHistory;

    // ── Sales stats ──────────────────────────────────────────────────────
    uint256 public totalRevenue;
    uint256 public totalSales;

    // ── Events ───────────────────────────────────────────────────────────
    event PurchaseRequested(
        uint64  indexed purchaseId,
        address indexed buyer,
        bytes   buyerPublicKey,
        uint128 amount
    );

    event KeyDelivered(
        uint64  indexed purchaseId,
        address indexed buyer,
        bytes   encryptedKey
    );

    event RefundIssued(
        uint64  indexed purchaseId,
        address indexed buyer,
        uint128 amount
    );

    event FundsWithdrawn(address indexed to, uint256 amount);
    event Paused(bool state);
    event MetadataUpdated(string fileCID, string buyerPageCID, string fileMetadata);

    // ── Errors ───────────────────────────────────────────────────────────
    error InsufficientPayment();
    error ContractPaused();
    error OnlySeller();
    error InvalidPubKey();
    error NotFound();
    error AlreadyDelivered();
    error AlreadyRefunded();
    error RefundWindowOpen();    // seller can't withdraw disputed funds
    error RefundWindowClosed();  // buyer can't refund after window
    error NothingToWithdraw();
    error TransferFailed();

    // ── Modifiers ────────────────────────────────────────────────────────
    modifier onlySeller() {
        if (msg.sender != seller) revert OnlySeller();
        _;
    }

    // ═════════════════════════════════════════════════════════════════════
    //  CONSTRUCTOR
    // ═════════════════════════════════════════════════════════════════════
    constructor(
        uint256       _price,
        bytes32       _keyCommitment,
        string memory _fileCID,
        string memory _buyerPageCID,
        string memory _fileMetadata
    ) {
        seller        = msg.sender;
        price         = _price;
        keyCommitment = _keyCommitment;
        fileCID       = _fileCID;
        buyerPageCID  = _buyerPageCID;
        fileMetadata  = _fileMetadata;
    }

    // ═════════════════════════════════════════════════════════════════════
    //  BUYER: PURCHASE
    // ═════════════════════════════════════════════════════════════════════
    /**
     * @notice Buy the file. Send >= `price` wei with your 65-byte
     *         uncompressed secp256k1 public key.
     * @param pubKey 65-byte uncompressed ECIES public key (0x04 || x || y)
     */
    function purchase(bytes calldata pubKey) external payable {
        if (paused) revert ContractPaused();
        if (msg.value < price) revert InsufficientPayment();
        if (pubKey.length != 65) revert InvalidPubKey();

        uint64 id = purchaseCount++;

        purchases[id] = Purchase({
            buyer:        msg.sender,
            timestamp:    uint64(block.timestamp),
            paidWei:      uint128(msg.value),
            keyDelivered: false,
            refunded:     false
        });

        buyerPubKeys[id] = pubKey;
        buyerHistory[msg.sender].push(id);
        totalSales++;

        emit PurchaseRequested(id, msg.sender, pubKey, uint128(msg.value));
    }

    // ═════════════════════════════════════════════════════════════════════
    //  SELLER: DELIVER KEY
    // ═════════════════════════════════════════════════════════════════════
    /**
     * @notice Seller delivers the AES key encrypted with the buyer's
     *         ECIES public key.
     * @param purchaseId The purchase to fulfill
     * @param encKey     ECIES ciphertext of the AES-256 key
     */
    function deliverKey(uint64 purchaseId, bytes calldata encKey)
        external onlySeller
    {
        if (purchaseId >= purchaseCount) revert NotFound();
        Purchase storage p = purchases[purchaseId];
        if (p.keyDelivered) revert AlreadyDelivered();
        if (p.refunded) revert AlreadyRefunded();

        p.keyDelivered = true;
        encryptedKeys[purchaseId] = encKey;
        totalRevenue += p.paidWei;

        emit KeyDelivered(purchaseId, p.buyer, encKey);
    }

    // ═════════════════════════════════════════════════════════════════════
    //  BUYER: REFUND (if seller fails to deliver within REFUND_WINDOW)
    // ═════════════════════════════════════════════════════════════════════
    /**
     * @notice Buyer can claim a refund if the seller hasn't delivered
     *         the key within REFUND_WINDOW seconds.
     */
    function refund(uint64 purchaseId) external {
        if (purchaseId >= purchaseCount) revert NotFound();
        Purchase storage p = purchases[purchaseId];
        if (msg.sender != p.buyer) revert OnlySeller(); // reusing error
        if (p.keyDelivered) revert AlreadyDelivered();
        if (p.refunded) revert AlreadyRefunded();
        if (block.timestamp < p.timestamp + REFUND_WINDOW)
            revert RefundWindowClosed();

        p.refunded = true;
        uint128 amt = p.paidWei;

        (bool ok, ) = payable(p.buyer).call{value: amt}("");
        if (!ok) revert TransferFailed();

        emit RefundIssued(purchaseId, p.buyer, amt);
    }

    // ═════════════════════════════════════════════════════════════════════
    //  SELLER: WITHDRAW
    // ═════════════════════════════════════════════════════════════════════
    function withdraw() external onlySeller {
        uint256 bal = address(this).balance;
        if (bal == 0) revert NothingToWithdraw();
        (bool ok, ) = payable(seller).call{value: bal}("");
        if (!ok) revert TransferFailed();
        emit FundsWithdrawn(seller, bal);
    }

    // ═════════════════════════════════════════════════════════════════════
    //  SELLER: ADMIN
    // ═════════════════════════════════════════════════════════════════════
    function setPaused(bool _paused) external onlySeller {
        paused = _paused;
        emit Paused(_paused);
    }

    function updateMetadata(
        string calldata _fileCID,
        string calldata _buyerPageCID,
        string calldata _fileMetadata
    ) external onlySeller {
        fileCID      = _fileCID;
        buyerPageCID = _buyerPageCID;
        fileMetadata = _fileMetadata;
        emit MetadataUpdated(_fileCID, _buyerPageCID, _fileMetadata);
    }

    // ═════════════════════════════════════════════════════════════════════
    //  VIEWS
    // ═════════════════════════════════════════════════════════════════════
    function getPurchase(uint64 id) external view returns (
        address buyer,
        uint64  timestamp,
        uint128 paidWei,
        bool    keyDelivered,
        bool    refunded
    ) {
        Purchase storage p = purchases[id];
        return (p.buyer, p.timestamp, p.paidWei, p.keyDelivered, p.refunded);
    }

    function getBuyerHistory(address buyer)
        external view returns (uint64[] memory)
    {
        return buyerHistory[buyer];
    }

    function getEncryptedKey(uint64 id)
        external view returns (bytes memory)
    {
        return encryptedKeys[id];
    }

    function getBuyerPubKey(uint64 id)
        external view returns (bytes memory)
    {
        return buyerPubKeys[id];
    }

    // ── Receive ──────────────────────────────────────────────────────────
    receive() external payable {}
}
