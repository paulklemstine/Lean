"""
contract_utils.py – Compile & deploy the FileVendingMachine Solidity contract.

Uses `solcx` for compilation and `web3.py` for deployment.
"""

import json
import os
from pathlib import Path
from typing import Optional, Tuple, Dict, Any

# ---------------------------------------------------------------------------
#  Compilation
# ---------------------------------------------------------------------------

CONTRACTS_DIR = Path(__file__).resolve().parent.parent / "contracts"
SOL_FILE = CONTRACTS_DIR / "FileVendingMachine.sol"
SOLC_VERSION = "0.8.19"


def compile_contract(sol_path: Optional[str] = None) -> Dict[str, Any]:
    """
    Compile the Solidity contract and return {abi, bytecode}.

    Installs the required solc version automatically.
    """
    import solcx

    sol_path = Path(sol_path) if sol_path else SOL_FILE
    source = sol_path.read_text()

    # Install compiler if needed
    if SOLC_VERSION not in [str(v) for v in solcx.get_installed_solc_versions()]:
        solcx.install_solc(SOLC_VERSION)

    compiled = solcx.compile_source(
        source,
        output_values=["abi", "bin"],
        solc_version=SOLC_VERSION,
    )

    # solcx returns keys like "<stdin>:FileVendingMachine"
    contract_id = None
    for key in compiled:
        if "FileVendingMachine" in key:
            contract_id = key
            break
    if contract_id is None:
        raise RuntimeError("FileVendingMachine not found in compilation output")

    return {
        "abi": compiled[contract_id]["abi"],
        "bytecode": compiled[contract_id]["bin"],
    }


# ---------------------------------------------------------------------------
#  Deployment
# ---------------------------------------------------------------------------

# Well-known RPC endpoints
NETWORKS = {
    "mainnet":  "https://mainnet.infura.io/v3/{INFURA_KEY}",
    "sepolia":  "https://sepolia.infura.io/v3/{INFURA_KEY}",
    "goerli":   "https://goerli.infura.io/v3/{INFURA_KEY}",
    "localhost": "http://127.0.0.1:8545",
    "hardhat":   "http://127.0.0.1:8545",
    "ganache":   "http://127.0.0.1:7545",
}


def get_web3(network: str = "localhost",
             rpc_url: Optional[str] = None,
             infura_key: Optional[str] = None):
    """Return a connected Web3 instance."""
    from web3 import Web3

    if rpc_url is None:
        infura_key = infura_key or os.environ.get("INFURA_KEY", "")
        rpc_url = NETWORKS.get(network, network).replace("{INFURA_KEY}", infura_key)

    w3 = Web3(Web3.HTTPProvider(rpc_url))
    if not w3.is_connected():
        raise ConnectionError(f"Cannot connect to {rpc_url}")
    return w3


def deploy_contract(
    w3,
    abi: list,
    bytecode: str,
    file_cid: str,
    metadata_cid: str,
    price_wei: int,
    key_commitment: bytes,
    single_serving: bool = True,
    deployer_private_key: Optional[str] = None,
    gas_limit: int = 3_000_000,
) -> Tuple[str, Any]:
    """
    Deploy the FileVendingMachine and return (contract_address, tx_receipt).

    Parameters
    ----------
    w3 : Web3 instance
    deployer_private_key : hex-encoded private key.
        If None, uses w3.eth.accounts[0] (e.g. Ganache unlocked accounts).
    """
    from web3 import Web3

    Contract = w3.eth.contract(abi=abi, bytecode=bytecode)

    constructor_args = [
        file_cid,
        metadata_cid,
        price_wei,
        key_commitment,
        single_serving,
    ]

    if deployer_private_key:
        account = w3.eth.account.from_key(deployer_private_key)
        tx = Contract.constructor(*constructor_args).build_transaction({
            "from": account.address,
            "nonce": w3.eth.get_transaction_count(account.address),
            "gas": gas_limit,
            "gasPrice": w3.eth.gas_price,
        })
        signed = account.sign_transaction(tx)
        tx_hash = w3.eth.send_raw_transaction(signed.raw_transaction)
    else:
        # Use first unlocked account (Ganache / Hardhat)
        deployer = w3.eth.accounts[0]
        tx_hash = Contract.constructor(*constructor_args).transact({
            "from": deployer,
            "gas": gas_limit,
        })

    receipt = w3.eth.wait_for_transaction_receipt(tx_hash, timeout=120)
    return receipt.contractAddress, receipt


# ---------------------------------------------------------------------------
#  Artifact management
# ---------------------------------------------------------------------------

def save_deployment_artifact(
    output_path: str,
    contract_address: str,
    abi: list,
    file_cid: str,
    metadata_cid: str,
    price_wei: int,
    network: str,
    key_hex: str,
):
    """Save a JSON artifact with everything needed to interact post-deploy."""
    artifact = {
        "contract_address": contract_address,
        "abi": abi,
        "file_cid": file_cid,
        "metadata_cid": metadata_cid,
        "price_wei": price_wei,
        "network": network,
        "aes_key_hex": key_hex,
    }
    Path(output_path).write_text(json.dumps(artifact, indent=2))
    return artifact


def load_deployment_artifact(path: str) -> Dict[str, Any]:
    """Load a previously saved deployment artifact."""
    return json.loads(Path(path).read_text())
