#!/usr/bin/env python3
"""
╔══════════════════════════════════════════════════════════════════════════╗
║     DEMO 2: Full Pipeline Simulation                                   ║
║                                                                        ║
║     Simulates the entire seller → buyer flow without needing           ║
║     a live Ethereum node or IPFS daemon:                               ║
║                                                                        ║
║       SELLER SIDE:                                                     ║
║         1. Encrypt file                                                ║
║         2. Upload to IPFS (simulated)                                  ║
║         3. Deploy smart contract (simulated)                           ║
║         4. Generate buyer frontend                                     ║
║                                                                        ║
║       BUYER SIDE:                                                      ║
║         5. Load frontend page                                          ║
║         6. Pay contract (simulated)                                    ║
║         7. Receive decryption key                                      ║
║         8. Download & decrypt file                                     ║
╚══════════════════════════════════════════════════════════════════════════╝
"""

import os
import sys
import json
import tempfile
import hashlib
from pathlib import Path

sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))
from crypto_vending_machine import (
    encrypt_file, decrypt_file, save_encrypted_file,
    generate_frontend, CONTRACT_ABI
)


def simulate_ipfs_upload(filepath: str) -> str:
    """Simulate IPFS upload, returning a deterministic CID."""
    with open(filepath, "rb") as f:
        h = hashlib.sha256(f.read()).hexdigest()
    return f"Qm{h[:44]}"


