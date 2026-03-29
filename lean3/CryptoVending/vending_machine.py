#!/usr/bin/env python3
"""
vending_machine.py — CLI for the CryptoVending decentralised file-sale system.

Workflow
--------
  1.  Encrypt a file and upload to IPFS:
        python vending_machine.py create --file secret.pdf --price 0.01

  2.  Deploy the smart contract:
        python vending_machine.py deploy --artifact vend.json --network sepolia

  3.  Run the key-delivery watcher:
        python vending_machine.py watch --artifact vend.json

  4.  (Buyer) Open the IPFS-hosted buyer page and pay with MetaMask.
"""

import argparse
import json
import os
import sys
import textwrap
from pathlib import Path

# ---------------------------------------------------------------------------
#  Locate package
# ---------------------------------------------------------------------------
ROOT = Path(__file__).resolve().parent
sys.path.insert(0, str(ROOT))

from src.crypto_utils import (
    generate_aes_key, encrypt_file, pack_encrypted_file, key_commitment,
)
from src.ipfs_utils import get_ipfs_backend
from src.contract_utils import (
    compile_contract, get_web3, deploy_contract,
    save_deployment_artifact, load_deployment_artifact,
)

# ---------------------------------------------------------------------------
#  Network metadata
# ---------------------------------------------------------------------------
CHAIN_IDS = {
    "mainnet": 1,
    "sepolia": 11155111,
    "goerli": 5,
    "localhost": 1337,
    "hardhat": 31337,
    "ganache": 1337,
}
RPC_URLS = {
    "localhost": "http://127.0.0.1:8545",
    "hardhat":   "http://127.0.0.1:8545",
    "ganache":   "http://127.0.0.1:7545",
}
GATEWAYS = {
    "local":  "http://127.0.0.1:8080",
    "pinata": "https://gateway.pinata.cloud",
    "mock":   "https://ipfs.io",
}


# ═══════════════════════════════════════════════════════════════════════
#  CREATE — Encrypt file, upload to IPFS, build buyer page, save artifact
# ═══════════════════════════════════════════════════════════════════════

def cmd_create(args):
    filepath = args.file
    price_eth = args.price
    ipfs_backend = args.ipfs
    single_serving = not args.multi
    output = args.output or (Path(filepath).stem + "_vend.json")

    print(f"╔══════════════════════════════════════════════╗")
    print(f"║  CryptoVending — File Vending Machine        ║")
    print(f"╚══════════════════════════════════════════════╝")
    print()

    # 1. Generate AES key
    print("[1/5] Generating AES-256 encryption key…")
    aes_key = generate_aes_key()
    commitment = key_commitment(aes_key)
    print(f"       Key commitment: {commitment.hex()}")

    # 2. Encrypt file
    print(f"[2/5] Encrypting {filepath}…")
    nonce, ciphertext = encrypt_file(filepath, aes_key)
    original_name = Path(filepath).name
    blob = pack_encrypted_file(nonce, ciphertext, original_name)
    print(f"       Encrypted size: {len(blob):,} bytes")

    # 3. Upload encrypted file to IPFS
    print(f"[3/5] Uploading encrypted file to IPFS ({ipfs_backend})…")
    ipfs = get_ipfs_backend(ipfs_backend)
    file_cid = ipfs.add_bytes(blob, original_name + ".enc")
    print(f"       File CID: {file_cid}")

    # 4. Build and upload buyer HTML page
    print("[4/5] Building buyer page…")
    from web3 import Web3
    price_wei = Web3.to_wei(price_eth, "ether")

    # Compile contract to get ABI
    compiled = compile_contract()
    abi_json = json.dumps(compiled["abi"])

    # We don't have a contract address yet — use a placeholder
    network = args.network or "sepolia"
    chain_id = CHAIN_IDS.get(network, 1)
    rpc_url = RPC_URLS.get(network,
        f"https://{network}.infura.io/v3/" + os.environ.get("INFURA_KEY", "YOUR_INFURA_KEY"))
    gateway = GATEWAYS.get(ipfs_backend, "https://ipfs.io")

    buyer_html = _build_buyer_page(
        contract_address="0x0000000000000000000000000000000000000000",
        network=network,
        chain_id=chain_id,
        rpc_url=rpc_url,
        file_cid=file_cid,
        price_wei=str(price_wei),
        price_eth=str(price_eth),
        ipfs_gateway=gateway,
        abi_json=abi_json,
    )

    metadata_cid = ipfs.add_bytes(buyer_html.encode("utf-8"), "buyer.html")
    print(f"       Buyer page CID: {metadata_cid}")
    print(f"       Buyer page URL: {ipfs.gateway_url(metadata_cid)}")

    # 5. Save artifact
    print(f"[5/5] Saving artifact → {output}")
    artifact = {
        "file_cid": file_cid,
        "metadata_cid": metadata_cid,
        "price_wei": str(price_wei),
        "price_eth": str(price_eth),
        "aes_key_hex": aes_key.hex(),
        "key_commitment": commitment.hex(),
        "network": network,
        "chain_id": chain_id,
        "abi": compiled["abi"],
        "bytecode": compiled["bytecode"],
        "single_serving": single_serving,
        "original_filename": original_name,
        "contract_address": None,  # filled after deploy
    }
    Path(output).write_text(json.dumps(artifact, indent=2))

    # Also save the buyer page locally
    local_html = Path(output).with_suffix(".html")
    local_html.write_text(buyer_html)
    print(f"       Local buyer page saved: {local_html}")

    print()
    print("  ✓  Artifact saved.  Next step:")
    print(f"     python vending_machine.py deploy --artifact {output} "
          f"--network {network}")
    print()


