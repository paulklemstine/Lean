"""
crypto_utils.py – Symmetric & asymmetric helpers for file encryption.

• AES-256-GCM for file encryption (authenticated encryption).
• ECIES (secp256k1) for encrypting the AES key to the buyer.
"""

import os
import json
import struct
import hashlib
from pathlib import Path
from typing import Tuple

from cryptography.hazmat.primitives.ciphers.aead import AESGCM

# ---------------------------------------------------------------------------
#  AES-256-GCM  (file encryption)
# ---------------------------------------------------------------------------

AES_KEY_BYTES = 32     # 256-bit
AES_NONCE_BYTES = 12   # 96-bit recommended for GCM


def generate_aes_key() -> bytes:
    """Return a random 256-bit AES key."""
    return os.urandom(AES_KEY_BYTES)


def encrypt_file(filepath: str, key: bytes) -> Tuple[bytes, bytes]:
    """
    Encrypt *filepath* with AES-256-GCM.

    Returns
    -------
    (nonce, ciphertext)   where ciphertext includes the 16-byte GCM tag.
    """
    nonce = os.urandom(AES_NONCE_BYTES)
    plaintext = Path(filepath).read_bytes()
    ciphertext = AESGCM(key).encrypt(nonce, plaintext, None)
    return nonce, ciphertext


def decrypt_data(nonce: bytes, ciphertext: bytes, key: bytes) -> bytes:
    """Decrypt AES-256-GCM ciphertext."""
    return AESGCM(key).decrypt(nonce, ciphertext, None)


def pack_encrypted_file(nonce: bytes, ciphertext: bytes,
                        original_name: str) -> bytes:
    """
    Pack encrypted data into a self-describing binary blob:

        [4B name_len][name_bytes][12B nonce][ciphertext...]
    """
    name_bytes = original_name.encode("utf-8")
    return (struct.pack("<I", len(name_bytes))
            + name_bytes
            + nonce
            + ciphertext)


def unpack_encrypted_file(blob: bytes) -> Tuple[str, bytes, bytes]:
    """Inverse of pack_encrypted_file → (original_name, nonce, ciphertext)."""
    name_len = struct.unpack("<I", blob[:4])[0]
    name = blob[4 : 4 + name_len].decode("utf-8")
    nonce = blob[4 + name_len : 4 + name_len + AES_NONCE_BYTES]
    ciphertext = blob[4 + name_len + AES_NONCE_BYTES :]
    return name, nonce, ciphertext


def key_commitment(key: bytes) -> bytes:
    """keccak256 commitment of the AES key (matches Solidity)."""
    from web3 import Web3
    return Web3.solidity_keccak(["bytes"], [key])


# ---------------------------------------------------------------------------
#  ECIES helpers  (secp256k1)
# ---------------------------------------------------------------------------

try:
    from ecies import encrypt as ecies_encrypt, decrypt as ecies_decrypt
    from ecies.utils import generate_eth_key

    def generate_buyer_keypair() -> Tuple[bytes, bytes]:
        """
        Generate a secp256k1 keypair for the buyer.

        Returns (private_key_hex_bytes, uncompressed_public_key_65_bytes).
        """
        key = generate_eth_key()
        return (key.to_hex().encode(),
                key.public_key.to_bytes())  # 65 bytes uncompressed

    def encrypt_for_buyer(data: bytes, buyer_pubkey: bytes) -> bytes:
        """ECIES-encrypt *data* so only the holder of *buyer_pubkey*'s
        private key can decrypt it."""
        return ecies_encrypt(buyer_pubkey, data)

    def decrypt_from_seller(encrypted: bytes, private_key_hex: bytes) -> bytes:
        """ECIES-decrypt data encrypted for us."""
        return ecies_decrypt(private_key_hex.decode(), encrypted)

except ImportError:
    # Graceful degradation when ecies is not installed
    def generate_buyer_keypair():
        raise ImportError("Install `eciespy`: pip install eciespy")
    def encrypt_for_buyer(data, buyer_pubkey):
        raise ImportError("Install `eciespy`: pip install eciespy")
    def decrypt_from_seller(encrypted, private_key_hex):
        raise ImportError("Install `eciespy`: pip install eciespy")
