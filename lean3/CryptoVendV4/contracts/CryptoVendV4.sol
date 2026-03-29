// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title CryptoVendV4
 * @author CryptoVend v4 Project
 * @notice Fully autonomous digital file vending machine with smart-contract oracle nodes.
 *
 * ═══════════════════════════════════════════════════════════════════════
 *  ARCHITECTURE — Smart Contract Oracle Network
 * ═══════════════════════════════════════════════════════════════════════
 *
 *  CryptoVend v4 eliminates the last piece of off-chain infrastructure:
 *  the oracle HTTP endpoints. Every component is now either a smart
 *  contract or content-addressed IPFS data.
 *
 *  v3: Oracle nodes = HTTP servers (serverless functions, browser tabs)
 *  v4: Oracle nodes = Smart contracts (OracleNode.sol instances)
 *
 *  The seller deploys this contract + N OracleNode contracts, publishes
 *  the buyer page to IPFS, and is done. Permanently. The entire system
 *  runs autonomously on-chain + IPFS forever.
 *
 *  ┌─────────┐                    ┌──────────────────┐
 *  │  Seller  │  deploy (once)    │  CryptoVendV4    │
 *  │  (gone)  │──────────────────▶│  (this contract)  │
 *  └────┬─────┘                   │                  │
 *       │                         │  • Product info  │
 *       │ deploy N oracles        │  • Price & payment│
 *       │                         │  • Purchase log  │
 *       ▼                         │  • Oracle registry│
 *  ┌─────────────────┐           └────────┬─────────┘
 *  │  OracleNode[0]  │                    │
 *  │  OracleNode[1]  │                    │ verifyPurchase()
 *  │  OracleNode[2]  │◀───────────────────┤
 *  │       ...       │                    │
 *  │  OracleNode[N-1]│                    │
 *  └────────┬────────┘           ┌────────┴─────────┐
 *           │ getShare()         │     Buyer Page    │
 *           │ (view, 0 gas)      │     (IPFS)        │
 *           └───────────────────▶│                  │
 *                                │  • Pay contract  │
 *                                │  • eth_call oracles│
 *                                │  • Reconstruct key│
 *                                │  • Decrypt file  │
 *                                └──────────────────┘
 *
 *  WHAT THE SELLER DOES (once, ~5 minutes):
 *    1. Open seller.html in browser
 *    2. Select file, set price, configure threshold
 *    3. Click Deploy — browser handles everything:
 *       - Encrypts file with AES-256-GCM
 *       - Splits key via Shamir's Secret Sharing
 *       - Deploys this contract
 *       - Deploys N OracleNode contracts (one per share)
 *       - Registers oracles in this contract
 *       - Uploads encrypted file + buyer page to IPFS
 *    4. Close the browser. Done forever. ✨
 *
 *  WHAT THE BUYER DOES:
 *    1. Visit IPFS buyer page
 *    2. Pay via MetaMask
 *    3. Page calls each OracleNode.getShare() via eth_call (free)
 *    4. Page reconstructs AES key via Lagrange interpolation
 *    5. Page downloads + decrypts file from IPFS
 *    Total time: ~15 seconds. No humans involved.
 *
 *  INFRASTRUCTURE REQUIRED: None.
 *    - Smart contracts are permanent (as long as the chain runs)
 *    - IPFS content is permanent (as long as one node pins it)
 *    - No servers. No domains. No APIs. No maintenance.
 *
 * ═══════════════════════════════════════════════════════════════════════
 */
