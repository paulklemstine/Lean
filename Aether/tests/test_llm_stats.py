"""Tests for Phase 0 LLM call accounting (pi_agent.llm_stats)."""
import sys
from pathlib import Path
from unittest.mock import MagicMock

import pytest

sys.path.insert(0, str(Path(__file__).parent.parent))


def _make_pi_agent():
    """Build a PiAgentClient without running __init__ (avoids config/network)."""
    from pi_agent_client import PiAgentClient
    pa = PiAgentClient.__new__(PiAgentClient)
    pa.use_ollama = True  # route _call_ollama to _call_ollama_local (mocked)
    pa.reset_llm_stats()
    return pa


def test_reset_llm_stats():
    pa = _make_pi_agent()
    pa.llm_stats["calls"]["total"] = 99
    pa.reset_llm_stats()
    assert pa.llm_stats["calls"]["total"] == 0
    assert pa.llm_stats["skipped"]["eval"] == 0


def test_record_llm_skip():
    pa = _make_pi_agent()
    pa.record_llm_skip("eval")
    pa.record_llm_skip("eval")
    pa.record_llm_skip("critic")
    assert pa.llm_stats["skipped"]["eval"] == 2
    assert pa.llm_stats["skipped"]["critic"] == 1


def test_call_ollama_counts_by_category():
    pa = _make_pi_agent()
    pa._call_ollama_local = MagicMock(return_value="ok")
    pa._call_ollama("sys", "user", category="eval")
    pa._call_ollama("sys", "user", category="eval")
    pa._call_ollama("sys", "user", category="critic")
    pa._call_ollama("sys", "user")  # default "other"
    assert pa.llm_stats["calls"]["total"] == 4
    assert pa.llm_stats["calls"]["eval"] == 2
    assert pa.llm_stats["calls"]["critic"] == 1
    assert pa.llm_stats["calls"]["other"] == 1


def test_call_ollama_local_invoked_when_use_ollama():
    pa = _make_pi_agent()
    pa._call_ollama_local = MagicMock(return_value="local-ok")
    out = pa._call_ollama("sys", "user", category="lint")
    assert out == "local-ok"
    assert pa.llm_stats["calls"]["lint"] == 1