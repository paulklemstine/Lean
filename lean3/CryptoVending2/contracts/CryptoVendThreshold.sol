// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title CryptoVendThreshold
 * @author CryptoVending v3 Project
 * @notice Fully automated, serverless file vending machine using threshold cryptography.
 *
 * ═══════════════════════════════════════════════════════════════════════
 *  ARCHITECTURE — Threshold Key Release
 * ═══════════════════════════════════════════════════════════════════════
 *
 *  The seller's AES key is split into N shares via Shamir's Secret
 *  Sharing with threshold t. Each share is entrusted to an independent
 *  oracle node. After setup, the seller goes offline permanently.
 *
 *  ┌─────────┐   setup    ┌──────────────┐
 *  │  Seller  │──────────▶│  This Contract│
 *  │  (once)  │           │  (L2 chain)   │
 *  └─────────┘           └──────┬───────┘
 *       │                        │
 *       │ shares (ECIES)         │ payment verification
 *       ▼                        ▼
 *  ┌─────────────┐        ┌────────────┐
 *  │ Oracle Nodes │◀──────│   Buyer     │
 *  │  (1..N)      │ query │  (IPFS page)│
 *  │  serverless  │──────▶│             │
 *  └─────────────┘ share  └────────────┘
 *
 *  Flow:
 *    1. Seller encrypts file with AES-256-GCM, uploads to IPFS
 *    2. Seller splits AES key into (t, N) Shamir shares
 *    3. Seller encrypts each share with its oracle's public key (ECIES)
 *    4. Seller deploys this contract with share commitments + oracle info
 *    5. Seller uploads encrypted shares to IPFS, stores CIDs in contract
 *    6. Seller pins buyer page to IPFS → DONE. Seller goes offline.
 *    7. Buyer visits IPFS page, pays via MetaMask
 *    8. Buyer contacts each oracle endpoint with contract + purchaseId
 *    9. Each oracle verifies on-chain payment, re-encrypts its share
 *       for the buyer's ECIES public key, returns it
 *   10. Buyer collects t shares, reconstructs AES key via Lagrange
 *   11. Buyer downloads encrypted file from IPFS, decrypts locally
 *
 *  KEY PROPERTIES:
 *    - No single oracle knows the full AES key
 *    - Any t-of-N oracles suffice (fault tolerance)
 *    - Seller is offline after setup (fully serverless)
 *    - All state is on-chain + IPFS (idempotent)
 *    - Oracle nodes are stateless (derive share from IPFS + own key)
 *
 * ═══════════════════════════════════════════════════════════════════════
 */