contract CryptoVendV4 {
    // ── Constants ────────────────────────────────────────────────────────
    uint256 public constant VERSION = 4;
    uint256 public constant REFUND_WINDOW = 1 hours;

    // ── Immutables ───────────────────────────────────────────────────────
    address public immutable seller;
    uint256 public immutable price;
    bytes32 public immutable keyCommitment;   // keccak256(aesKey)
    uint8   public immutable threshold;       // t — minimum shares needed
    uint8   public immutable numOracles;      // N — total oracle contracts

    // ── Storage ──────────────────────────────────────────────────────────
    string  public fileCID;          // IPFS CID of encrypted file
    string  public buyerPageCID;     // IPFS CID of buyer HTML page
    string  public fileMetadata;     // JSON: {name, size, type, description}
    bool    public paused;
    bool    public setupComplete;    // True when all oracles registered

    // ── Oracle Registry (contracts, not endpoints!) ──────────────────────
    struct OracleInfo {
        address contractAddr;        // OracleNode contract address
        bytes32 shareCommitment;     // keccak256(raw_share_bytes)
        uint8   shareIndex;          // Shamir x-coordinate
    }

    OracleInfo[] public oracleRegistry;

    // ── Purchase Tracking ────────────────────────────────────────────────
    struct Purchase {
        address buyer;
        uint64  timestamp;
        uint128 paidWei;
        bool    refunded;
    }

    uint64 public purchaseCount;
    mapping(uint64 => Purchase)    public purchases;
    mapping(address => uint64[])   public buyerHistory;

    // ── Sales Stats ──────────────────────────────────────────────────────
    uint256 public totalRevenue;
    uint256 public totalSales;

    // ── Events ───────────────────────────────────────────────────────────
    event PurchaseConfirmed(
        uint64  indexed purchaseId,
        address indexed buyer,
        uint128 amount
    );

    event RefundIssued(
        uint64  indexed purchaseId,
        address indexed buyer,
        uint128 amount
    );

    event OracleRegistered(
        uint8   indexed index,
        address contractAddr,
        bytes32 shareCommitment
    );

    event SetupCompleted(uint8 oracleCount);
    event FundsWithdrawn(address indexed to, uint256 amount);
    event Paused(bool state);
    event MetadataUpdated(string fileCID, string buyerPageCID);

    // ── Errors ───────────────────────────────────────────────────────────
    error InsufficientPayment();
    error ContractPaused();
    error SetupNotComplete();
    error OnlySeller();
    error NotFound();
    error AlreadyRefunded();
    error RefundWindowClosed();
    error NothingToWithdraw();
    error TransferFailed();
    error InvalidThreshold();
    error TooManyOracles();
    error SetupAlreadyComplete();
    error InvalidOracleContract();

    // ── Modifiers ────────────────────────────────────────────────────────
    modifier onlySeller() {
        if (msg.sender != seller) revert OnlySeller();
        _;
    }

    // ═════════════════════════════════════════════════════════════════════
    //  CONSTRUCTOR
    // ═════════════════════════════════════════════════════════════════════
    /**
     * @param _price          Price in wei
     * @param _keyCommitment  keccak256(aesKey) for buyer verification
     * @param _threshold      Minimum shares needed (t)
     * @param _numOracles     Total oracle contracts (N)
     * @param _fileCID        IPFS CID of encrypted file
     * @param _fileMetadata   JSON metadata: {name, size, type, description}
     */
    constructor(
        uint256       _price,
        bytes32       _keyCommitment,
        uint8         _threshold,
        uint8         _numOracles,
        string memory _fileCID,
        string memory _fileMetadata
    ) {
        if (_threshold == 0 || _threshold > _numOracles) revert InvalidThreshold();
        if (_numOracles > 25) revert TooManyOracles();

        seller        = msg.sender;
        price         = _price;
        keyCommitment = _keyCommitment;
        threshold     = _threshold;
        numOracles    = _numOracles;
        fileCID       = _fileCID;
        fileMetadata  = _fileMetadata;
    }

    // ═════════════════════════════════════════════════════════════════════
    //  SELLER: REGISTER ORACLE CONTRACTS (one-time setup)
    // ═════════════════════════════════════════════════════════════════════
    /**
     * @notice Register a deployed OracleNode contract.
     *         Called once per oracle during initial setup.
     *         After all N oracles are registered, setup is marked complete.
     *
     * @param _oracleContract  Address of the deployed OracleNode
     * @param _shareCommitment keccak256(raw_share_bytes)
     * @param _shareIndex      Shamir x-coordinate (1..N)
     */
    function registerOracle(
        address _oracleContract,
        bytes32 _shareCommitment,
        uint8   _shareIndex
    ) external onlySeller {
        if (setupComplete) revert SetupAlreadyComplete();
        if (_oracleContract == address(0)) revert InvalidOracleContract();
        if (oracleRegistry.length >= numOracles) revert TooManyOracles();

        // Verify the oracle contract points back to us
        // (basic sanity check — the oracle's vendingContract should match)
        try IOracleNode(_oracleContract).info() returns (
            address vending, uint8, bytes32, uint256
        ) {
            if (vending != address(this)) revert InvalidOracleContract();
        } catch {
            revert InvalidOracleContract();
        }

        oracleRegistry.push(OracleInfo({
            contractAddr:    _oracleContract,
            shareCommitment: _shareCommitment,
            shareIndex:      _shareIndex
        }));

        emit OracleRegistered(
            uint8(oracleRegistry.length - 1),
            _oracleContract,
            _shareCommitment
        );

        // Auto-finalize when all oracles are registered
        if (oracleRegistry.length == numOracles) {
            setupComplete = true;
            emit SetupCompleted(numOracles);
        }
    }

    /**
     * @notice Set the buyer page CID. Can be called before or after setup.
     */
    function setBuyerPageCID(string calldata _buyerPageCID) external onlySeller {
        buyerPageCID = _buyerPageCID;
        emit MetadataUpdated(fileCID, _buyerPageCID);
    }

    // ═════════════════════════════════════════════════════════════════════
    //  BUYER: PURCHASE
    // ═════════════════════════════════════════════════════════════════════
    /**
     * @notice Buy the file. Send >= `price` wei.
     *         After purchase, call each OracleNode.getShare() via eth_call
     *         to collect your key shares.
     */
    function purchase() external payable {
        if (paused) revert ContractPaused();
        if (!setupComplete) revert SetupNotComplete();
        if (msg.value < price) revert InsufficientPayment();

        uint64 id = purchaseCount++;

        purchases[id] = Purchase({
            buyer:     msg.sender,
            timestamp: uint64(block.timestamp),
            paidWei:   uint128(msg.value),
            refunded:  false
        });

        buyerHistory[msg.sender].push(id);
        totalSales++;
        totalRevenue += msg.value;

        emit PurchaseConfirmed(id, msg.sender, uint128(msg.value));
    }

    // ═════════════════════════════════════════════════════════════════════
    //  BUYER: REFUND
    // ═════════════════════════════════════════════════════════════════════
    /**
     * @notice Request a refund if shares couldn't be collected.
     *         Only available after REFUND_WINDOW has elapsed.
     */
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
    //  ORACLE INTERFACE: VERIFY PURCHASE
    // ═════════════════════════════════════════════════════════════════════
    /**
     * @notice Called by OracleNode contracts to verify a purchase.
     *         Returns whether the purchase is valid and the buyer's address.
     *
     * @param id  Purchase ID
     * @return valid   True if purchase exists, is paid, and not refunded
     * @return buyer   The buyer's address
     * @return pubKey  Empty bytes (v4 doesn't need ECIES — shares are
     *                 returned directly via eth_call over HTTPS)
     */
    function verifyPurchase(uint64 id) external view returns (
        bool    valid,
        address buyer,
        bytes memory pubKey
    ) {
        if (id >= purchaseCount) return (false, address(0), "");
        Purchase storage p = purchases[id];
        if (p.refunded) return (false, p.buyer, "");
        return (true, p.buyer, "");
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
        if (id >= purchaseCount) revert NotFound();
        Purchase storage p = purchases[id];
        return (p.buyer, p.timestamp, p.paidWei, p.refunded);
    }

    function getBuyerHistory(address buyer)
        external view returns (uint64[] memory)
    {
        return buyerHistory[buyer];
    }

    /**
     * @notice Get all oracle contract addresses.
     *         Buyer page calls this to know which OracleNode contracts to query.
     */
    function getOracles() external view returns (
        address[] memory addrs,
        bytes32[] memory commitments,
        uint8[]   memory indices
    ) {
        uint256 len = oracleRegistry.length;
        addrs       = new address[](len);
        commitments = new bytes32[](len);
        indices     = new uint8[](len);

        for (uint256 i = 0; i < len; i++) {
            addrs[i]       = oracleRegistry[i].contractAddr;
            commitments[i] = oracleRegistry[i].shareCommitment;
            indices[i]     = oracleRegistry[i].shareIndex;
        }
    }

    /**
     * @notice Get a single oracle's info by registry index.
     */
    function getOracle(uint8 registryIndex) external view returns (
        address contractAddr,
        bytes32 shareCommitment,
        uint8   shareIndex
    ) {
        if (registryIndex >= oracleRegistry.length) revert NotFound();
        OracleInfo storage o = oracleRegistry[registryIndex];
        return (o.contractAddr, o.shareCommitment, o.shareIndex);
    }

    /**
     * @notice Summary of contract state for buyer page display.
     */
    function summary() external view returns (
        uint256 _price,
        bytes32 _keyCommitment,
        uint8   _threshold,
        uint8   _numOracles,
        string memory _fileCID,
        string memory _fileMetadata,
        string memory _buyerPageCID,
        bool    _setupComplete,
        bool    _paused,
        uint64  _purchaseCount,
        uint256 _totalSales
    ) {
        return (
            price, keyCommitment, threshold, numOracles,
            fileCID, fileMetadata, buyerPageCID,
            setupComplete, paused, purchaseCount, totalSales
        );
    }

    // ── Receive ──────────────────────────────────────────────────────────
    receive() external payable {}
}

// ── Interface for OracleNode verification ────────────────────────────────
interface IOracleNode {
    function info() external view returns (
        address vending, uint8 index, bytes32 commitment, uint256 version
    );
    function getShare(uint64 purchaseId) external view returns (
        bytes memory shareData, uint8 index
    );
}
