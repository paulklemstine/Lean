"""
ipfs_utils.py – Upload / download helpers for IPFS.

Supports:
  • Local IPFS daemon via the HTTP API  (ipfshttpclient)
  • Pinata cloud pinning service         (requests)
  • Mock mode for offline testing
"""

import os
import json
import tempfile
from pathlib import Path
from typing import Optional


# ---------------------------------------------------------------------------
#  Backend selection
# ---------------------------------------------------------------------------

class IPFSBackend:
    """Abstract IPFS backend."""

    def add_bytes(self, data: bytes, filename: str = "file") -> str:
        """Upload raw bytes, return CID string."""
        raise NotImplementedError

    def add_file(self, filepath: str) -> str:
        """Upload a file, return CID."""
        return self.add_bytes(Path(filepath).read_bytes(),
                              Path(filepath).name)

    def cat(self, cid: str) -> bytes:
        """Download bytes by CID."""
        raise NotImplementedError

    def gateway_url(self, cid: str) -> str:
        """Public gateway URL for the CID."""
        return f"https://ipfs.io/ipfs/{cid}"


# ---------------------------------------------------------------------------
#  Local daemon
# ---------------------------------------------------------------------------

class LocalIPFS(IPFSBackend):
    """Talks to a locally running `ipfs daemon`."""

    def __init__(self, api_addr: str = "/ip4/127.0.0.1/tcp/5001"):
        try:
            import ipfshttpclient
            self._client = ipfshttpclient.connect(api_addr)
        except Exception as exc:
            raise ConnectionError(
                f"Cannot connect to local IPFS daemon at {api_addr}. "
                "Start it with `ipfs daemon`.") from exc

    def add_bytes(self, data: bytes, filename: str = "file") -> str:
        res = self._client.add_bytes(data)
        # ipfshttpclient returns a CID string directly
        return res if isinstance(res, str) else res["Hash"]

    def cat(self, cid: str) -> bytes:
        return self._client.cat(cid)


# ---------------------------------------------------------------------------
#  Pinata (cloud)
# ---------------------------------------------------------------------------

class PinataIPFS(IPFSBackend):
    """Uses Pinata's pinning API (requires PINATA_API_KEY & PINATA_SECRET)."""

    PINATA_BASE = "https://api.pinata.cloud"

    def __init__(self,
                 api_key: Optional[str] = None,
                 secret: Optional[str] = None):
        import requests as _req
        self._req = _req
        self.api_key = api_key or os.environ.get("PINATA_API_KEY", "")
        self.secret  = secret  or os.environ.get("PINATA_SECRET", "")
        if not self.api_key or not self.secret:
            raise ValueError(
                "Set PINATA_API_KEY and PINATA_SECRET env vars, "
                "or pass them explicitly.")

    def _headers(self):
        return {
            "pinata_api_key": self.api_key,
            "pinata_secret_api_key": self.secret,
        }

    def add_bytes(self, data: bytes, filename: str = "file") -> str:
        url = f"{self.PINATA_BASE}/pinning/pinFileToIPFS"
        # Write to a temp file because Pinata expects multipart upload
        with tempfile.NamedTemporaryFile(delete=False,
                                         suffix=f"_{filename}") as tmp:
            tmp.write(data)
            tmp_path = tmp.name
        try:
            with open(tmp_path, "rb") as f:
                resp = self._req.post(
                    url,
                    files={"file": (filename, f)},
                    headers=self._headers(),
                )
            resp.raise_for_status()
            return resp.json()["IpfsHash"]
        finally:
            os.unlink(tmp_path)

    def cat(self, cid: str) -> bytes:
        url = f"https://gateway.pinata.cloud/ipfs/{cid}"
        resp = self._req.get(url)
        resp.raise_for_status()
        return resp.content

    def gateway_url(self, cid: str) -> str:
        return f"https://gateway.pinata.cloud/ipfs/{cid}"


# ---------------------------------------------------------------------------
#  Mock (offline / testing)
# ---------------------------------------------------------------------------

class MockIPFS(IPFSBackend):
    """In-memory mock for testing without a real IPFS node."""

    _store: dict = {}
    _counter = 0

    def add_bytes(self, data: bytes, filename: str = "file") -> str:
        import hashlib
        cid = "Qm" + hashlib.sha256(data).hexdigest()[:44]
        MockIPFS._store[cid] = data
        return cid

    def cat(self, cid: str) -> bytes:
        if cid not in MockIPFS._store:
            raise FileNotFoundError(f"CID {cid} not in mock store")
        return MockIPFS._store[cid]

    def gateway_url(self, cid: str) -> str:
        return f"http://localhost:8080/ipfs/{cid}"


# ---------------------------------------------------------------------------
#  Factory
# ---------------------------------------------------------------------------

def get_ipfs_backend(backend: str = "mock", **kwargs) -> IPFSBackend:
    """
    Get an IPFS backend by name.

    Parameters
    ----------
    backend : 'local' | 'pinata' | 'mock'
    """
    if backend == "local":
        return LocalIPFS(**kwargs)
    elif backend == "pinata":
        return PinataIPFS(**kwargs)
    elif backend == "mock":
        return MockIPFS()
    else:
        raise ValueError(f"Unknown IPFS backend: {backend!r}")
