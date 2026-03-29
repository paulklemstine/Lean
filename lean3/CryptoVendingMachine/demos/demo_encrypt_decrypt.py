#!/usr/bin/env python3
"""
╔══════════════════════════════════════════════════════════════════════════╗
║     DEMO 1: Encryption & Decryption Roundtrip                         ║
║                                                                        ║
║     Demonstrates the core cryptographic pipeline:                      ║
║       1. Create a sample file                                          ║
║       2. Encrypt with AES-256-GCM                                      ║
║       3. Show the encrypted data (hex dump)                            ║
║       4. Decrypt and verify                                            ║
╚══════════════════════════════════════════════════════════════════════════╝
"""

import os
import sys
import tempfile

sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))
from crypto_vending_machine import encrypt_file, decrypt_file, save_encrypted_file


def hex_dump(data: bytes, width: int = 32, max_lines: int = 8) -> str:
    """Pretty hex dump of binary data."""
    lines = []
    for i in range(0, min(len(data), width * max_lines), width):
        chunk = data[i:i+width]
        hex_part = " ".join(f"{b:02x}" for b in chunk)
        ascii_part = "".join(chr(b) if 32 <= b < 127 else "." for b in chunk)
        lines.append(f"  {i:08x}  {hex_part:<{width*3}}  |{ascii_part}|")
    if len(data) > width * max_lines:
        lines.append(f"  ... ({len(data):,} bytes total)")
    return "\n".join(lines)


def main():
    print("\n" + "=" * 70)
    print("  CRYPTO VENDING MACHINE — Encryption Demo")
    print("=" * 70)

    # Step 1: Create sample file
    print("\n  [Step 1] Creating sample file...")
    sample_content = """
    ╔══════════════════════════════════════════════╗
    ║  TOP SECRET DOCUMENT                        ║
    ║                                              ║
    ║  The answer to everything is 42.             ║
    ║                                              ║
    ║  This file is worth 0.01 ETH.               ║
    ╚══════════════════════════════════════════════╝
    """.encode("utf-8")

    tmp = tempfile.NamedTemporaryFile(
        delete=False, suffix="_secret.txt", prefix="demo_"
    )
    tmp.write(sample_content)
    tmp.close()
    filename = os.path.basename(tmp.name)

    print(f"  Created: {filename}")
    print(f"  Size: {len(sample_content)} bytes")
    print(f"\n  Content preview:")
    print(sample_content.decode("utf-8"))

    # Step 2: Encrypt
    print("  [Step 2] Encrypting with AES-256-GCM...")
    key, nonce, tag, ciphertext = encrypt_file(tmp.name)

    print(f"\n  Encryption Key (256-bit):")
    print(f"    {key.hex()}")
    print(f"\n  Nonce (96-bit):")
    print(f"    {nonce.hex()}")
    print(f"\n  Auth Tag (128-bit):")
    print(f"    {tag.hex()}")
    print(f"\n  Ciphertext ({len(ciphertext)} bytes):")
    print(hex_dump(ciphertext))

    # Step 3: Save packed format
    print(f"\n  [Step 3] Packed format: [nonce|tag|ciphertext]")
    packed = nonce + tag + ciphertext
    print(f"  Total size: {len(packed)} bytes")
    print(f"    Nonce:      {len(nonce):>5} bytes  (offset 0)")
    print(f"    Tag:        {len(tag):>5} bytes  (offset {len(nonce)})")
    print(f"    Ciphertext: {len(ciphertext):>5} bytes  (offset {len(nonce)+len(tag)})")

    # Step 4: Decrypt
    print(f"\n  [Step 4] Decrypting...")
    plaintext = decrypt_file(key, packed, filename)

    print(f"  Decrypted size: {len(plaintext)} bytes")
    print(f"  Match: {'✅ PERFECT' if plaintext == sample_content else '❌ MISMATCH'}")
    print(f"\n  Decrypted content:")
    print(plaintext.decode("utf-8"))

    # Step 5: Demonstrate tamper detection
    print("  [Step 5] Tamper detection test...")
    tampered = bytearray(packed)
    tampered[30] ^= 0xFF  # Flip one bit in ciphertext
    try:
        decrypt_file(key, bytes(tampered), filename)
        print("  ❌ FAIL — tampered data was accepted!")
    except Exception as e:
        print(f"  ✅ PASS — tampered data rejected: {type(e).__name__}")

    # Step 6: Wrong key detection
    print("\n  [Step 6] Wrong key detection test...")
    wrong_key = bytes([(b + 1) % 256 for b in key])
    try:
        decrypt_file(wrong_key, packed, filename)
        print("  ❌ FAIL — wrong key was accepted!")
    except Exception as e:
        print(f"  ✅ PASS — wrong key rejected: {type(e).__name__}")

    # Cleanup
    os.unlink(tmp.name)

    print("\n" + "=" * 70)
    print("  Demo complete! All cryptographic operations verified.")
    print("=" * 70 + "\n")


if __name__ == "__main__":
    main()
