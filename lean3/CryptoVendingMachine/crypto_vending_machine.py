#!/usr/bin/env python3
"""
╔══════════════════════════════════════════════════════════════════════════════╗
║               CRYPTO VENDING MACHINE — File Encryption & Sales             ║
║                                                                            ║
║  Encrypt any file, deploy a single-serving Ethereum smart contract, host   ║
║  the encrypted file and buyer UI on IPFS, and let customers pay-and-       ║
║  download with MetaMask.                                                   ║
╚══════════════════════════════════════════════════════════════════════════════╝

Usage:
    python crypto_vending_machine.py encrypt   --file secret.pdf --price 0.01
    python crypto_vending_machine.py deploy    --config output/config.json --network sepolia
    python crypto_vending_machine.py full      --file secret.pdf --price 0.01 --network sepolia

Environment variables (or .env file):
    PRIVATE_KEY       — Deployer wallet private key
    RPC_URL           — Ethereum JSON-RPC endpoint (Infura / Alchemy)
    IPFS_API_URL      — IPFS HTTP API (default: http://127.0.0.1:5001)
    ETHERSCAN_API_KEY — (optional) For contract verification
"""

import os
import sys
import json
import hashlib
import secrets
import argparse
import tempfile
import shutil
import subprocess
from pathlib import Path
from datetime import datetime, timezone
from typing import Optional, Tuple

# ─── Cryptography ────────────────────────────────────────────────────────────

from Crypto.Cipher import AES
from Crypto.Random import get_random_bytes

# ─── Ethereum / Web3 ─────────────────────────────────────────────────────────

try:
    from web3 import Web3
    from eth_account import Account
    HAS_WEB3 = True
except ImportError:
    HAS_WEB3 = False

# ─── IPFS ─────────────────────────────────────────────────────────────────────

import requests

# ─── dotenv (optional) ────────────────────────────────────────────────────────

try:
    from dotenv import load_dotenv
    load_dotenv()
except ImportError:
    pass


# ═══════════════════════════════════════════════════════════════════════════════
#  CONSTANTS
# ═══════════════════════════════════════════════════════════════════════════════

AES_KEY_SIZE   = 32   # AES-256
AES_NONCE_SIZE = 12   # GCM standard nonce
AES_TAG_SIZE   = 16   # GCM authentication tag

SOLIDITY_SOURCE = Path(__file__).parent / "contracts" / "FileVendingMachine.sol"
FRONTEND_TEMPLATE = Path(__file__).parent / "frontend" / "index.html"
OUTPUT_DIR = Path(__file__).parent / "output"

# Pinata public IPFS gateway (fallback)
IPFS_GATEWAY = "https://gateway.pinata.cloud/ipfs/"
IPFS_API_URL = os.getenv("IPFS_API_URL", "http://127.0.0.1:5001")

# Network presets
NETWORKS = {
    "mainnet":  {"chain_id": 1,        "rpc": "https://eth.llamarpc.com"},
    "sepolia":  {"chain_id": 11155111, "rpc": "https://rpc.sepolia.org"},
    "goerli":   {"chain_id": 5,        "rpc": "https://rpc.ankr.com/eth_goerli"},
    "holesky":  {"chain_id": 17000,    "rpc": "https://ethereum-holesky.publicnode.com"},
    "localhost": {"chain_id": 31337,   "rpc": "http://127.0.0.1:8545"},
}


# ═══════════════════════════════════════════════════════════════════════════════
#  1. ENCRYPTION MODULE
# ═══════════════════════════════════════════════════════════════════════════════

def encrypt_file(input_path: str) -> Tuple[bytes, bytes, bytes, bytes]:
    """
    Encrypt a file using AES-256-GCM.

    Returns:
        (key, nonce, tag, ciphertext)

    The ciphertext file format is:
        [12-byte nonce][16-byte tag][ciphertext...]
    """
    key   = get_random_bytes(AES_KEY_SIZE)
    nonce = get_random_bytes(AES_NONCE_SIZE)

    with open(input_path, "rb") as f:
        plaintext = f.read()

    cipher = AES.new(key, AES.MODE_GCM, nonce=nonce)

    # Include original filename as AAD for integrity
    original_name = Path(input_path).name.encode("utf-8")
    cipher.update(original_name)

    ciphertext, tag = cipher.encrypt_and_digest(plaintext)

    return key, nonce, tag, ciphertext


def decrypt_file(key: bytes, encrypted_data: bytes, original_name: str = "") -> bytes:
    """
    Decrypt AES-256-GCM encrypted data.

    encrypted_data format: [12-byte nonce][16-byte tag][ciphertext...]
    """
    nonce      = encrypted_data[:AES_NONCE_SIZE]
    tag        = encrypted_data[AES_NONCE_SIZE:AES_NONCE_SIZE + AES_TAG_SIZE]
    ciphertext = encrypted_data[AES_NONCE_SIZE + AES_TAG_SIZE:]

    cipher = AES.new(key, AES.MODE_GCM, nonce=nonce)
    if original_name:
        cipher.update(original_name.encode("utf-8"))
    plaintext = cipher.decrypt_and_verify(ciphertext, tag)
    return plaintext


