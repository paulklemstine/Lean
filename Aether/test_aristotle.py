#!/usr/bin/env python3
"""Test Aristotle SDK integration."""

import asyncio
import os
from pathlib import Path

import pytest

from aristotle_sdk_client import AristotleSDKClient, AristotleResult

@pytest.mark.skipif(not os.getenv("RUN_INTEGRATION_TESTS"),
                    reason="integration test: set RUN_INTEGRATION_TESTS=1 to run")
async def test_tropical_firewall():
    """Submit the Tropical Firewall theorem to Aristotle."""
    client = AristotleSDKClient({"api_key": os.environ.get("ARISTOTLE_API_KEY", "")})

    lean_source = """import Mathlib

/-! # Tropical Firewall Determinism

In a black-hole firewall modeled as a tropical variety, determinism
is restored by the absence of additive inverses.
-/

theorem tropical_firewall_determinism
    {R : Type*} [LinearOrder R]
    (a b c : R) (h : max a b = max a c) (hgt : a < max a b) :
    b = c := by
  sorry
"""

    project_dir = Path("./test_job")
    project_dir.mkdir(exist_ok=True)

    print("[TEST] Submitting Tropical Firewall theorem to Aristotle...")
    print(f"[TEST] API Key present: {bool(os.environ.get('ARISTOTLE_API_KEY'))}")

    result = await client.submit_sorry_filling(
        lean_source=lean_source,
        project_dir=project_dir,
        prompt="Prove the theorem tropical_firewall_determinism. Use standard mathlib tactics. The theorem states that in a tropical (max-plus) semiring, if two elements have the same max with a third element, and that third element is strictly less than the max, then the two elements must be equal.",
    )

    print(f"[TEST] Result: {result.status}")
    print(f"[TEST] Project ID: {result.project_id}")
    print(f"[TEST] Latency: {result.latency_seconds:.1f}s")

    if result.lean_source:
        print(f"[TEST] Proof received ({len(result.lean_source)} chars)")
        print("--- PROOF ---")
        print(result.lean_source[:2000])
    else:
        print(f"[TEST] Error: {result.error_message}")

    return result

if __name__ == "__main__":
    asyncio.run(test_tropical_firewall())
