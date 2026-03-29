// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title OracleNode
 * @author CryptoVend v4 Project
 * @notice Autonomous oracle smart contract that holds one Shamir share.
 *
 * ═══════════════════════════════════════════════════════════════════════
 *  THE ORACLE IS THE CONTRACT
 * ═══════════════════════════════════════════════════════════════════════
 *
 *  In CryptoVend v3, oracle nodes were HTTP endpoints — servers that
 *  had to stay running. In v4, each oracle IS a smart contract:
 *
 *    • Deployed once by the seller alongside the main vending contract
 *    • Stores one Shamir secret share (obfuscated in storage)
 *    • Verifies buyer payment by calling the main vending contract
 *    • Returns the share via a view function (eth_call) — zero gas
 *    • Immutable, unstoppable, permanent — runs as long as the chain
 *    • No hosting, no servers, no browser tabs, no serverless functions
 *
 *  ┌─────────┐  deploy   ┌──────────────┐
 *  │  Seller  │──────────▶│  OracleNode  │
 *  │  (once)  │           │  (on-chain)  │
 *  └─────────┘           └──────┬───────┘
 *                                │ eth_call (view, free)
 *                                │ verifies payment
 *                                │ returns share
 *                                ▼
 *                         ┌────────────┐
 *                         │   Buyer    │
 *                         │  (browser) │
 *                         └────────────┘
 *
 *  STORAGE OBFUSCATION:
 *    The share is stored XOR'd with a key derived from the contract's
 *    own address and a seller-provided salt. Reading raw storage yields
 *    only the obfuscated value. The deobfuscation key is derived at
 *    runtime in the view function, so the plaintext share never appears
 *    in any storage slot. While not cryptographically unbreakable (a
 *    determined attacker who reads storage AND reverse-engineers the
 *    contract could reconstruct the key), this provides practical
 *    security for digital goods — especially combined with the threshold
 *    requirement that t-of-N shares must be collected.
 *
 * ═══════════════════════════════════════════════════════════════════════
 */

interface ICryptoVendV4 {
    function verifyPurchase(uint64 id) external view returns (
        bool valid, address buyer, bytes memory pubKey
    );
}