# ═══════════════════════════════════════════════════════════════════════
#  DEPLOY — Deploy the contract on-chain
# ═══════════════════════════════════════════════════════════════════════

def cmd_deploy(args):
    artifact_path = args.artifact
    network = args.network
    private_key = args.private_key or os.environ.get("DEPLOYER_PRIVATE_KEY")
    rpc_url = args.rpc

    artifact = json.loads(Path(artifact_path).read_text())

    print(f"[deploy] Connecting to {network}…")
    w3 = get_web3(network=network, rpc_url=rpc_url)
    print(f"         Chain ID: {w3.eth.chain_id}")
    print(f"         Latest block: {w3.eth.block_number}")

    price_wei = int(artifact["price_wei"])
    commitment = bytes.fromhex(artifact["key_commitment"])
    single_serving = artifact.get("single_serving", True)

    print("[deploy] Deploying FileVendingMachine…")
    addr, receipt = deploy_contract(
        w3=w3,
        abi=artifact["abi"],
        bytecode=artifact["bytecode"],
        file_cid=artifact["file_cid"],
        metadata_cid=artifact["metadata_cid"],
        price_wei=price_wei,
        key_commitment=commitment,
        single_serving=single_serving,
        deployer_private_key=private_key,
    )
    print(f"         ✓ Deployed at {addr}")
    print(f"         Gas used: {receipt.gasUsed:,}")
    print(f"         Tx hash: {receipt.transactionHash.hex()}")

    # Update artifact
    artifact["contract_address"] = addr
    artifact["network"] = network
    artifact["chain_id"] = w3.eth.chain_id
    Path(artifact_path).write_text(json.dumps(artifact, indent=2))

    # Rebuild buyer page with real contract address
    ipfs_backend = args.ipfs or "mock"
    ipfs = get_ipfs_backend(ipfs_backend)
    gateway = GATEWAYS.get(ipfs_backend, "https://ipfs.io")
    rpc_display = rpc_url or RPC_URLS.get(network,
        f"https://{network}.infura.io/v3/YOUR_INFURA_KEY")

    buyer_html = _build_buyer_page(
        contract_address=addr,
        network=network,
        chain_id=w3.eth.chain_id,
        rpc_url=rpc_display,
        file_cid=artifact["file_cid"],
        price_wei=artifact["price_wei"],
        price_eth=artifact["price_eth"],
        ipfs_gateway=gateway,
        abi_json=json.dumps(artifact["abi"]),
    )
    new_meta_cid = ipfs.add_bytes(buyer_html.encode("utf-8"), "buyer.html")
    artifact["metadata_cid"] = new_meta_cid
    Path(artifact_path).write_text(json.dumps(artifact, indent=2))

    local_html = Path(artifact_path).with_suffix(".html")
    local_html.write_text(buyer_html)

    print()
    print(f"  ✓  Buyer page CID: {new_meta_cid}")
    print(f"     Buyer page URL: {ipfs.gateway_url(new_meta_cid)}")
    print(f"     Local copy: {local_html}")
    print()
    print("  Next: run the key-delivery watcher:")
    print(f"     python vending_machine.py watch --artifact {artifact_path}")
    print()


# ═══════════════════════════════════════════════════════════════════════
#  WATCH — Run the seller-side key-delivery daemon
# ═══════════════════════════════════════════════════════════════════════

def cmd_watch(args):
    from src.watcher import KeyDeliveryWatcher

    artifact = json.loads(Path(args.artifact).read_text())
    private_key = args.private_key or os.environ.get("DEPLOYER_PRIVATE_KEY")
    if not private_key:
        print("Error: --private-key or DEPLOYER_PRIVATE_KEY required")
        sys.exit(1)

    w3 = get_web3(network=artifact.get("network", "localhost"),
                  rpc_url=args.rpc)
    contract = w3.eth.contract(
        address=artifact["contract_address"],
        abi=artifact["abi"],
    )
    aes_key = bytes.fromhex(artifact["aes_key_hex"])

    watcher = KeyDeliveryWatcher(
        w3, contract, aes_key, private_key, poll_interval=args.poll)
    watcher.run()


