"""
test_encryption.py — Unit tests for the crypto layer.

Run with:  pytest tests/ -v
"""

import os
import tempfile
import pytest
from pathlib import Path

# Add project root to path
import sys
sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from src.crypto_utils import (
    generate_aes_key,
    encrypt_file,
    decrypt_data,
    pack_encrypted_file,
    unpack_encrypted_file,
    AES_KEY_BYTES,
    AES_NONCE_BYTES,
)


class TestAESEncryption:
    """AES-256-GCM encryption round-trip tests."""

    def test_key_generation(self):
        key = generate_aes_key()
        assert len(key) == AES_KEY_BYTES
        # Two keys should be different (probabilistic but overwhelming)
        key2 = generate_aes_key()
        assert key != key2

    def test_encrypt_decrypt_roundtrip(self, tmp_path):
        # Create a test file
        test_file = tmp_path / "hello.txt"
        test_file.write_text("Hello, decentralised world! 🌐")

        key = generate_aes_key()
        nonce, ciphertext = encrypt_file(str(test_file), key)

        assert len(nonce) == AES_NONCE_BYTES
        assert len(ciphertext) > 0
        # Ciphertext should differ from plaintext
        assert ciphertext != test_file.read_bytes()

        # Decrypt
        plaintext = decrypt_data(nonce, ciphertext, key)
        assert plaintext == test_file.read_bytes()

    def test_wrong_key_fails(self, tmp_path):
        test_file = tmp_path / "secret.bin"
        test_file.write_bytes(os.urandom(1024))

        key1 = generate_aes_key()
        key2 = generate_aes_key()
        nonce, ct = encrypt_file(str(test_file), key1)

        with pytest.raises(Exception):
            decrypt_data(nonce, ct, key2)

    def test_large_file(self, tmp_path):
        """Test with a 1 MB file."""
        test_file = tmp_path / "large.bin"
        data = os.urandom(1_000_000)
        test_file.write_bytes(data)

        key = generate_aes_key()
        nonce, ct = encrypt_file(str(test_file), key)
        recovered = decrypt_data(nonce, ct, key)
        assert recovered == data


class TestPackUnpack:
    """Binary blob packing tests."""

    def test_pack_unpack_roundtrip(self):
        nonce = os.urandom(AES_NONCE_BYTES)
        ciphertext = os.urandom(500)
        name = "my_document.pdf"

        blob = pack_encrypted_file(nonce, ciphertext, name)
        r_name, r_nonce, r_ct = unpack_encrypted_file(blob)

        assert r_name == name
        assert r_nonce == nonce
        assert r_ct == ciphertext

    def test_unicode_filename(self):
        nonce = os.urandom(AES_NONCE_BYTES)
        ciphertext = os.urandom(100)
        name = "données_résumé_📊.xlsx"

        blob = pack_encrypted_file(nonce, ciphertext, name)
        r_name, r_nonce, r_ct = unpack_encrypted_file(blob)
        assert r_name == name


class TestIPFSMock:
    """Mock IPFS backend tests."""

    def test_add_and_cat(self):
        from src.ipfs_utils import get_ipfs_backend
        ipfs = get_ipfs_backend("mock")
        data = b"test data for IPFS"
        cid = ipfs.add_bytes(data, "test.txt")
        assert cid.startswith("Qm")
        assert ipfs.cat(cid) == data

    def test_missing_cid_raises(self):
        from src.ipfs_utils import get_ipfs_backend
        ipfs = get_ipfs_backend("mock")
        with pytest.raises(FileNotFoundError):
            ipfs.cat("QmNONEXISTENT")


class TestECIES:
    """ECIES keypair and encrypt/decrypt tests (requires eciespy)."""

    @pytest.fixture(autouse=True)
    def _check_ecies(self):
        try:
            from ecies import encrypt, decrypt
        except ImportError:
            pytest.skip("eciespy not installed")

    def test_keypair_generation(self):
        from src.crypto_utils import generate_buyer_keypair
        priv, pub = generate_buyer_keypair()
        assert len(pub) == 65  # uncompressed
        assert pub[0:1] == b'\x04'  # uncompressed prefix

    def test_ecies_roundtrip(self):
        from src.crypto_utils import (
            generate_buyer_keypair, encrypt_for_buyer, decrypt_from_seller
        )
        priv, pub = generate_buyer_keypair()
        secret = b"this is the AES key"
        encrypted = encrypt_for_buyer(secret, pub)
        decrypted = decrypt_from_seller(encrypted, priv)
        assert decrypted == secret


class TestEndToEnd:
    """Full pipeline: encrypt → pack → IPFS mock → unpack → decrypt."""

    def test_full_pipeline(self, tmp_path):
        from src.ipfs_utils import get_ipfs_backend

        # Create file
        original = tmp_path / "contract.sol"
        content = b"pragma solidity ^0.8.0; // secret contract"
        original.write_bytes(content)

        # Encrypt
        key = generate_aes_key()
        nonce, ct = encrypt_file(str(original), key)
        blob = pack_encrypted_file(nonce, ct, original.name)

        # Upload to mock IPFS
        ipfs = get_ipfs_backend("mock")
        cid = ipfs.add_bytes(blob, "contract.sol.enc")

        # Download from mock IPFS
        downloaded = ipfs.cat(cid)
        assert downloaded == blob

        # Unpack and decrypt
        name, r_nonce, r_ct = unpack_encrypted_file(downloaded)
        assert name == "contract.sol"
        recovered = decrypt_data(r_nonce, r_ct, key)
        assert recovered == content