contract OracleNode {
    // ── Constants ────────────────────────────────────────────────────────
    uint256 public constant VERSION = 4;

    // ── Immutables ───────────────────────────────────────────────────────
    address public immutable vendingContract;   // Main CryptoVendV4 address
    uint8   public immutable shareIndex;        // x-coordinate in Shamir's scheme (1..N)
    bytes32 public immutable shareCommitment;   // keccak256(plaintext_share)
    bytes32 public immutable obfuscationSalt;   // Salt used for storage obfuscation

    // ── Storage (obfuscated) ─────────────────────────────────────────────
    // The share is stored as: obfuscatedShare = plainShare XOR obfuscationMask
    // where obfuscationMask = keccak256(abi.encodePacked(obfuscationSalt, address(this), vendingContract))
    // This ensures reading raw storage yields only the obfuscated value.
    bytes32 private obfuscatedShareHi;   // First 32 bytes (or full share if <= 32 bytes)
    bytes32 private obfuscatedShareLo;   // Second 32 bytes (for AES-256 = exactly 32B, this is zero-padded)
    uint8   private shareLength;         // Actual share length in bytes

    // ── Events ───────────────────────────────────────────────────────────
    event ShareServed(uint64 indexed purchaseId, address indexed buyer);

    // ── Errors ───────────────────────────────────────────────────────────
    error InvalidPurchase();
    error ShareTooLong();

    // ═════════════════════════════════════════════════════════════════════
    //  CONSTRUCTOR — Deploy once, serve forever
    // ═════════════════════════════════════════════════════════════════════
    /**
     * @param _vendingContract  Address of the main CryptoVendV4 contract
     * @param _shareIndex       Shamir x-coordinate (1-indexed: 1, 2, ..., N)
     * @param _shareData        Raw Shamir share bytes
     * @param _shareCommitment  keccak256(shareData) for buyer-side verification
     * @param _salt             Random salt for storage obfuscation
     */
    constructor(
        address _vendingContract,
        uint8   _shareIndex,
        bytes memory _shareData,
        bytes32 _shareCommitment,
        bytes32 _salt
    ) {
        if (_shareData.length > 64) revert ShareTooLong();

        vendingContract  = _vendingContract;
        shareIndex       = _shareIndex;
        shareCommitment  = _shareCommitment;
        obfuscationSalt  = _salt;
        shareLength      = uint8(_shareData.length);

        // Compute obfuscation masks
        bytes32 maskHi = _computeMaskHi(_vendingContract, _salt);
        bytes32 maskLo = _computeMaskLo(_vendingContract, _salt);

        // Pad share data to 64 bytes and XOR with masks
        bytes32 hi;
        bytes32 lo;
        assembly {
            hi := mload(add(_shareData, 32))
            // Only read lo if share is longer than 32 bytes
            if gt(mload(_shareData), 32) {
                lo := mload(add(_shareData, 64))
            }
        }

        obfuscatedShareHi = hi ^ maskHi;
        obfuscatedShareLo = lo ^ maskLo;
    }

    // ═════════════════════════════════════════════════════════════════════
    //  CORE: GET SHARE (view function — zero gas via eth_call)
    // ═════════════════════════════════════════════════════════════════════
    /**
     * @notice Retrieve the Shamir share for a verified purchase.
     *         Called via eth_call (off-chain) — costs zero gas.
     *         Verifies payment on the main vending contract before returning.
     *
     * @param purchaseId  The purchase ID from the main vending contract
     * @return shareData  The plaintext Shamir share bytes
     * @return index      The share's x-coordinate (for Lagrange interpolation)
     */
    function getShare(uint64 purchaseId) external view returns (
        bytes memory shareData,
        uint8 index
    ) {
        // Verify purchase on the main vending contract
        (bool valid, , ) = ICryptoVendV4(vendingContract).verifyPurchase(purchaseId);
        if (!valid) revert InvalidPurchase();

        // Deobfuscate the share
        bytes32 maskHi = _computeMaskHi(vendingContract, obfuscationSalt);
        bytes32 maskLo = _computeMaskLo(vendingContract, obfuscationSalt);

        bytes32 hi = obfuscatedShareHi ^ maskHi;
        bytes32 lo = obfuscatedShareLo ^ maskLo;

        // Pack into bytes of the correct length
        uint8 len = shareLength;
        shareData = new bytes(len);
        assembly {
            mstore(add(shareData, 32), hi)
            if gt(len, 32) {
                mstore(add(shareData, 64), lo)
            }
        }

        return (shareData, shareIndex);
    }

    /**
     * @notice Check if this oracle would serve a share for a given purchase.
     *         Useful for buyer-side pre-flight checks.
     */
    function canServe(uint64 purchaseId) external view returns (bool) {
        (bool valid, , ) = ICryptoVendV4(vendingContract).verifyPurchase(purchaseId);
        return valid;
    }

    /**
     * @notice Get oracle metadata without retrieving the share.
     */
    function info() external view returns (
        address vending,
        uint8   index,
        bytes32 commitment,
        uint256 version
    ) {
        return (vendingContract, shareIndex, shareCommitment, VERSION);
    }

    // ── Internal: Obfuscation mask computation ───────────────────────────
    function _computeMaskHi(address _vending, bytes32 _salt) internal view returns (bytes32) {
        return keccak256(abi.encodePacked(_salt, address(this), _vending, uint8(0)));
    }

    function _computeMaskLo(address _vending, bytes32 _salt) internal view returns (bytes32) {
        return keccak256(abi.encodePacked(_salt, address(this), _vending, uint8(1)));
    }
}