# ═══════════════════════════════════════════════════════════════════════
#  INFO — Display artifact information
# ═══════════════════════════════════════════════════════════════════════

def cmd_info(args):
    artifact = json.loads(Path(args.artifact).read_text())
    print(json.dumps({k: v for k, v in artifact.items()
                      if k not in ("abi", "bytecode", "aes_key_hex")},
                     indent=2))


# ═══════════════════════════════════════════════════════════════════════
#  Helpers
# ═══════════════════════════════════════════════════════════════════════

def _build_buyer_page(*, contract_address, network, chain_id,
                      rpc_url, file_cid, price_wei, price_eth,
                      ipfs_gateway, abi_json) -> str:
    """Render the buyer HTML template with injected config."""
    template_path = ROOT / "templates" / "buyer_page.html"
    html = template_path.read_text()
    replacements = {
        "{{CONTRACT_ADDRESS}}": contract_address,
        "{{NETWORK}}":          network,
        "{{CHAIN_ID}}":         str(chain_id),
        "{{RPC_URL}}":          rpc_url,
        "{{FILE_CID}}":         file_cid,
        "{{PRICE_WEI}}":        str(price_wei),
        "{{PRICE_ETH}}":        str(price_eth),
        "{{IPFS_GATEWAY}}":     ipfs_gateway,
        "{{ABI_JSON}}":         abi_json,
    }
    for placeholder, value in replacements.items():
        html = html.replace(placeholder, value)
    return html


# ═══════════════════════════════════════════════════════════════════════
#  Argument parsing
# ═══════════════════════════════════════════════════════════════════════

def main():
    parser = argparse.ArgumentParser(
        description="CryptoVending — Decentralised file vending machine",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=textwrap.dedent("""\
        Examples:
          # Create (encrypt + upload):
          python vending_machine.py create --file secret.pdf --price 0.01

          # Deploy to Sepolia testnet:
          python vending_machine.py deploy --artifact secret_vend.json \\
              --network sepolia --private-key 0xABC...

          # Run key-delivery watcher:
          python vending_machine.py watch --artifact secret_vend.json \\
              --private-key 0xABC...
        """),
    )
    sub = parser.add_subparsers(dest="command")

    # ── create ────────────────────────────────────────────────────────
    p_create = sub.add_parser("create",
        help="Encrypt a file, upload to IPFS, build buyer page")
    p_create.add_argument("--file", "-f", required=True,
        help="Path to the file to sell")
    p_create.add_argument("--price", "-p", type=float, default=0.01,
        help="Price in ETH (default 0.01)")
    p_create.add_argument("--ipfs", default="mock",
        choices=["local", "pinata", "mock"],
        help="IPFS backend (default: mock)")
    p_create.add_argument("--network", default="sepolia",
        help="Target network name (default: sepolia)")
    p_create.add_argument("--output", "-o", default=None,
        help="Output artifact JSON path")
    p_create.add_argument("--multi", action="store_true",
        help="Allow multiple purchases (default: single-serving)")
    p_create.set_defaults(func=cmd_create)

    # ── deploy ────────────────────────────────────────────────────────
    p_deploy = sub.add_parser("deploy",
        help="Deploy the vending machine contract on-chain")
    p_deploy.add_argument("--artifact", required=True,
        help="Artifact JSON from 'create' step")
    p_deploy.add_argument("--network", default="localhost",
        help="Network (localhost/sepolia/mainnet)")
    p_deploy.add_argument("--rpc", default=None,
        help="Custom RPC URL")
    p_deploy.add_argument("--private-key", default=None,
        help="Deployer private key (hex)")
    p_deploy.add_argument("--ipfs", default="mock",
        choices=["local", "pinata", "mock"],
        help="IPFS backend for re-uploading buyer page")
    p_deploy.set_defaults(func=cmd_deploy)

    # ── watch ─────────────────────────────────────────────────────────
    p_watch = sub.add_parser("watch",
        help="Run the seller-side key-delivery watcher")
    p_watch.add_argument("--artifact", required=True,
        help="Deployment artifact JSON")
    p_watch.add_argument("--private-key", default=None,
        help="Seller private key (hex)")
    p_watch.add_argument("--rpc", default=None,
        help="Custom RPC URL")
    p_watch.add_argument("--poll", type=float, default=5.0,
        help="Poll interval in seconds")
    p_watch.set_defaults(func=cmd_watch)

    # ── info ──────────────────────────────────────────────────────────
    p_info = sub.add_parser("info",
        help="Display deployment artifact info")
    p_info.add_argument("--artifact", required=True)
    p_info.set_defaults(func=cmd_info)

    args = parser.parse_args()
    if not args.command:
        parser.print_help()
        sys.exit(1)
    args.func(args)


if __name__ == "__main__":
    main()