def main():
    print("\n" + "═" * 70)
    print("  CRYPTO VENDING MACHINE — Full Pipeline Demo")
    print("═" * 70)

    output_dir = Path(tempfile.mkdtemp(prefix="cvm_demo_"))

    # ─── SELLER SIDE ──────────────────────────────────────────────────

    print("\n  ╔══════════════════════════════════════════╗")
    print("  ║          SELLER WORKFLOW                 ║")
    print("  ╚══════════════════════════════════════════╝")

    # Create sample file
    print("\n  [S1] Creating sample file to sell...")
    sample_data = b"CLASSIFIED: The speed of light is 299,792,458 m/s. Don't tell anyone!"
    sample_path = output_dir / "classified_document.txt"
    sample_path.write_bytes(sample_data)
    print(f"      File: {sample_path.name} ({len(sample_data)} bytes)")

    # Encrypt
    print("\n  [S2] Encrypting with AES-256-GCM...")
    key, nonce, tag, ciphertext = encrypt_file(str(sample_path))
    print(f"      Key:  {key.hex()[:32]}...")
    print(f"      Size: {len(ciphertext)} bytes ciphertext")

    # Save encrypted file
    encrypted_path = output_dir / "classified_document.txt.encrypted"
    save_encrypted_file(nonce, tag, ciphertext, str(encrypted_path))
    print(f"      Saved: {encrypted_path.name}")

    # Upload to IPFS
    print("\n  [S3] Uploading encrypted file to IPFS (simulated)...")
    file_cid = simulate_ipfs_upload(str(encrypted_path))
    print(f"      CID: {file_cid}")

    # Deploy contract
    print("\n  [S4] Deploying smart contract (simulated)...")
    contract_address = "0x" + hashlib.sha256(b"demo_contract").hexdigest()[:40]
    price_eth = "0.01"
    chain_id = 11155111  # Sepolia
    print(f"      Contract: {contract_address}")
    print(f"      Price:    {price_eth} ETH")
    print(f"      Network:  Sepolia (chain {chain_id})")

    # Generate frontend
    print("\n  [S5] Generating buyer frontend...")
    html = generate_frontend(
        contract_address=contract_address,
        chain_id=chain_id,
        price_eth=price_eth,
        ipfs_cid=file_cid,
        original_filename="classified_document.txt",
        abi=CONTRACT_ABI,
        network_name="sepolia"
    )
    frontend_path = output_dir / "buyer_page.html"
    frontend_path.write_text(html)
    print(f"      Frontend: {frontend_path.name} ({len(html):,} chars)")

    # Upload frontend to IPFS
    frontend_cid = simulate_ipfs_upload(str(frontend_path))
    print(f"      Frontend CID: {frontend_cid}")

    # Save seller config
    config = {
        "file": sample_path.name,
        "encryption_key": key.hex(),
        "file_cid": file_cid,
        "frontend_cid": frontend_cid,
        "contract_address": contract_address,
        "price_eth": price_eth,
        "network": "sepolia"
    }
    config_path = output_dir / "seller_config.json"
    config_path.write_text(json.dumps(config, indent=2))
    print(f"\n      Config saved: {config_path.name}")

    # ─── BUYER SIDE ───────────────────────────────────────────────────

    print("\n  ╔══════════════════════════════════════════╗")
    print("  ║           BUYER WORKFLOW                 ║")
    print("  ╚══════════════════════════════════════════╝")

    print(f"\n  [B1] Buyer visits: https://ipfs.io/ipfs/{frontend_cid}")
    print(f"      Page loads with contract at {contract_address[:10]}...")

    print(f"\n  [B2] Buyer connects MetaMask wallet...")
    buyer_address = "0x" + hashlib.sha256(b"demo_buyer").hexdigest()[:40]
    print(f"      Connected: {buyer_address[:10]}...")

    print(f"\n  [B3] Buyer sends {price_eth} ETH to purchase()...")
    tx_hash = "0x" + hashlib.sha256(b"demo_tx").hexdigest()
    print(f"      TX: {tx_hash[:18]}...")
    print(f"      ⏳ Waiting for confirmation...")
    print(f"      ✅ Confirmed in block #12345678")

    print(f"\n  [B4] Contract emits Purchased event with decryption key...")
    print(f"      Key received: {key.hex()[:32]}...")

    print(f"\n  [B5] Downloading encrypted file from IPFS...")
    print(f"      Fetching: https://ipfs.io/ipfs/{file_cid}")
    with open(encrypted_path, "rb") as f:
        encrypted_data = f.read()
    print(f"      Downloaded: {len(encrypted_data)} bytes")

    print(f"\n  [B6] Decrypting file in browser (WebCrypto API)...")
    decrypted = decrypt_file(key, encrypted_data, "classified_document.txt")
    print(f"      Decrypted: {len(decrypted)} bytes")

    match = decrypted == sample_data
    print(f"\n  [B7] Verification: {'✅ PERFECT MATCH' if match else '❌ MISMATCH'}")

    if match:
        print(f"\n      Decrypted content:")
        print(f"      \"{decrypted.decode('utf-8')}\"")

    # ─── SUMMARY ──────────────────────────────────────────────────────

    print(f"\n  ╔══════════════════════════════════════════╗")
    print(f"  ║           PIPELINE SUMMARY               ║")
    print(f"  ╚══════════════════════════════════════════╝")
    print(f"""
  ┌─────────────────────────────────────────────────┐
  │ SELLER                                          │
  │   File:        {sample_path.name:<35}│
  │   Encrypted:   ✅                                │
  │   IPFS Upload: {file_cid[:35]:<35}│
  │   Contract:    {contract_address[:35]:<35}│
  │   Frontend:    {frontend_cid[:35]:<35}│
  ├─────────────────────────────────────────────────┤
  │ BUYER                                           │
  │   Payment:     {price_eth} ETH ✅{' '*30}│
  │   Key Received:✅                                │
  │   Download:    ✅                                │
  │   Decrypt:     ✅                                │
  │   Verified:    {'✅ MATCH' if match else '❌ FAIL'}{' '*28}│
  └─────────────────────────────────────────────────┘
    """)

    print(f"  Output directory: {output_dir}")
    print(f"  Open {frontend_path.name} in a browser to see the buyer UI.\n")


if __name__ == "__main__":
    main()