def save_encrypted_file(nonce: bytes, tag: bytes, ciphertext: bytes,
                         output_path: str) -> str:
    """Pack and save encrypted file in [nonce][tag][ciphertext] format."""
    packed = nonce + tag + ciphertext
    with open(output_path, "wb") as f:
        f.write(packed)
    return output_path


# ═══════════════════════════════════════════════════════════════════════════════
#  2. IPFS MODULE
# ═══════════════════════════════════════════════════════════════════════════════

def upload_to_ipfs(file_path: str, api_url: str = IPFS_API_URL) -> str:
    """
    Upload a file to IPFS via the HTTP API.

    Returns the IPFS CID (content identifier).
    Falls back to a simulated CID if IPFS daemon is unavailable.
    """
    try:
        with open(file_path, "rb") as f:
            response = requests.post(
                f"{api_url}/api/v0/add",
                files={"file": f},
                timeout=60
            )
        response.raise_for_status()
        cid = response.json()["Hash"]
        print(f"  ✓ Uploaded to IPFS: {cid}")
        return cid
    except Exception as e:
        # Generate a deterministic placeholder CID from file hash
        with open(file_path, "rb") as f:
            file_hash = hashlib.sha256(f.read()).hexdigest()
        simulated_cid = f"Qm{file_hash[:44]}"
        print(f"  ⚠ IPFS unavailable ({e}). Simulated CID: {simulated_cid}")
        print(f"    To use real IPFS, run: ipfs daemon")
        return simulated_cid


def upload_bytes_to_ipfs(data: bytes, filename: str,
                          api_url: str = IPFS_API_URL) -> str:
    """Upload raw bytes to IPFS."""
    tmp = tempfile.NamedTemporaryFile(delete=False, suffix=f"_{filename}")
    try:
        tmp.write(data)
        tmp.close()
        return upload_to_ipfs(tmp.name, api_url)
    finally:
        os.unlink(tmp.name)


# ═══════════════════════════════════════════════════════════════════════════════
#  3. SMART CONTRACT COMPILATION & DEPLOYMENT
# ═══════════════════════════════════════════════════════════════════════════════

