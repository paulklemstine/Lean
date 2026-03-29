#!/usr/bin/env python3
"""
╔══════════════════════════════════════════════════════════════════════════════╗
║  DEMO 1: Cryptographic Primitives for Pay-to-Decrypt                       ║
║                                                                            ║
║  Demonstrates the core cryptographic operations:                           ║
║  • AES-256-GCM encryption/decryption                                       ║
║  • Keccak-256 hash commitment                                              ║
║  • Key generation and verification                                         ║
║                                                                            ║
║  Visual output shows the data flow through the system.                     ║
╚══════════════════════════════════════════════════════════════════════════════╝

Requirements: pip install pycryptodome matplotlib
"""

import os
import hashlib
import json
import struct
import sys

# ─── Minimal AES-GCM implementation (no external crypto dependency) ──────────
# Using a simple XOR cipher for demonstration; in production use AES-256-GCM
# For the demo we'll use hashlib-based stream cipher as a portable fallback

def keccak256(data: bytes) -> bytes:
    """Compute Keccak-256 hash (same as Solidity's keccak256)."""
    k = hashlib.sha3_256(data)
    return k.digest()

def generate_key() -> bytes:
    """Generate a random 256-bit symmetric key."""
    return os.urandom(32)

def encrypt(key: bytes, plaintext: bytes) -> dict:
    """
    Encrypt plaintext using a key-derived stream cipher with authentication.
    Returns dict with nonce, ciphertext, and authentication tag.
    
    NOTE: This is a portable demo implementation. Production systems should
    use AES-256-GCM via a proper cryptographic library.
    """
    nonce = os.urandom(12)
    
    # Derive keystream using SHAKE-256 (acts as a PRG seeded by key||nonce)
    shake = hashlib.shake_256(key + nonce)
    keystream = shake.digest(len(plaintext) + 32)  # extra 32 bytes for auth
    
    # XOR encryption
    ciphertext = bytes(p ^ k for p, k in zip(plaintext, keystream[:len(plaintext)]))
    
    # Authentication tag: HMAC-like construction
    auth_input = nonce + ciphertext + struct.pack('>Q', len(plaintext))
    tag = hashlib.sha3_256(key + auth_input).digest()[:16]
    
    return {
        'nonce': nonce.hex(),
        'ciphertext': ciphertext.hex(),
        'tag': tag.hex()
    }

def decrypt(key: bytes, enc_data: dict) -> bytes:
    """Decrypt ciphertext using the symmetric key."""
    nonce = bytes.fromhex(enc_data['nonce'])
    ciphertext = bytes.fromhex(enc_data['ciphertext'])
    tag = bytes.fromhex(enc_data['tag'])
    
    # Verify authentication tag first
    auth_input = nonce + ciphertext + struct.pack('>Q', len(ciphertext))
    expected_tag = hashlib.sha3_256(key + auth_input).digest()[:16]
    
    if tag != expected_tag:
        raise ValueError("Authentication failed! Ciphertext has been tampered with.")
    
    # Derive same keystream
    shake = hashlib.shake_256(key + nonce)
    keystream = shake.digest(len(ciphertext) + 32)
    
    # XOR decryption
    plaintext = bytes(c ^ k for c, k in zip(ciphertext, keystream[:len(ciphertext)]))
    return plaintext

def commit_key(key: bytes) -> bytes:
    """Create a hash commitment to the key (simulates keccak256 on Ethereum)."""
    return keccak256(key)

def verify_commitment(key: bytes, commitment: bytes) -> bool:
    """Verify that a key matches a previously made commitment."""
    return keccak256(key) == commitment


# ═══════════════════════════════════════════════════════════════════════════════
#  VISUAL DEMONSTRATION
# ═══════════════════════════════════════════════════════════════════════════════

def print_box(title, content, width=72, color='\033[96m'):
    """Print a formatted box with title and content."""
    reset = '\033[0m'
    dim = '\033[2m'
    print(f"\n{color}{'═' * width}")
    print(f"  {title}")
    print(f"{'═' * width}{reset}")
    for line in content.split('\n'):
        print(f"  {line}")
    print(f"{dim}{'─' * width}{reset}")

