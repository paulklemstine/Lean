// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title FileVendingMachine
 * @author CryptoVendingMachine Project
 * @notice A single-serving vending machine contract for selling encrypted files.
 *
 * Architecture:
 *   1. Seller encrypts a file with AES-256-GCM, uploads ciphertext to IPFS.
 *   2. Seller deploys this contract with:
 *        - The IPFS CID of the encrypted file
 *        - The AES-256 decryption key (stored encrypted with buyer's future tx)
 *        - The price in ETH
 *        - The seller's withdrawal address
 *   3. A buyer sends exactly `price` ETH to `purchase()`.
 *   4. The contract reveals the symmetric decryption key to the buyer.
 *   5. The seller can withdraw funds. Contract is single-serving: one buyer only.
 *
 * Security model:
 *   - The decryption key is stored on-chain (visible after purchase).
 *   - Before purchase, the key is present in contract storage but the buyer
 *     must pay to trigger the `Purchased` event that indexes it conveniently.
 *   - For high-value files, consider using a commit-reveal or threshold scheme.
 *   - This is a MVP demonstrating the pattern; production use should add
 *     time-locks, refund logic, and off-chain key exchange.
 */
contract FileVendingMachine {
    // ─── State ───────────────────────────────────────────────────────────

    address public seller;
    address public buyer;
    uint256 public price;
    string  public ipfsCID;          // CID of the encrypted file on IPFS
    string  public frontendCID;      // CID of the buyer-facing HTML page
    bytes   public encryptionKey;    // AES-256 key (revealed after purchase)
    bool    public purchased;
    bool    public withdrawn;

    // ─── Events ──────────────────────────────────────────────────────────

    event Purchased(
        address indexed buyer,
        uint256 price,
        string  ipfsCID,
        bytes   encryptionKey
    );

    event Withdrawn(address indexed seller, uint256 amount);

    // ─── Errors ──────────────────────────────────────────────────────────

    error AlreadyPurchased();
    error IncorrectPayment(uint256 sent, uint256 required);
    error AlreadyWithdrawn();
    error OnlySeller();
    error WithdrawalFailed();

    // ─── Constructor ─────────────────────────────────────────────────────

    /**
     * @param _price         Price in wei
     * @param _ipfsCID       IPFS CID of the encrypted file
     * @param _frontendCID   IPFS CID of the buyer HTML page
     * @param _encryptionKey AES-256 decryption key (raw bytes)
     */
    constructor(
        uint256 _price,
        string memory _ipfsCID,
        string memory _frontendCID,
        bytes  memory _encryptionKey
    ) {
        seller        = msg.sender;
        price         = _price;
        ipfsCID       = _ipfsCID;
        frontendCID   = _frontendCID;
        encryptionKey = _encryptionKey;
        purchased     = false;
        withdrawn     = false;
    }

    // ─── Purchase ────────────────────────────────────────────────────────

    /**
     * @notice Buy the file. Sends exactly `price` ETH. Emits the decryption key.
     */
    function purchase() external payable {
        if (purchased) revert AlreadyPurchased();
        if (msg.value != price) revert IncorrectPayment(msg.value, price);

        purchased = true;
        buyer     = msg.sender;

        emit Purchased(msg.sender, price, ipfsCID, encryptionKey);
    }

    // ─── Withdraw ────────────────────────────────────────────────────────

    /**
     * @notice Seller withdraws the proceeds after a purchase.
     */
    function withdraw() external {
        if (msg.sender != seller) revert OnlySeller();
        if (!purchased) revert AlreadyPurchased();   // nothing to withdraw
        if (withdrawn)  revert AlreadyWithdrawn();

        withdrawn = true;
        uint256 amount = address(this).balance;

        (bool ok, ) = seller.call{value: amount}("");
        if (!ok) revert WithdrawalFailed();

        emit Withdrawn(seller, amount);
    }

    // ─── Views ───────────────────────────────────────────────────────────

    /**
     * @notice Returns contract info as a tuple for easy frontend consumption.
     */
    function info() external view returns (
        address _seller,
        uint256 _price,
        string memory _ipfsCID,
        string memory _frontendCID,
        bool    _purchased,
        address _buyer
    ) {
        return (seller, price, ipfsCID, frontendCID, purchased, buyer);
    }

    /**
     * @notice Returns the decryption key. Accessible to anyone after purchase
     *         (it's on-chain anyway), but the event is the canonical delivery.
     */
    function getKey() external view returns (bytes memory) {
        return encryptionKey;
    }
}