# Inline ABI for the FileVendingMachine contract
CONTRACT_ABI = [
    {
        "inputs": [
            {"internalType": "uint256", "name": "_price", "type": "uint256"},
            {"internalType": "string",  "name": "_ipfsCID", "type": "string"},
            {"internalType": "string",  "name": "_frontendCID", "type": "string"},
            {"internalType": "bytes",   "name": "_encryptionKey", "type": "bytes"}
        ],
        "stateMutability": "nonpayable",
        "type": "constructor"
    },
    {
        "inputs": [],
        "name": "purchase",
        "outputs": [],
        "stateMutability": "payable",
        "type": "function"
    },
    {
        "inputs": [],
        "name": "withdraw",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "inputs": [],
        "name": "info",
        "outputs": [
            {"internalType": "address", "name": "_seller",      "type": "address"},
            {"internalType": "uint256", "name": "_price",       "type": "uint256"},
            {"internalType": "string",  "name": "_ipfsCID",     "type": "string"},
            {"internalType": "string",  "name": "_frontendCID", "type": "string"},
            {"internalType": "bool",    "name": "_purchased",   "type": "bool"},
            {"internalType": "address", "name": "_buyer",       "type": "address"}
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [],
        "name": "getKey",
        "outputs": [{"internalType": "bytes", "name": "", "type": "bytes"}],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [],
        "name": "price",
        "outputs": [{"internalType": "uint256", "name": "", "type": "uint256"}],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [],
        "name": "purchased",
        "outputs": [{"internalType": "bool", "name": "", "type": "bool"}],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [],
        "name": "ipfsCID",
        "outputs": [{"internalType": "string", "name": "", "type": "string"}],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [],
        "name": "seller",
        "outputs": [{"internalType": "address", "name": "", "type": "address"}],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [],
        "name": "buyer",
        "outputs": [{"internalType": "address", "name": "", "type": "address"}],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "anonymous": False,
        "inputs": [
            {"indexed": True,  "internalType": "address", "name": "buyer", "type": "address"},
            {"indexed": False, "internalType": "uint256", "name": "price", "type": "uint256"},
            {"indexed": False, "internalType": "string",  "name": "ipfsCID", "type": "string"},
            {"indexed": False, "internalType": "bytes",   "name": "encryptionKey", "type": "bytes"}
        ],
        "name": "Purchased",
        "type": "event"
    },
    {
        "anonymous": False,
        "inputs": [
            {"indexed": True,  "internalType": "address", "name": "seller", "type": "address"},
            {"indexed": False, "internalType": "uint256", "name": "amount", "type": "uint256"}
        ],
        "name": "Withdrawn",
        "type": "event"
    }
]

# Pre-compiled bytecode for FileVendingMachine (Solidity 0.8.20)
# This is a placeholder — in production, compile with solc or use solcx
CONTRACT_BYTECODE_PLACEHOLDER = None


def compile_contract() -> Tuple[list, str]:
    """
    Compile the Solidity contract using solcx or return pre-built ABI/bytecode.
    Falls back to the inline ABI with a placeholder bytecode.
    """
    try:
        import solcx
        solcx.install_solc("0.8.20")
        solcx.set_solc_version("0.8.20")

        with open(SOLIDITY_SOURCE, "r") as f:
            source = f.read()

        compiled = solcx.compile_source(
            source,
            output_values=["abi", "bin"],
            solc_version="0.8.20"
        )

        contract_key = "<stdin>:FileVendingMachine"
        abi      = compiled[contract_key]["abi"]
        bytecode = compiled[contract_key]["bin"]

        print("  ✓ Contract compiled with solc 0.8.20")
        return abi, bytecode

    except Exception as e:
        print(f"  ⚠ solcx compilation failed ({e})")
        print(f"    Using inline ABI. Compile externally with:")
        print(f"    solc --abi --bin contracts/FileVendingMachine.sol")

        # Try reading pre-compiled bytecode
        bin_path = SOLIDITY_SOURCE.with_suffix(".bin")
        if bin_path.exists():
            bytecode = bin_path.read_text().strip()
            return CONTRACT_ABI, bytecode

        return CONTRACT_ABI, None


def deploy_contract(
    w3: "Web3",
    account: "Account",
    abi: list,
    bytecode: str,
    price_wei: int,
    ipfs_cid: str,
    frontend_cid: str,
    encryption_key: bytes
) -> str:
    """Deploy the FileVendingMachine contract and return the contract address."""

    Contract = w3.eth.contract(abi=abi, bytecode=bytecode)

    tx = Contract.constructor(
        price_wei,
        ipfs_cid,
        frontend_cid,
        encryption_key
    ).build_transaction({
        "from": account.address,
        "nonce": w3.eth.get_transaction_count(account.address),
        "gas": 3000000,
        "gasPrice": w3.eth.gas_price,
        "chainId": w3.eth.chain_id,
    })

    signed = account.sign_transaction(tx)
    tx_hash = w3.eth.send_raw_transaction(signed.raw_transaction)
    print(f"  ⏳ Deploy TX sent: {tx_hash.hex()}")

    receipt = w3.eth.wait_for_transaction_receipt(tx_hash, timeout=300)
    contract_address = receipt["contractAddress"]
    print(f"  ✓ Contract deployed at: {contract_address}")
    return contract_address


# ═══════════════════════════════════════════════════════════════════════════════
#  4. FRONTEND GENERATOR
# ═══════════════════════════════════════════════════════════════════════════════

def generate_frontend(
    contract_address: str,
    chain_id: int,
    price_eth: str,
    ipfs_cid: str,
    original_filename: str,
    abi: list,
    network_name: str = "sepolia"
) -> str:
    """Generate the single-page HTML/JS buyer interface."""

    abi_json = json.dumps(abi, indent=2)

    html = f"""<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>🔐 Crypto Vending Machine — Buy Encrypted File</title>
    <style>
        :root {{
            --bg: #0a0a0f;
            --card: #12121a;
            --accent: #6c5ce7;
            --accent2: #a29bfe;
            --success: #00b894;
            --danger: #e74c3c;
            --text: #dfe6e9;
            --muted: #636e72;
            --border: #2d3436;
        }}
        * {{ margin: 0; padding: 0; box-sizing: border-box; }}
        body {{
            font-family: 'SF Mono', 'Fira Code', 'Cascadia Code', monospace;
            background: var(--bg);
            color: var(--text);
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            padding: 2rem;
        }}
        .container {{
            max-width: 520px;
            width: 100%;
        }}
        .card {{
            background: var(--card);
            border: 1px solid var(--border);
            border-radius: 16px;
            padding: 2rem;
            margin-bottom: 1rem;
        }}
        .logo {{
            font-size: 3rem;
            text-align: center;
            margin-bottom: 0.5rem;
        }}
        h1 {{
            text-align: center;
            font-size: 1.3rem;
            font-weight: 600;
            margin-bottom: 0.3rem;
            background: linear-gradient(135deg, var(--accent), var(--accent2));
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }}
        .subtitle {{
            text-align: center;
            color: var(--muted);
            font-size: 0.8rem;
            margin-bottom: 1.5rem;
        }}
        .info-row {{
            display: flex;
            justify-content: space-between;
            padding: 0.6rem 0;
            border-bottom: 1px solid var(--border);
            font-size: 0.85rem;
        }}
        .info-row:last-child {{ border-bottom: none; }}
        .info-label {{ color: var(--muted); }}
        .info-value {{
            color: var(--text);
            word-break: break-all;
            text-align: right;
            max-width: 60%;
        }}
        .price-display {{
            text-align: center;
            margin: 1.5rem 0;
        }}
        .price-amount {{
            font-size: 2.5rem;
            font-weight: 700;
            color: var(--accent2);
        }}
        .price-unit {{
            font-size: 1rem;
            color: var(--muted);
        }}
        .btn {{
            width: 100%;
            padding: 1rem;
            border: none;
            border-radius: 12px;
            font-size: 1rem;
            font-weight: 600;
            font-family: inherit;
            cursor: pointer;
            transition: all 0.3s;
            margin-top: 0.5rem;
        }}
        .btn-primary {{
            background: linear-gradient(135deg, var(--accent), var(--accent2));
            color: white;
        }}
        .btn-primary:hover {{ opacity: 0.9; transform: translateY(-1px); }}
        .btn-primary:disabled {{
            opacity: 0.4;
            cursor: not-allowed;
            transform: none;
        }}
        .btn-success {{
            background: var(--success);
            color: white;
        }}
        .status {{
            text-align: center;
            padding: 0.8rem;
            border-radius: 8px;
            margin-top: 1rem;
            font-size: 0.85rem;
        }}
        .status-info {{ background: rgba(108,92,231,0.15); color: var(--accent2); }}
        .status-success {{ background: rgba(0,184,148,0.15); color: var(--success); }}
        .status-error {{ background: rgba(231,76,60,0.15); color: var(--danger); }}
        .progress {{
            width: 100%;
            height: 4px;
            background: var(--border);
            border-radius: 2px;
            margin-top: 1rem;
            overflow: hidden;
        }}
        .progress-bar {{
            height: 100%;
            background: linear-gradient(90deg, var(--accent), var(--accent2));
            border-radius: 2px;
            transition: width 0.5s;
            width: 0%;
        }}
        .hidden {{ display: none; }}
        .footer {{
            text-align: center;
            color: var(--muted);
            font-size: 0.7rem;
            margin-top: 1rem;
        }}
        .footer a {{ color: var(--accent2); text-decoration: none; }}
        @keyframes pulse {{
            0%, 100% {{ opacity: 1; }}
            50% {{ opacity: 0.5; }}
        }}
        .pulsing {{ animation: pulse 1.5s infinite; }}
    </style>
</head>
<body>
    <div class="container">
        <div class="card">
            <div class="logo">🔐</div>
            <h1>Crypto Vending Machine</h1>
            <p class="subtitle">Decentralized file sales, powered by Ethereum + IPFS</p>

            <div class="info-row">
                <span class="info-label">File</span>
                <span class="info-value" id="fileName">{original_filename}</span>
            </div>
            <div class="info-row">
                <span class="info-label">Network</span>
                <span class="info-value" id="networkName">{network_name.title()}</span>
            </div>
            <div class="info-row">
                <span class="info-label">Contract</span>
                <span class="info-value" id="contractAddr">{contract_address[:8]}...{contract_address[-6:]}</span>
            </div>
            <div class="info-row">
                <span class="info-label">Status</span>
                <span class="info-value" id="saleStatus">Loading...</span>
            </div>

            <div class="price-display">
                <div class="price-amount">{price_eth}</div>
                <div class="price-unit">ETH</div>
            </div>

            <button class="btn btn-primary" id="connectBtn" onclick="connectWallet()">
                🦊 Connect MetaMask
            </button>
            <button class="btn btn-primary hidden" id="purchaseBtn" onclick="purchaseFile()" disabled>
                ⚡ Purchase &amp; Download
            </button>
            <button class="btn btn-success hidden" id="downloadBtn" onclick="downloadDecrypted()">
                📥 Download Decrypted File
            </button>

            <div class="progress hidden" id="progressContainer">
                <div class="progress-bar" id="progressBar"></div>
            </div>

            <div class="status hidden" id="statusBox"></div>
        </div>

        <div class="footer">
            Powered by Ethereum &amp; IPFS &bull;
            <a href="https://ipfs.io/ipfs/{ipfs_cid}" target="_blank">View encrypted file on IPFS</a>
        </div>
    </div>

    <script>
    // ═══════════════════════════════════════════════════════════════════
    //  CONFIGURATION (baked in at generation time)
    // ═══════════════════════════════════════════════════════════════════

    const CONFIG = {{
        contractAddress: "{contract_address}",
        chainId: {chain_id},
        priceWei: "{int(float(price_eth) * 1e18)}",
        ipfsCID: "{ipfs_cid}",
        originalFilename: "{original_filename}",
        networkName: "{network_name}",
        ipfsGateway: "https://gateway.pinata.cloud/ipfs/",
        abi: {abi_json}
    }};

    let provider, signer, contract, account;
    let decryptionKey = null;
    let encryptedData = null;

    // ═══════════════════════════════════════════════════════════════════
    //  UI HELPERS
    // ═══════════════════════════════════════════════════════════════════

    function $(id) {{ return document.getElementById(id); }}
    function show(id) {{ $(id).classList.remove('hidden'); }}
    function hide(id) {{ $(id).classList.add('hidden'); }}

    function setStatus(msg, type = 'info') {{
        const box = $('statusBox');
        box.className = 'status status-' + type;
        box.textContent = msg;
        show('statusBox');
    }}

    function setProgress(pct) {{
        show('progressContainer');
        $('progressBar').style.width = pct + '%';
    }}

    // ═══════════════════════════════════════════════════════════════════
    //  CHECK SALE STATUS ON LOAD
    // ═══════════════════════════════════════════════════════════════════

    async function checkStatus() {{
        try {{
            if (typeof window.ethereum === 'undefined') {{
                $('saleStatus').textContent = 'Install MetaMask';
                return;
            }}
            const tempProvider = new ethers.BrowserProvider(window.ethereum);
            const tempContract = new ethers.Contract(
                CONFIG.contractAddress, CONFIG.abi, tempProvider
            );
            const purchased = await tempContract.purchased();
            $('saleStatus').textContent = purchased ? '✅ Sold' : '🟢 Available';

            if (purchased) {{
                $('purchaseBtn').disabled = true;
                setStatus('This file has already been purchased.', 'info');
            }}
        }} catch (e) {{
            $('saleStatus').textContent = '⚠️ Cannot read contract';
        }}
    }}

    // ═══════════════════════════════════════════════════════════════════
    //  WALLET CONNECTION
    // ═══════════════════════════════════════════════════════════════════

    async function connectWallet() {{
        if (typeof window.ethereum === 'undefined') {{
            setStatus('MetaMask not detected. Please install MetaMask.', 'error');
            return;
        }}

        try {{
            setStatus('Connecting to MetaMask...', 'info');

            // Request account access
            const accounts = await window.ethereum.request({{
                method: 'eth_requestAccounts'
            }});
            account = accounts[0];

            // Check network
            const chainIdHex = await window.ethereum.request({{
                method: 'eth_chainId'
            }});
            const currentChainId = parseInt(chainIdHex, 16);

            if (currentChainId !== CONFIG.chainId) {{
                setStatus(
                    `Wrong network! Please switch to ${{CONFIG.networkName}} (chain ${{CONFIG.chainId}})`,
                    'error'
                );
                // Try to switch
                try {{
                    await window.ethereum.request({{
                        method: 'wallet_switchEthereumChain',
                        params: [{{ chainId: '0x' + CONFIG.chainId.toString(16) }}]
                    }});
                }} catch (switchError) {{
                    return;
                }}
            }}

            provider = new ethers.BrowserProvider(window.ethereum);
            signer = await provider.getSigner();
            contract = new ethers.Contract(CONFIG.contractAddress, CONFIG.abi, signer);

            hide('connectBtn');
            show('purchaseBtn');
            $('purchaseBtn').disabled = false;

            setStatus(`Connected: ${{account.slice(0,6)}}...${{account.slice(-4)}}`, 'success');

        }} catch (err) {{
            setStatus('Connection failed: ' + err.message, 'error');
        }}
    }}

    // ═══════════════════════════════════════════════════════════════════
    //  PURCHASE
    // ═══════════════════════════════════════════════════════════════════

    async function purchaseFile() {{
        try {{
            $('purchaseBtn').disabled = true;
            setStatus('Sending transaction...', 'info');
            setProgress(10);

            const tx = await contract.purchase({{
                value: CONFIG.priceWei
            }});

            setStatus('Transaction sent! Waiting for confirmation...', 'info');
            setProgress(30);

            const receipt = await tx.wait();
            setProgress(50);

            // Parse the Purchased event to get the decryption key
            const iface = new ethers.Interface(CONFIG.abi);
            for (const log of receipt.logs) {{
                try {{
                    const parsed = iface.parseLog(log);
                    if (parsed && parsed.name === 'Purchased') {{
                        decryptionKey = parsed.args.encryptionKey;
                        break;
                    }}
                }} catch (e) {{ /* skip non-matching logs */ }}
            }}

            if (!decryptionKey) {{
                // Fallback: read key from contract
                decryptionKey = await contract.getKey();
            }}

            setStatus('Purchase confirmed! Downloading encrypted file...', 'success');
            setProgress(60);

            // Download encrypted file from IPFS
            await downloadEncryptedFile();

        }} catch (err) {{
            setStatus('Purchase failed: ' + err.message, 'error');
            $('purchaseBtn').disabled = false;
        }}
    }}

    // ═══════════════════════════════════════════════════════════════════
    //  DOWNLOAD & DECRYPT
    // ═══════════════════════════════════════════════════════════════════

    async function downloadEncryptedFile() {{
        try {{
            setProgress(70);

            // Try multiple IPFS gateways
            const gateways = [
                `https://gateway.pinata.cloud/ipfs/${{CONFIG.ipfsCID}}`,
                `https://ipfs.io/ipfs/${{CONFIG.ipfsCID}}`,
                `https://cloudflare-ipfs.com/ipfs/${{CONFIG.ipfsCID}}`,
                `https://dweb.link/ipfs/${{CONFIG.ipfsCID}}`
            ];

            let response = null;
            for (const url of gateways) {{
                try {{
                    response = await fetch(url);
                    if (response.ok) break;
                }} catch (e) {{ continue; }}
            }}

            if (!response || !response.ok) {{
                throw new Error('Could not download from any IPFS gateway');
            }}

            encryptedData = new Uint8Array(await response.arrayBuffer());
            setProgress(85);

            setStatus('File downloaded! Decrypting...', 'success');

            // Decrypt
            await decryptAndOffer();

        }} catch (err) {{
            setStatus('Download failed: ' + err.message, 'error');
        }}
    }}

    async function decryptAndOffer() {{
        try {{
            // Parse key from hex
            let keyBytes;
            if (typeof decryptionKey === 'string') {{
                keyBytes = hexToBytes(decryptionKey.startsWith('0x')
                    ? decryptionKey.slice(2) : decryptionKey);
            }} else {{
                keyBytes = new Uint8Array(decryptionKey);
            }}

            // Parse encrypted data: [12-byte nonce][16-byte tag][ciphertext]
            const nonce = encryptedData.slice(0, 12);
            const tag = encryptedData.slice(12, 28);
            const ciphertext = encryptedData.slice(28);

            // Combine ciphertext + tag for WebCrypto (GCM appends tag)
            const ciphertextWithTag = new Uint8Array(ciphertext.length + tag.length);
            ciphertextWithTag.set(ciphertext);
            ciphertextWithTag.set(tag, ciphertext.length);

            // Import key
            const cryptoKey = await crypto.subtle.importKey(
                'raw', keyBytes, 'AES-GCM', false, ['decrypt']
            );

            // Build additional data (original filename)
            const encoder = new TextEncoder();
            const aad = encoder.encode(CONFIG.originalFilename);

            // Decrypt
            const decrypted = await crypto.subtle.decrypt(
                {{ name: 'AES-GCM', iv: nonce, additionalData: aad, tagLength: 128 }},
                cryptoKey,
                ciphertextWithTag
            );

            setProgress(100);

            // Offer download
            const blob = new Blob([decrypted]);
            const url = URL.createObjectURL(blob);
            window._decryptedURL = url;

            hide('purchaseBtn');
            show('downloadBtn');
            setStatus('✅ Decryption successful! Click to download.', 'success');

        }} catch (err) {{
            setStatus('Decryption failed: ' + err.message, 'error');
        }}
    }}

    function downloadDecrypted() {{
        if (!window._decryptedURL) return;
        const a = document.createElement('a');
        a.href = window._decryptedURL;
        a.download = CONFIG.originalFilename;
        document.body.appendChild(a);
        a.click();
        document.body.removeChild(a);
    }}

    // ═══════════════════════════════════════════════════════════════════
    //  UTILITIES
    // ═══════════════════════════════════════════════════════════════════

    function hexToBytes(hex) {{
        const bytes = new Uint8Array(hex.length / 2);
        for (let i = 0; i < hex.length; i += 2) {{
            bytes[i / 2] = parseInt(hex.substr(i, 2), 16);
        }}
        return bytes;
    }}

    // ═══════════════════════════════════════════════════════════════════
    //  INIT
    // ═══════════════════════════════════════════════════════════════════

    // Load ethers.js from CDN
    const script = document.createElement('script');
    script.src = 'https://cdnjs.cloudflare.com/ajax/libs/ethers/6.9.0/ethers.umd.min.js';
    script.onload = () => {{ checkStatus(); }};
    document.head.appendChild(script);

    // Listen for account/network changes
    if (window.ethereum) {{
        window.ethereum.on('accountsChanged', () => location.reload());
        window.ethereum.on('chainChanged', () => location.reload());
    }}
    </script>
</body>
</html>"""

    return html


# ═══════════════════════════════════════════════════════════════════════════════
#  5. ORCHESTRATOR — Main Pipeline
# ═══════════════════════════════════════════════════════════════════════════════

def run_encrypt(args):
    """Encrypt file, upload to IPFS, generate config."""
    print("\n╔══════════════════════════════════════════════════════════════╗")
    print("║          CRYPTO VENDING MACHINE — Encrypt & Prepare        ║")
    print("╚══════════════════════════════════════════════════════════════╝\n")

    input_path = args.file
    price_eth  = args.price

    if not os.path.isfile(input_path):
        print(f"  ✗ File not found: {input_path}")
        sys.exit(1)

    original_filename = Path(input_path).name
    file_size = os.path.getsize(input_path)

    print(f"  File: {original_filename} ({file_size:,} bytes)")
    print(f"  Price: {price_eth} ETH\n")

    # Step 1: Encrypt
    print("  [1/4] Encrypting file with AES-256-GCM...")
    key, nonce, tag, ciphertext = encrypt_file(input_path)
    print(f"  ✓ Encrypted ({len(ciphertext):,} bytes ciphertext)")
    print(f"  ✓ Key: {key.hex()}")

    # Step 2: Save encrypted file
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    encrypted_path = OUTPUT_DIR / f"{original_filename}.encrypted"
    save_encrypted_file(nonce, tag, ciphertext, str(encrypted_path))
    print(f"\n  [2/4] Saved encrypted file: {encrypted_path}")

    # Step 3: Upload to IPFS
    print(f"\n  [3/4] Uploading encrypted file to IPFS...")
    ipfs_cid = upload_to_ipfs(str(encrypted_path))

    # Step 4: Save configuration
    config = {
        "created_at": datetime.now(timezone.utc).isoformat(),
        "original_filename": original_filename,
        "original_size": file_size,
        "encrypted_size": len(nonce) + len(tag) + len(ciphertext),
        "encryption": {
            "algorithm": "AES-256-GCM",
            "key_hex": key.hex(),
            "nonce_hex": nonce.hex(),
            "tag_hex": tag.hex(),
        },
        "ipfs": {
            "encrypted_file_cid": ipfs_cid,
            "gateway_url": f"{IPFS_GATEWAY}{ipfs_cid}",
        },
        "sale": {
            "price_eth": price_eth,
            "price_wei": str(int(float(price_eth) * 1e18)),
        },
        "contract": {
            "address": None,   # filled after deploy
            "network": None,
            "chain_id": None,
        },
        "frontend": {
            "cid": None,       # filled after deploy
        }
    }

    config_path = OUTPUT_DIR / "config.json"
    with open(config_path, "w") as f:
        json.dump(config, f, indent=2)

    print(f"\n  [4/4] Configuration saved: {config_path}")
    print(f"\n  ⚠ IMPORTANT: Keep config.json safe — it contains the encryption key!")
    print(f"\n  Next step: deploy with:")
    print(f"    python crypto_vending_machine.py deploy --config {config_path} --network sepolia\n")

    return config


def run_deploy(args):
    """Deploy contract and frontend to the specified network."""
    print("\n╔══════════════════════════════════════════════════════════════╗")
    print("║          CRYPTO VENDING MACHINE — Deploy Contract          ║")
    print("╚══════════════════════════════════════════════════════════════╝\n")

    if not HAS_WEB3:
        print("  ✗ web3 library required. Install with: pip install web3 eth-account")
        sys.exit(1)

    # Load config
    config_path = args.config
    with open(config_path, "r") as f:
        config = json.load(f)

    network = args.network
    if network not in NETWORKS:
        print(f"  ✗ Unknown network: {network}")
        print(f"    Available: {', '.join(NETWORKS.keys())}")
        sys.exit(1)

    net_info = NETWORKS[network]
    rpc_url  = os.getenv("RPC_URL", net_info["rpc"])
    chain_id = net_info["chain_id"]

    private_key = os.getenv("PRIVATE_KEY")
    if not private_key:
        print("  ✗ Set PRIVATE_KEY environment variable")
        sys.exit(1)

    print(f"  Network: {network} (chain {chain_id})")
    print(f"  RPC: {rpc_url}")

    # Connect
    w3 = Web3(Web3.HTTPProvider(rpc_url))
    if not w3.is_connected():
        print(f"  ✗ Cannot connect to {rpc_url}")
        sys.exit(1)

    account = Account.from_key(private_key)
    balance = w3.eth.get_balance(account.address)
    print(f"  Deployer: {account.address}")
    print(f"  Balance: {w3.from_wei(balance, 'ether')} ETH\n")

    # Compile contract
    print("  [1/4] Compiling contract...")
    abi, bytecode = compile_contract()
    if bytecode is None:
        print("  ✗ No bytecode available. Compile the contract first:")
        print("    pip install py-solc-x")
        print("    # or compile manually with solc")
        sys.exit(1)

    # Generate frontend (with placeholder address first)
    print("\n  [2/4] Generating buyer frontend...")
    placeholder_addr = "0x" + "0" * 40

    # Deploy contract
    print("\n  [3/4] Deploying contract...")
    encryption_key = bytes.fromhex(config["encryption"]["key_hex"])
    price_wei = int(config["sale"]["price_wei"])
    ipfs_cid = config["ipfs"]["encrypted_file_cid"]

    contract_address = deploy_contract(
        w3, account, abi, bytecode,
        price_wei, ipfs_cid, "",  # frontend CID filled later
        encryption_key
    )

    # Now generate frontend with real address and upload
    frontend_html = generate_frontend(
        contract_address=contract_address,
        chain_id=chain_id,
        price_eth=config["sale"]["price_eth"],
        ipfs_cid=ipfs_cid,
        original_filename=config["original_filename"],
        abi=abi,
        network_name=network
    )

    frontend_path = OUTPUT_DIR / "buyer_page.html"
    with open(frontend_path, "w") as f:
        f.write(frontend_html)
    print(f"  ✓ Frontend saved: {frontend_path}")

    print("\n  [4/4] Uploading frontend to IPFS...")
    frontend_cid = upload_to_ipfs(str(frontend_path))

    # Update config
    config["contract"]["address"]  = contract_address
    config["contract"]["network"]  = network
    config["contract"]["chain_id"] = chain_id
    config["frontend"]["cid"]      = frontend_cid

    with open(config_path, "w") as f:
        json.dump(config, f, indent=2)

    print(f"\n{'='*60}")
    print(f"  🎉 DEPLOYMENT COMPLETE!")
    print(f"{'='*60}")
    print(f"  Contract:  {contract_address}")
    print(f"  Network:   {network}")
    print(f"  File CID:  {ipfs_cid}")
    print(f"  Frontend:  {IPFS_GATEWAY}{frontend_cid}")
    print(f"  Price:     {config['sale']['price_eth']} ETH")
    print(f"{'='*60}")
    print(f"\n  Share this link with buyers:")
    print(f"  → https://ipfs.io/ipfs/{frontend_cid}\n")


def run_full(args):
    """Full pipeline: encrypt → deploy."""
    config = run_encrypt(args)

    if args.network:
        # Update args with config path for deploy
        args.config = str(OUTPUT_DIR / "config.json")
        run_deploy(args)
    else:
        print("  Skipping deployment (no --network specified)")


def run_decrypt_test(args):
    """Test decryption of an encrypted file using the config."""
    print("\n  Testing decryption...")

    with open(args.config, "r") as f:
        config = json.load(f)

    key = bytes.fromhex(config["encryption"]["key_hex"])
    encrypted_path = OUTPUT_DIR / f"{config['original_filename']}.encrypted"

    with open(encrypted_path, "rb") as f:
        encrypted_data = f.read()

    plaintext = decrypt_file(key, encrypted_data, config["original_filename"])

    output_path = OUTPUT_DIR / f"decrypted_{config['original_filename']}"
    with open(output_path, "wb") as f:
        f.write(plaintext)

    print(f"  ✓ Decrypted to: {output_path}")
    print(f"  ✓ Size: {len(plaintext):,} bytes")


# ═══════════════════════════════════════════════════════════════════════════════
#  6. CLI
# ═══════════════════════════════════════════════════════════════════════════════

def main():
    parser = argparse.ArgumentParser(
        description="Crypto Vending Machine — Sell encrypted files on Ethereum + IPFS",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # Encrypt a file and prepare for sale
  python crypto_vending_machine.py encrypt --file secret.pdf --price 0.01

  # Deploy to Sepolia testnet
  python crypto_vending_machine.py deploy --config output/config.json --network sepolia

  # Full pipeline (encrypt + deploy)
  python crypto_vending_machine.py full --file secret.pdf --price 0.01 --network sepolia

  # Test decryption locally
  python crypto_vending_machine.py test-decrypt --config output/config.json

Environment:
  PRIVATE_KEY       Deployer wallet private key
  RPC_URL           Ethereum JSON-RPC endpoint
  IPFS_API_URL      IPFS HTTP API (default: http://127.0.0.1:5001)
        """
    )

    subparsers = parser.add_subparsers(dest="command", help="Command")

    # encrypt
    enc = subparsers.add_parser("encrypt", help="Encrypt file and upload to IPFS")
    enc.add_argument("--file", "-f", required=True, help="File to encrypt and sell")
    enc.add_argument("--price", "-p", required=True, help="Price in ETH (e.g. 0.01)")

    # deploy
    dep = subparsers.add_parser("deploy", help="Deploy contract and frontend")
    dep.add_argument("--config", "-c", required=True, help="Path to config.json")
    dep.add_argument("--network", "-n", required=True,
                     choices=list(NETWORKS.keys()), help="Target network")

    # full
    full = subparsers.add_parser("full", help="Full pipeline: encrypt + deploy")
    full.add_argument("--file", "-f", required=True, help="File to encrypt and sell")
    full.add_argument("--price", "-p", required=True, help="Price in ETH")
    full.add_argument("--network", "-n", choices=list(NETWORKS.keys()),
                      help="Deploy to network (omit for encrypt-only)")

    # test-decrypt
    td = subparsers.add_parser("test-decrypt", help="Test decryption locally")
    td.add_argument("--config", "-c", required=True, help="Path to config.json")

    args = parser.parse_args()

    if args.command == "encrypt":
        run_encrypt(args)
    elif args.command == "deploy":
        run_deploy(args)
    elif args.command == "full":
        run_full(args)
    elif args.command == "test-decrypt":
        run_decrypt_test(args)
    else:
        parser.print_help()


if __name__ == "__main__":
    main()
