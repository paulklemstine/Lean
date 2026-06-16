#!/usr/bin/env python3
"""Shared utilities for archive/backfill operations.

This module exists to avoid circular imports between backfill,
single-job packaging, and archive_manager.
"""

import asyncio
import logging
import os
import sys
from pathlib import Path
from typing import Optional

import httpx

sys.path.insert(0, str(Path(__file__).parent))

import aristotlelib.api_request as api_request


async def get_api_key() -> str:
    """Load Aristotle API key from env or config.yaml."""
    key = os.environ.get("ARISTOTLE_API_KEY", "")
    if not key:
        try:
            import yaml
            cfg_path = Path(__file__).parent / "config.yaml"
            if cfg_path.exists():
                cfg = yaml.safe_load(cfg_path.read_text())
                key = cfg.get("aristotle", {}).get("api_key", "")
                if key.startswith("${"):
                    key = os.environ.get(key.strip("${}"), "")
        except Exception:
            pass
    if not key:
        raise RuntimeError("ARISTOTLE_API_KEY required")
    return key


def get_api_base_url() -> str:
    """Return the configured Aristotle API base URL."""
    return api_request.BASE_URL


async def stream_download(
    url: str,
    dest: Path,
    api_key: str,
    timeout: float = 600.0,
    chunk_size: int = 8192,
) -> None:
    """Stream a download to disk without holding the whole response in RAM."""
    headers = {"X-API-Key": api_key}
    tmo = httpx.Timeout(timeout, connect=30.0, read=timeout, write=30.0)
    async with httpx.AsyncClient(timeout=tmo, follow_redirects=True) as client:
        async with client.stream("GET", url, headers=headers) as response:
            response.raise_for_status()
            with dest.open("wb") as f:
                async for chunk in response.aiter_bytes(chunk_size=chunk_size):
                    f.write(chunk)


def set_max_memory_mb(mb: Optional[int]) -> None:
    """Cap this process's address space so an in-memory leak causes MemoryError
    instead of killing the WSL2 VM via the OOM killer.
    """
    if not mb or mb <= 0:
        return
    try:
        import resource
        limit = mb * 1024 * 1024
        resource.setrlimit(resource.RLIMIT_AS, (limit, limit))
        logging.info("[Archive] Set process address-space limit to %s MB", mb)
    except Exception as e:
        logging.warning("[Archive] Could not set memory limit: %s", e)


def mem_mb() -> Optional[float]:
    """Return current process RSS in MB, if psutil is available."""
    try:
        import psutil
        proc = psutil.Process(os.getpid())
        return round(proc.memory_info().rss / (1024 * 1024), 2)
    except Exception:
        return None


def log_extra_context() -> str:
    mem = mem_mb()
    if mem is not None:
        return f" mem={mem}MB"
    return ""
