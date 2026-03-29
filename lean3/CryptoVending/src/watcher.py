"""
watcher.py – Seller-side daemon that watches for PurchaseInitiated events
and automatically delivers ECIES-encrypted AES keys to buyers.

Usage
-----
    python -m src.watcher --artifact deployment.json --key-hex <AES_KEY_HEX>

Or programmatically:

    from src.watcher import KeyDeliveryWatcher
    watcher = KeyDeliveryWatcher(w3, contract, aes_key, seller_private_key)
    watcher.run()
"""

import time
import json
import argparse
import logging
from typing import Optional

logging.basicConfig(level=logging.INFO,
                    format="%(asctime)s  %(levelname)-8s  %(message)s")
log = logging.getLogger("watcher")


class KeyDeliveryWatcher:
    """
    Watches for ``PurchaseInitiated`` events on a deployed
    FileVendingMachine contract, encrypts the AES key with the buyer's
    ECIES public key, and calls ``deliverKey``.
    """

    def __init__(self, w3, contract, aes_key: bytes,
                 seller_private_key: str,
                 poll_interval: float = 5.0):
        self.w3 = w3
        self.contract = contract
        self.aes_key = aes_key
        self.seller_private_key = seller_private_key
        self.poll_interval = poll_interval
        self._last_block = max(0, w3.eth.block_number - 100)

    # ------------------------------------------------------------------
    def _encrypt_key_for_buyer(self, buyer_pubkey: bytes) -> bytes:
        from src.crypto_utils import encrypt_for_buyer
        return encrypt_for_buyer(self.aes_key, buyer_pubkey)

    def _deliver_key(self, purchase_id: int, encrypted_key: bytes):
        account = self.w3.eth.account.from_key(self.seller_private_key)
        tx = self.contract.functions.deliverKey(
            purchase_id, encrypted_key
        ).build_transaction({
            "from": account.address,
            "nonce": self.w3.eth.get_transaction_count(account.address),
            "gas": 300_000,
            "gasPrice": self.w3.eth.gas_price,
        })
        signed = account.sign_transaction(tx)
        tx_hash = self.w3.eth.send_raw_transaction(signed.raw_transaction)
        receipt = self.w3.eth.wait_for_transaction_receipt(tx_hash)
        return receipt

    # ------------------------------------------------------------------
    def process_events(self):
        """Poll for new PurchaseInitiated events and deliver keys."""
        current_block = self.w3.eth.block_number
        if current_block <= self._last_block:
            return

        event_filter = self.contract.events.PurchaseInitiated.get_logs(
            fromBlock=self._last_block + 1,
            toBlock=current_block,
        )

        for event in event_filter:
            pid = event["args"]["purchaseId"]
            buyer = event["args"]["buyer"]
            pubkey = event["args"]["buyerPublicKey"]
            amount = event["args"]["amount"]

            log.info("Purchase #%d from %s (%.6f ETH)",
                     pid, buyer,
                     self.w3.from_wei(amount, "ether"))

            # Check if key already delivered
            purchase = self.contract.functions.purchases(pid).call()
            if purchase[3]:  # keyDelivered
                log.info("  Key already delivered for purchase #%d", pid)
                continue

            try:
                encrypted_key = self._encrypt_key_for_buyer(pubkey)
                receipt = self._deliver_key(pid, encrypted_key)
                log.info("  ✓ Key delivered  tx=%s  gas=%d",
                         receipt.transactionHash.hex(),
                         receipt.gasUsed)
            except Exception as exc:
                log.error("  ✗ Failed to deliver key for purchase #%d: %s",
                          pid, exc)

        self._last_block = current_block

    # ------------------------------------------------------------------
    def run(self):
        """Run the watcher loop forever."""
        log.info("Watcher started — polling every %.1fs", self.poll_interval)
        log.info("Contract: %s", self.contract.address)
        try:
            while True:
                self.process_events()
                time.sleep(self.poll_interval)
        except KeyboardInterrupt:
            log.info("Watcher stopped.")


# ---------------------------------------------------------------------------
#  CLI
# ---------------------------------------------------------------------------

def main():
    parser = argparse.ArgumentParser(
        description="Watch for purchases and deliver decryption keys.")
    parser.add_argument("--artifact", required=True,
                        help="Path to deployment artifact JSON")
    parser.add_argument("--seller-key", required=True,
                        help="Seller private key (hex)")
    parser.add_argument("--rpc", default=None,
                        help="RPC URL override")
    parser.add_argument("--poll", type=float, default=5.0,
                        help="Poll interval in seconds")
    args = parser.parse_args()

    from src.contract_utils import load_deployment_artifact, get_web3

    artifact = load_deployment_artifact(args.artifact)
    w3 = get_web3(network=artifact.get("network", "localhost"),
                  rpc_url=args.rpc)
    contract = w3.eth.contract(
        address=artifact["contract_address"],
        abi=artifact["abi"],
    )
    aes_key = bytes.fromhex(artifact["aes_key_hex"])

    watcher = KeyDeliveryWatcher(
        w3, contract, aes_key, args.seller_key, args.poll)
    watcher.run()


if __name__ == "__main__":
    main()
