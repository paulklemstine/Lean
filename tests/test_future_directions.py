"""Tests for Aether/research_memory.py — FutureDirectionsManager logic."""

import sys
from pathlib import Path
from tempfile import mkdtemp

import pytest

# Ensure Aether/ is on sys.path for imports
sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "Aether"))


class TestInferDomainsFixA:
    """The root-cause bug: _infer_domains must return [] on no match."""

    def test_no_bridges_fallback(self):
        from research_memory import FutureDirectionsManager

        tmpdir = mkdtemp()
        mgr = FutureDirectionsManager(Path(tmpdir))
        result = mgr._infer_domains("The quick brown fox jumps over the lazy dog")
        assert result == [], f"Expected [], got {result}"

    def test_known_domain_still_works(self):
        from research_memory import FutureDirectionsManager

        tmpdir = mkdtemp()
        mgr = FutureDirectionsManager(Path(tmpdir))
        result = mgr._infer_domains("Prove a Goldbach conjecture about primes")
        assert len(result) >= 1
