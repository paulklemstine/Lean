// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title FileVendingMachine
 * @notice A single-serving decentralized file vending machine.
 *
 * Architecture:
 *   1. Seller encrypts a file with AES-256-GCM, uploads ciphertext to IPFS.
 *   2. This contract is deployed with the IPFS CID, price, and a hash
 *      commitment of the AES key.
 *   3. A buyer sends >= price ETH together with their ECIES public key
 *      (an uncompressed secp256k1 point, 65 bytes).
 *   4. The contract emits `PurchaseInitiated`.
 *   5. The seller's watcher encrypts the AES key with the buyer's public key
 *      (ECIES) and calls `deliverKey`.
 *   6. The contract emits `KeyDelivered`; the buyer's front-end decrypts
 *      the AES key with their private key, fetches the file from IPFS,
 *      and decrypts it locally.
 *
 * The AES key never appears on-chain in the clear.
 */
contract FileVendingMachine {
    // ── State ────────────────────────────────────────────────────────────
    address public immutable seller;
    string  public fileCID;          // IPFS CID of the encrypted file
    string  public metadataCID;      // IPFS CID of the buyer HTML page
    uint256 public price;            // price in wei
    bytes32 public keyCommitment;    // keccak256(aesKey)
    bool    public isSingleServing;  // if true, only one purchase allowed
    bool    public sold;             // whether a single-serving item was sold

    struct Purchase {
        address buyer;
        bytes   buyerPublicKey;  // 65-byte uncompressed secp256k1 pubkey
        bytes   encryptedKey;    // ECIES-encrypted AES key (set by seller)
        bool    keyDelivered;
        uint256 paidAmount;
        uint256 timestamp;
    }

    uint256 public purchaseCount;
    mapping(uint256 => Purchase) public purchases;
    mapping(address => uint256[]) public buyerPurchases;

    // ── Events ───────────────────────────────────────────────────────────
    event PurchaseInitiated(
        uint256 indexed purchaseId,
        address indexed buyer,
        bytes   buyerPublicKey,
        uint256 amount
    );

    event KeyDelivered(
        uint256 indexed purchaseId,
        address indexed buyer,
        bytes   encryptedKey
    );

    event FundsWithdrawn(address indexed seller, uint256 amount);
    event PriceUpdated(uint256 oldPrice, uint256 newPrice);

    // ── Errors ───────────────────────────────────────────────────────────
    error InsufficientPayment(uint256 required, uint256 sent);
    error AlreadySold();
    error OnlySeller();
    error InvalidPublicKey();
    error PurchaseNotFound();
    error KeyAlreadyDelivered();
    error NothingToWithdraw();

    // ── Modifiers ────────────────────────────────────────────────────────
    modifier onlySeller() {
        if (msg.sender != seller) revert OnlySeller();
        _;
    }

    // ── Constructor ──────────────────────────────────────────────────────
    constructor(
        string memory _fileCID,
        string memory _metadataCID,
        uint256       _price,
        bytes32       _keyCommitment,
        bool          _isSingleServing
    ) {
        seller          = msg.sender;
        fileCID         = _fileCID;
        metadataCID     = _metadataCID;
        price           = _price;
        keyCommitment   = _keyCommitment;
        isSingleServing = _isSingleServing;
    }

    // ── Purchase ─────────────────────────────────────────────────────────
    /**
     * @notice Buy the file.  Send >= `price` wei and include your 65-byte
     *         uncompressed secp256k1 public key so the seller can encrypt
     *         the decryption key for you.
     */
    function purchase(bytes calldata buyerPublicKey) external payable {
        if (msg.value < price)
            revert InsufficientPayment(price, msg.value);
        if (isSingleServing && sold)
            revert AlreadySold();
        if (buyerPublicKey.length != 65)
            revert InvalidPublicKey();

        uint256 id = purchaseCount++;
        purchases[id] = Purchase({
            buyer:          msg.sender,
            buyerPublicKey: buyerPublicKey,
            encryptedKey:   "",
            keyDelivered:   false,
            paidAmount:     msg.value,
            timestamp:      block.timestamp
        });
        buyerPurchases[msg.sender].push(id);

        if (isSingleServing) sold = true;

        emit PurchaseInitiated(id, msg.sender, buyerPublicKey, msg.value);
    }

    // ── Key delivery (seller) ────────────────────────────────────────────
    /**
     * @notice Seller delivers the AES key encrypted with the buyer's
     *         public key (ECIES ciphertext).
     */
    function deliverKey(
        uint256 purchaseId,
        bytes calldata encryptedKey
    ) external onlySeller {
        if (purchaseId >= purchaseCount) revert PurchaseNotFound();
        Purchase storage p = purchases[purchaseId];
        if (p.keyDelivered) revert KeyAlreadyDelivered();

        p.encryptedKey  = encryptedKey;
        p.keyDelivered  = true;

        emit KeyDelivered(purchaseId, p.buyer, encryptedKey);
    }

    // ── Queries ──────────────────────────────────────────────────────────
    function getEncryptedKey(uint256 purchaseId)
        external view returns (bytes memory)
    {
        if (purchaseId >= purchaseCount) revert PurchaseNotFound();
        return purchases[purchaseId].encryptedKey;
    }

    function getBuyerPurchaseIds(address buyer)
        external view returns (uint256[] memory)
    {
        return buyerPurchases[buyer];
    }

    // ── Withdraw ─────────────────────────────────────────────────────────
    function withdraw() external onlySeller {
        uint256 balance = address(this).balance;
        if (balance == 0) revert NothingToWithdraw();
        payable(seller).transfer(balance);
        emit FundsWithdrawn(seller, balance);
    }

    // ── Admin ────────────────────────────────────────────────────────────
    function updatePrice(uint256 newPrice) external onlySeller {
        uint256 old = price;
        price = newPrice;
        emit PriceUpdated(old, newPrice);
    }

    // ── Receive ETH (fallback) ───────────────────────────────────────────
    receive() external payable {}
}