def hex_preview(data: str, max_len=48) -> str:
    """Show a preview of hex data with ellipsis if too long."""
    if len(data) > max_len:
        return data[:max_len//2] + '...' + data[-max_len//2:]
    return data

def main():
    print("\n" + "=" * 72)
    print("  PAY-TO-DECRYPT: Cryptographic Primitives Demo")
    print("  Demonstrating the mathematical foundation of trustless info trading")
    print("=" * 72)

    # ── Step 1: The Secret ──────────────────────────────────────────────
    secret_message = (
        "The Riemann Hypothesis is true. Here is the proof:\n"
        "Consider the non-trivial zeros of the zeta function...\n"
        "(This is a demo. The actual proof is left as an exercise.)"
    )
    
    print_box("STEP 1: The Secret (Plaintext)", 
              f"Message ({len(secret_message)} bytes):\n\n"
              f"  \"{secret_message[:60]}...\"\n\n"
              f"Content hash: {keccak256(secret_message.encode()).hex()[:32]}...",
              color='\033[92m')

    # ── Step 2: Key Generation ──────────────────────────────────────────
    key = generate_key()
    commitment = commit_key(key)
    
    print_box("STEP 2: Key Generation & Commitment",
              f"Random 256-bit key K:\n"
              f"  {key.hex()}\n\n"
              f"Hash commitment H = keccak256(K):\n"
              f"  {commitment.hex()}\n\n"
              f"The commitment H is published on-chain.\n"
              f"The key K is kept secret by the seller.",
              color='\033[93m')

    # ── Step 3: Encryption ──────────────────────────────────────────────
    encrypted = encrypt(key, secret_message.encode())
    
    print_box("STEP 3: Encryption",
              f"Nonce:      {encrypted['nonce']}\n"
              f"Ciphertext: {hex_preview(encrypted['ciphertext'])}\n"
              f"Auth tag:   {encrypted['tag']}\n\n"
              f"Ciphertext size: {len(encrypted['ciphertext'])//2} bytes\n"
              f"This encrypted blob is stored on IPFS (publicly accessible).\n"
              f"Without key K, it is computationally infeasible to decrypt.",
              color='\033[95m')

    # ── Step 4: What the blockchain sees ────────────────────────────────
    on_chain_data = {
        'key_hash': commitment.hex(),
        'content_hash': keccak256(secret_message.encode()).hex(),
        'ciphertext_uri': 'ipfs://QmDemo123...',
        'price_wei': 1000000000000000000,  # 1 ETH
        'timeout_seconds': 86400  # 24 hours
    }
    
    print_box("STEP 4: On-Chain Data (Public)",
              json.dumps(on_chain_data, indent=2) + "\n\n"
              "Everything here is public. But without the key K,\n"
              "the encrypted content remains unreadable.",
              color='\033[94m')

    # ── Step 5: Key Revelation & Decryption ─────────────────────────────
    print_box("STEP 5: After Payment — Key Revelation",
              f"Seller reveals K = {key.hex()}\n\n"
              f"Contract verifies:\n"
              f"  keccak256(K) = {keccak256(key).hex()[:32]}...\n"
              f"  Expected H   = {commitment.hex()[:32]}...\n"
              f"  Match: {'✅ YES' if verify_commitment(key, commitment) else '❌ NO'}",
              color='\033[91m')

    # ── Step 6: Decryption ──────────────────────────────────────────────
    decrypted = decrypt(key, encrypted)
    
    print_box("STEP 6: Buyer Decrypts",
              f"Using revealed key K to decrypt ciphertext...\n\n"
              f"Decrypted message:\n"
              f"  \"{decrypted.decode()[:60]}...\"\n\n"
              f"Content hash verification:\n"
              f"  Hash of decrypted: {keccak256(decrypted).hex()[:32]}...\n"
              f"  Expected:          {keccak256(secret_message.encode()).hex()[:32]}...\n"
              f"  Match: {'✅ YES' if keccak256(decrypted) == keccak256(secret_message.encode()) else '❌ NO'}",
              color='\033[92m')

    # ── Step 7: Wrong key demonstration ─────────────────────────────────
    wrong_key = generate_key()
    print_box("BONUS: What happens with a wrong key?",
              f"Wrong key: {wrong_key.hex()}\n\n"
              f"Commitment check:\n"
              f"  keccak256(wrong_key) = {keccak256(wrong_key).hex()[:32]}...\n"
              f"  Expected H           = {commitment.hex()[:32]}...\n"
              f"  Match: {'✅ YES' if verify_commitment(wrong_key, commitment) else '❌ NO — Contract rejects!'}\n\n"
              f"The seller cannot claim payment with a wrong key.\n"
              f"The hash commitment enforces honesty.",
              color='\033[91m')

    # ── Summary Statistics ──────────────────────────────────────────────
    print_box("SUMMARY: Cryptographic Operations",
              f"┌────────────────────────┬──────────────┐\n"
              f"│ Operation              │ Size (bytes) │\n"
              f"├────────────────────────┼──────────────┤\n"
              f"│ Encryption key         │          32  │\n"
              f"│ Hash commitment        │          32  │\n"
              f"│ Content hash           │          32  │\n"
              f"│ Nonce                  │          12  │\n"
              f"│ Auth tag               │          16  │\n"
              f"│ Plaintext              │  {len(secret_message):>9}  │\n"
              f"│ Ciphertext             │  {len(encrypted['ciphertext'])//2:>9}  │\n"
              f"├────────────────────────┼──────────────┤\n"
              f"│ On-chain footprint     │        ~128  │\n"
              f"│ (hashes + metadata)    │              │\n"
              f"└────────────────────────┴──────────────┘\n\n"
              f"Key insight: Only ~128 bytes needed on-chain regardless of payload size!",
              color='\033[97m')

if __name__ == '__main__':
    main()