contract CryptoVendThreshold {
    // ── Constants ────────────────────────────────────────────────────────
    uint256 public constant VERSION = 3;
    uint256 public constant REFUND_WINDOW = 1 hours;

    // ── Immutables ───────────────────────────────────────────────────────
    address public immutable seller;
    uint256 public immutable price;
    bytes32 public immutable keyCommitment;   // keccak256(aesKey)
    uint8   public immutable threshold;       // t — minimum shares needed
    uint8   public immutable numOracles;      // N — total oracle count

    // ── Storage ──────────────────────────────────────────────────────────
    string  public fileCID;          // IPFS CID of encrypted file
    string  public buyerPageCID;     // IPFS CID of buyer HTML page
    string  public fileMetadata;     // JSON: {name, size, type, description}
    bool    public paused;

    // ── Oracle Registry ──────────────────────────────────────────────────
    struct Oracle {
        address addr;                // Oracle's Ethereum address
        bytes32 shareCommitment;     // keccak256(raw_share_bytes)
        string  shareCID;            // IPFS CID of ECIES-encrypted share
        string  endpoint;            // HTTP endpoint URL for share requests
    }

    mapping(uint8 => Oracle) public oracles;  // index → Oracle

    // ── Purchase Tracking ────────────────────────────────────────────────
    struct Purchase {
        address buyer;
        uint64  timestamp;
        uint128 paidWei;
        bool    refunded;
    }

    uint64 public purchaseCount;
    mapping(uint64 => Purchase)    public purchases;
    mapping(uint64 => bytes)       public buyerPubKeys;
    mapping(address => uint64[])   public buyerHistory;

    // ── Sales Stats ──────────────────────────────────────────────────────
    uint256 public totalRevenue;
    uint256 public totalSales;

    // ── Events ───────────────────────────────────────────────────────────
    event PurchaseConfirmed(
        uint64  indexed purchaseId,
        address indexed buyer,
        bytes   buyerPublicKey,
        uint128 amount
    );

    event RefundIssued(
        uint64  indexed purchaseId,
        address indexed buyer,
        uint128 amount
    );

    event FundsWithdrawn(address indexed to, uint256 amount);
    event Paused(bool state);
    event MetadataUpdated(string fileCID, string buyerPageCID, string fileMetadata);
    event OracleRegistered(uint8 indexed index, address oracle, string endpoint);

    // ── Errors ───────────────────────────────────────────────────────────
    error InsufficientPayment();
    error ContractPaused();
    error OnlySeller();
    error InvalidPubKey();
    error NotFound();
    error AlreadyRefunded();
    error RefundWindowOpen();
    error RefundWindowClosed();
    error NothingToWithdraw();
    error TransferFailed();
    error InvalidThreshold();
    error OracleAlreadySet();

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
        uint8         _threshold,
        uint8         _numOracles,
        string memory _fileCID,
        string memory _fileMetadata
    ) {
        if (_threshold == 0 || _threshold > _numOracles) revert InvalidThreshold();

        seller        = msg.sender;
        price         = _price;
        keyCommitment = _keyCommitment;
        threshold     = _threshold;
        numOracles    = _numOracles;
        fileCID       = _fileCID;
        fileMetadata  = _fileMetadata;
    }

    // ═════════════════════════════════════════════════════════════════════
    //  SELLER: REGISTER ORACLES (one-time setup, then seller goes offline)
    // ═════════════════════════════════════════════════════════════════════
    /**
     * @notice Register an oracle node with its share commitment and endpoint.
     *         Called once per oracle during initial setup.
     * @param index         Oracle index (0 to numOracles-1)
     * @param oracleAddr    Oracle's Ethereum address
     * @param shareCommit   keccak256(raw_share_bytes) for buyer-side verification
     * @param shareCID      IPFS CID of the ECIES-encrypted share blob
     * @param endpoint      HTTP endpoint URL where oracle serves share requests
     */
    function registerOracle(
        uint8         index,
        address       oracleAddr,
        bytes32       shareCommit,
        string calldata shareCID,
        string calldata endpoint
    ) external onlySeller {
        if (index >= numOracles) revert NotFound();
        if (oracles[index].addr != address(0)) revert OracleAlreadySet();

        oracles[index] = Oracle({
            addr:            oracleAddr,
            shareCommitment: shareCommit,
            shareCID:        shareCID,
            endpoint:        endpoint
        });

        emit OracleRegistered(index, oracleAddr, endpoint);
    }

    /**
     * @notice Set the buyer page CID after all oracles are registered.
     */
    function setBuyerPageCID(string calldata _buyerPageCID) external onlySeller {
        buyerPageCID = _buyerPageCID;
        emit MetadataUpdated(fileCID, _buyerPageCID, fileMetadata);
    }

    // ═════════════════════════════════════════════════════════════════════
    //  BUYER: PURCHASE
    // ═════════════════════════════════════════════════════════════════════
    /**
     * @notice Buy the file. Send >= `price` wei with your 65-byte
     *         uncompressed secp256k1 public key for share encryption.
     * @param pubKey 65-byte uncompressed ECIES public key (0x04 || x || y)
     */
    function purchase(bytes calldata pubKey) external payable {
        if (paused) revert ContractPaused();
        if (msg.value < price) revert InsufficientPayment();
        if (pubKey.length != 65) revert InvalidPubKey();

        uint64 id = purchaseCount++;

        purchases[id] = Purchase({
            buyer:     msg.sender,
            timestamp: uint64(block.timestamp),
            paidWei:   uint128(msg.value),
            refunded:  false
        });

        buyerPubKeys[id] = pubKey;
        buyerHistory[msg.sender].push(id);
        totalSales++;
        totalRevenue += msg.value;

        emit PurchaseConfirmed(id, msg.sender, pubKey, uint128(msg.value));
    }

    // ═════════════════════════════════════════════════════════════════════
    //  BUYER: REFUND (if shares cannot be collected within REFUND_WINDOW)
    // ═════════════════════════════════════════════════════════════════════
    function refund(uint64 purchaseId) external {
        if (purchaseId >= purchaseCount) revert NotFound();
        Purchase storage p = purchases[purchaseId];
        if (msg.sender != p.buyer) revert OnlySeller();
        if (p.refunded) revert AlreadyRefunded();
        if (block.timestamp < p.timestamp + REFUND_WINDOW)
            revert RefundWindowClosed();

        p.refunded = true;
        totalRevenue -= p.paidWei;
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

    // ═════════════════════════════════════════════════════════════════════
    //  VIEWS
    // ═════════════════════════════════════════════════════════════════════
    function getPurchase(uint64 id) external view returns (
        address buyer,
        uint64  timestamp,
        uint128 paidWei,
        bool    refunded
    ) {
        Purchase storage p = purchases[id];
        return (p.buyer, p.timestamp, p.paidWei, p.refunded);
    }

    function getBuyerHistory(address buyer)
        external view returns (uint64[] memory)
    {
        return buyerHistory[buyer];
    }

    function getBuyerPubKey(uint64 id)
        external view returns (bytes memory)
    {
        return buyerPubKeys[id];
    }

    function getOracle(uint8 index) external view returns (
        address addr,
        bytes32 shareCommitment,
        string memory shareCID,
        string memory endpoint
    ) {
        Oracle storage o = oracles[index];
        return (o.addr, o.shareCommitment, o.shareCID, o.endpoint);
    }

    /**
     * @notice Verify that a purchase is valid and paid (used by oracle nodes).
     * @return valid    True if purchase exists, is paid, and not refunded
     * @return buyer    The buyer's address
     * @return pubKey   The buyer's ECIES public key
     */
    function verifyPurchase(uint64 id) external view returns (
        bool    valid,
        address buyer,
        bytes memory pubKey
    ) {
        if (id >= purchaseCount) return (false, address(0), "");
        Purchase storage p = purchases[id];
        if (p.refunded) return (false, p.buyer, "");
        return (true, p.buyer, buyerPubKeys[id]);
    }

    // ── Receive ──────────────────────────────────────────────────────────
    receive() external payable {}
}
