// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title PayToDecrypt
 * @author Oracle Council Research
 * @notice Atomic information-money swap using Hash Time-Locked Contracts (HTLC)
 *
 * @dev This contract enables trustless sale of encrypted information on Ethereum.
 *
 * MECHANISM:
 *   1. Seller encrypts payload P with random key K → ciphertext C
 *   2. Seller creates listing with H = keccak256(K), stores C off-chain (e.g., IPFS)
 *   3. Buyer funds the listing by sending ETH (held in escrow)
 *   4. Seller reveals K on-chain to claim payment
 *   5. Contract verifies keccak256(K) == H, then transfers ETH to seller
 *   6. Buyer reads K from the KeyRevealed event and decrypts C
 *
 * SECURITY PROPERTIES:
 *   - Seller MUST reveal the correct key to receive payment (hash-locked)
 *   - Buyer's ETH is refundable if seller doesn't reveal before timeout (time-locked)
 *   - Atomic: either both parties get what they want, or neither does
 *
 * KNOWN LIMITATIONS:
 *   - Key is visible in mempool before mining (use Flashbots for privacy)
 *   - Content quality is not verified (buyer trusts seller's description)
 *   - Ciphertext stored off-chain must remain available
 */
contract PayToDecrypt {

    // ═══════════════════════════════════════════════════════════════════
    //                           TYPES
    // ═══════════════════════════════════════════════════════════════════

    enum ListingState {
        Created,     // Seller posted listing, awaiting buyer
        Funded,      // Buyer deposited ETH, awaiting key reveal
        Revealed,    // Seller revealed key, transaction complete
        Expired,     // Timeout passed without reveal, buyer can refund
        Refunded,    // Buyer reclaimed funds after expiry
        Cancelled    // Seller cancelled before anyone funded
    }

    struct Listing {
        // --- Immutable after creation ---
        address payable seller;
        bytes32 keyHash;           // keccak256(decryption_key)
        bytes32 contentHash;       // keccak256(plaintext) for verification
        string  ciphertextURI;     // IPFS CID or URL to encrypted payload
        string  description;       // Human-readable description of content
        uint256 price;             // Price in wei
        uint256 timeout;           // Duration in seconds after funding

        // --- Mutable state ---
        address payable buyer;
        uint256 fundedAt;          // Timestamp when buyer funded
        ListingState state;
        bytes32 revealedKey;       // Set when seller reveals
    }

    // ═══════════════════════════════════════════════════════════════════
    //                          STORAGE
    // ═══════════════════════════════════════════════════════════════════

    uint256 public nextListingId;
    mapping(uint256 => Listing) public listings;

    uint256 public constant MIN_TIMEOUT = 1 hours;
    uint256 public constant MAX_TIMEOUT = 30 days;

    // ═══════════════════════════════════════════════════════════════════
    //                          EVENTS
    // ═══════════════════════════════════════════════════════════════════

    event ListingCreated(
        uint256 indexed listingId,
        address indexed seller,
        bytes32 keyHash,
        bytes32 contentHash,
        string  ciphertextURI,
        uint256 price,
        uint256 timeout
    );

    event ListingFunded(
        uint256 indexed listingId,
        address indexed buyer,
        uint256 fundedAt
    );

    event KeyRevealed(
        uint256 indexed listingId,
        address indexed seller,
        bytes32 decryptionKey        // THE KEY — emitted as event for gas efficiency
    );

    event ListingRefunded(
        uint256 indexed listingId,
        address indexed buyer,
        uint256 amount
    );

    event ListingCancelled(uint256 indexed listingId);

    // ═══════════════════════════════════════════════════════════════════
    //                          ERRORS
    // ═══════════════════════════════════════════════════════════════════

    error InvalidTimeout(uint256 given, uint256 min, uint256 max);
    error InvalidPrice();
    error InvalidKeyHash();
    error WrongState(uint256 listingId, ListingState expected, ListingState actual);
    error WrongPayment(uint256 expected, uint256 actual);
    error NotSeller(address caller, address seller);
    error NotBuyer(address caller, address buyer);
    error KeyHashMismatch(bytes32 expected, bytes32 actual);
    error NotExpiredYet(uint256 expiresAt, uint256 currentTime);
    error TransferFailed();

    // ═══════════════════════════════════════════════════════════════════
    //                      SELLER FUNCTIONS
    // ═══════════════════════════════════════════════════════════════════

    /**
     * @notice Create a new listing for encrypted content
     * @param _keyHash keccak256 hash of the symmetric decryption key
     * @param _contentHash keccak256 hash of the plaintext (for post-purchase verification)
     * @param _ciphertextURI URI/CID pointing to the encrypted payload
     * @param _description Human-readable description of what the buyer will receive
     * @param _price Price in wei
     * @param _timeout Seconds after funding before buyer can request refund
     */
    function createListing(
        bytes32 _keyHash,
        bytes32 _contentHash,
        string calldata _ciphertextURI,
        string calldata _description,
        uint256 _price,
        uint256 _timeout
    ) external returns (uint256 listingId) {
        if (_timeout < MIN_TIMEOUT || _timeout > MAX_TIMEOUT) {
            revert InvalidTimeout(_timeout, MIN_TIMEOUT, MAX_TIMEOUT);
        }
        if (_price == 0) revert InvalidPrice();
        if (_keyHash == bytes32(0)) revert InvalidKeyHash();

        listingId = nextListingId++;

        Listing storage l = listings[listingId];
        l.seller = payable(msg.sender);
        l.keyHash = _keyHash;
        l.contentHash = _contentHash;
        l.ciphertextURI = _ciphertextURI;
        l.description = _description;
        l.price = _price;
        l.timeout = _timeout;
        l.state = ListingState.Created;

        emit ListingCreated(
            listingId, msg.sender, _keyHash, _contentHash,
            _ciphertextURI, _price, _timeout
        );
    }

    /**
     * @notice Reveal the decryption key to claim escrowed payment
     * @dev The key is emitted in a KeyRevealed event (cheaper than storage)
     *      Contract verifies keccak256(key) matches the committed hash
     * @param _listingId ID of the funded listing
     * @param _key The 32-byte symmetric decryption key
     */
    function revealKey(uint256 _listingId, bytes32 _key) external {
        Listing storage l = listings[_listingId];

        if (l.state != ListingState.Funded) {
            revert WrongState(_listingId, ListingState.Funded, l.state);
        }
        if (msg.sender != l.seller) {
            revert NotSeller(msg.sender, l.seller);
        }

        bytes32 computedHash = keccak256(abi.encodePacked(_key));
        if (computedHash != l.keyHash) {
            revert KeyHashMismatch(l.keyHash, computedHash);
        }

        // State change before external call (checks-effects-interactions)
        l.state = ListingState.Revealed;
        l.revealedKey = _key;

        emit KeyRevealed(_listingId, msg.sender, _key);

        // Transfer escrowed ETH to seller
        (bool success, ) = l.seller.call{value: l.price}("");
        if (!success) revert TransferFailed();
    }

    /**
     * @notice Cancel an unfunded listing
     * @param _listingId ID of the listing to cancel
     */
    function cancelListing(uint256 _listingId) external {
        Listing storage l = listings[_listingId];

        if (l.state != ListingState.Created) {
            revert WrongState(_listingId, ListingState.Created, l.state);
        }
        if (msg.sender != l.seller) {
            revert NotSeller(msg.sender, l.seller);
        }

        l.state = ListingState.Cancelled;
        emit ListingCancelled(_listingId);
    }

    // ═══════════════════════════════════════════════════════════════════
    //                      BUYER FUNCTIONS
    // ═══════════════════════════════════════════════════════════════════

    /**
     * @notice Fund a listing by sending the exact price in ETH
     * @dev ETH is held in escrow until seller reveals or timeout expires
     * @param _listingId ID of the listing to fund
     */
    function fundListing(uint256 _listingId) external payable {
        Listing storage l = listings[_listingId];

        if (l.state != ListingState.Created) {
            revert WrongState(_listingId, ListingState.Created, l.state);
        }
        if (msg.value != l.price) {
            revert WrongPayment(l.price, msg.value);
        }

        l.buyer = payable(msg.sender);
        l.fundedAt = block.timestamp;
        l.state = ListingState.Funded;

        emit ListingFunded(_listingId, msg.sender, block.timestamp);
    }

    /**
     * @notice Reclaim escrowed ETH after the timeout has passed without key reveal
     * @param _listingId ID of the expired listing
     */
    function claimRefund(uint256 _listingId) external {
        Listing storage l = listings[_listingId];

        if (l.state != ListingState.Funded) {
            revert WrongState(_listingId, ListingState.Funded, l.state);
        }
        if (msg.sender != l.buyer) {
            revert NotBuyer(msg.sender, l.buyer);
        }

        uint256 expiresAt = l.fundedAt + l.timeout;
        if (block.timestamp < expiresAt) {
            revert NotExpiredYet(expiresAt, block.timestamp);
        }

        // State change before external call
        l.state = ListingState.Refunded;

        emit ListingRefunded(_listingId, msg.sender, l.price);

        (bool success, ) = l.buyer.call{value: l.price}("");
        if (!success) revert TransferFailed();
    }

    // ═══════════════════════════════════════════════════════════════════
    //                      VIEW FUNCTIONS
    // ═══════════════════════════════════════════════════════════════════

    /**
     * @notice Check if a listing's timeout has expired
     */
    function isExpired(uint256 _listingId) external view returns (bool) {
        Listing storage l = listings[_listingId];
        if (l.state != ListingState.Funded) return false;
        return block.timestamp >= l.fundedAt + l.timeout;
    }

    /**
     * @notice Get the full listing details
     */
    function getListing(uint256 _listingId) external view returns (
        address seller,
        bytes32 keyHash,
        bytes32 contentHash,
        string memory ciphertextURI,
        string memory description,
        uint256 price,
        uint256 timeout,
        address buyer,
        uint256 fundedAt,
        ListingState state,
        bytes32 revealedKey
    ) {
        Listing storage l = listings[_listingId];
        return (
            l.seller, l.keyHash, l.contentHash, l.ciphertextURI,
            l.description, l.price, l.timeout, l.buyer,
            l.fundedAt, l.state, l.revealedKey
        );
    }
}
