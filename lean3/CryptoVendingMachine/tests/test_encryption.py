#!/usr/bin/env python3
"""
Test suite for the Crypto Vending Machine encryption module.
"""

import os
import sys
import tempfile
import unittest

sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))
from crypto_vending_machine import (
    encrypt_file, decrypt_file, save_encrypted_file,
    generate_frontend, AES_KEY_SIZE, AES_NONCE_SIZE, AES_TAG_SIZE
)


class TestEncryption(unittest.TestCase):
    """Test AES-256-GCM encryption and decryption."""

    def setUp(self):
        """Create a temporary test file."""
        self.test_data = b"Hello, Ethereum! This is a secret file. " * 100
        self.tmp = tempfile.NamedTemporaryFile(
            delete=False, suffix="_test.txt",
            prefix="cvm_"
        )
        self.tmp.write(self.test_data)
        self.tmp.close()
        self.test_path = self.tmp.name
        self.test_filename = os.path.basename(self.test_path)

    def tearDown(self):
        """Clean up temp files."""
        if os.path.exists(self.test_path):
            os.unlink(self.test_path)

    def test_encrypt_returns_correct_sizes(self):
        """Encryption produces key, nonce, tag, ciphertext of correct sizes."""
        key, nonce, tag, ciphertext = encrypt_file(self.test_path)

        self.assertEqual(len(key), AES_KEY_SIZE)        # 32 bytes
        self.assertEqual(len(nonce), AES_NONCE_SIZE)     # 12 bytes
        self.assertEqual(len(tag), AES_TAG_SIZE)         # 16 bytes
        self.assertEqual(len(ciphertext), len(self.test_data))

    def test_encrypt_produces_different_output(self):
        """Encrypting the same file twice produces different ciphertexts."""
        key1, nonce1, _, ct1 = encrypt_file(self.test_path)
        key2, nonce2, _, ct2 = encrypt_file(self.test_path)

        self.assertNotEqual(key1, key2)
        self.assertNotEqual(nonce1, nonce2)
        self.assertNotEqual(ct1, ct2)

    def test_roundtrip_encryption(self):
        """Encrypt then decrypt recovers original data."""
        key, nonce, tag, ciphertext = encrypt_file(self.test_path)

        # Pack into wire format
        encrypted_data = nonce + tag + ciphertext

        # Decrypt
        plaintext = decrypt_file(key, encrypted_data, self.test_filename)
        self.assertEqual(plaintext, self.test_data)

    def test_save_and_load_encrypted(self):
        """Save encrypted file and decrypt from disk."""
        key, nonce, tag, ciphertext = encrypt_file(self.test_path)

        enc_path = self.test_path + ".encrypted"
        try:
            save_encrypted_file(nonce, tag, ciphertext, enc_path)

            # Verify file format
            with open(enc_path, "rb") as f:
                data = f.read()

            self.assertEqual(len(data), AES_NONCE_SIZE + AES_TAG_SIZE + len(ciphertext))

            # Decrypt from file
            plaintext = decrypt_file(key, data, self.test_filename)
            self.assertEqual(plaintext, self.test_data)
        finally:
            if os.path.exists(enc_path):
                os.unlink(enc_path)

    def test_wrong_key_fails(self):
        """Decryption with wrong key raises an error."""
        key, nonce, tag, ciphertext = encrypt_file(self.test_path)
        encrypted_data = nonce + tag + ciphertext

        # Corrupt key
        wrong_key = bytes([(b + 1) % 256 for b in key])

        with self.assertRaises(Exception):
            decrypt_file(wrong_key, encrypted_data, self.test_filename)

    def test_tampered_ciphertext_fails(self):
        """Decryption of tampered data raises an error (GCM integrity)."""
        key, nonce, tag, ciphertext = encrypt_file(self.test_path)

        # Tamper with ciphertext
        tampered = bytearray(ciphertext)
        tampered[0] ^= 0xFF
        encrypted_data = nonce + tag + bytes(tampered)

        with self.assertRaises(Exception):
            decrypt_file(key, encrypted_data, self.test_filename)

    def test_empty_file(self):
        """Encryption works on empty files."""
        empty_path = self.test_path + ".empty"
        try:
            with open(empty_path, "wb") as f:
                pass  # empty file

            key, nonce, tag, ciphertext = encrypt_file(empty_path)
            self.assertEqual(len(ciphertext), 0)

            encrypted_data = nonce + tag + ciphertext
            plaintext = decrypt_file(key, encrypted_data, os.path.basename(empty_path))
            self.assertEqual(plaintext, b"")
        finally:
            if os.path.exists(empty_path):
                os.unlink(empty_path)

    def test_large_file(self):
        """Encryption works on larger files (1 MB)."""
        large_path = self.test_path + ".large"
        try:
            data = os.urandom(1024 * 1024)  # 1 MB
            with open(large_path, "wb") as f:
                f.write(data)

            key, nonce, tag, ciphertext = encrypt_file(large_path)
            encrypted_data = nonce + tag + ciphertext
            plaintext = decrypt_file(key, encrypted_data, os.path.basename(large_path))
            self.assertEqual(plaintext, data)
        finally:
            if os.path.exists(large_path):
                os.unlink(large_path)

    def test_binary_file(self):
        """Encryption works on binary data with all byte values."""
        bin_path = self.test_path + ".bin"
        try:
            data = bytes(range(256)) * 10
            with open(bin_path, "wb") as f:
                f.write(data)

            key, nonce, tag, ciphertext = encrypt_file(bin_path)
            encrypted_data = nonce + tag + ciphertext
            plaintext = decrypt_file(key, encrypted_data, os.path.basename(bin_path))
            self.assertEqual(plaintext, data)
        finally:
            if os.path.exists(bin_path):
                os.unlink(bin_path)


class TestFrontendGeneration(unittest.TestCase):
    """Test HTML frontend generation."""

    def test_generates_valid_html(self):
        """Frontend generator produces HTML with required elements."""
        html = generate_frontend(
            contract_address="0x1234567890abcdef1234567890abcdef12345678",
            chain_id=11155111,
            price_eth="0.01",
            ipfs_cid="QmTest123",
            original_filename="test.pdf",
            abi=[],
            network_name="sepolia"
        )

        self.assertIn("<!DOCTYPE html>", html)
        self.assertIn("0x1234567890abcdef1234567890abcdef12345678", html)
        self.assertIn("11155111", html)
        self.assertIn("QmTest123", html)
        self.assertIn("test.pdf", html)
        self.assertIn("MetaMask", html)
        self.assertIn("ethers", html)
        self.assertIn("AES-GCM", html)

    def test_contains_purchase_function(self):
        """Frontend contains the purchase JavaScript function."""
        html = generate_frontend(
            contract_address="0x" + "a" * 40,
            chain_id=1,
            price_eth="1.0",
            ipfs_cid="QmTest",
            original_filename="file.zip",
            abi=[]
        )

        self.assertIn("purchaseFile", html)
        self.assertIn("connectWallet", html)
        self.assertIn("downloadDecrypted", html)
        self.assertIn("decryptAndOffer", html)


if __name__ == "__main__":
    unittest.main(verbosity=2)
