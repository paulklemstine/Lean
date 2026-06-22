import pytest
import time
import json
import tempfile
from pathlib import Path
from pi_agent_client import PiAgentClient
from pollinations_pollen import PollinationsPollenConfig

class MockPollenGate:
    def __init__(self, state_path):
        self.config = PollinationsPollenConfig(state_path=state_path)

@pytest.fixture
def temp_state_file(tmp_path):
    state_file = tmp_path / "pollinations_pollen_state.json"
    return state_file

def test_circuit_breaker(temp_state_file, monkeypatch):
    client = PiAgentClient()
    client.openrouter_enabled = False
    client.ollama_cloud_enabled = False
    client.pollen_gate = MockPollenGate(temp_state_file)
    client.use_ollama = False

    # Mock time
    current_time = [1000.0]
    monkeypatch.setattr(time, "time", lambda: current_time[0])
    
    call_counts = {"pollinations": 0, "ollama_cloud": 0}

    def mock_call_pollinations(system, user, timeout=None, skip_wait_on_depletion=False):
        call_counts["pollinations"] += 1
        return "[API_ERROR] 402 Pollen depleted"
    
    def mock_call_ollama_cloud(system, user, timeout=None):
        call_counts["ollama_cloud"] += 1
        return "Success from ollama cloud"

    monkeypatch.setattr(client, "_call_pollinations", mock_call_pollinations)
    monkeypatch.setattr(client, "_call_ollama_cloud", mock_call_ollama_cloud)
    
    # Enable ollama cloud to see fallbacks
    client.ollama_cloud_enabled = True
    client.ollama_cloud_api_key = "test_key"

    # Fail 5 times
    for i in range(5):
        result = client._call_ollama("sys", "user")
        assert result == "Success from ollama cloud"
        assert call_counts["pollinations"] == i + 1

    # Now it should be OPEN
    with open(temp_state_file, "r") as f:
        state = json.load(f)
    assert state["state"] == "OPEN"
    assert state["consecutive_402"] == 5

    # 6th call should skip Pollinations
    current_time[0] += 10.0
    result = client._call_ollama("sys", "user")
    assert result == "Success from ollama cloud"
    assert call_counts["pollinations"] == 5 # Didn't increase

    # Advance time by 20 minutes and 1 second
    current_time[0] += 20 * 60 + 1.0

    # 7th call should probe (HALF-OPEN)
    result = client._call_ollama("sys", "user")
    assert result == "Success from ollama cloud"
    assert call_counts["pollinations"] == 6

    # Still returning 402, so should be OPEN again
    with open(temp_state_file, "r") as f:
        state = json.load(f)
    assert state["state"] == "OPEN"
    assert state["consecutive_402"] == 6

    # Advance time again
    current_time[0] += 20 * 60 + 1.0
    
    # Mock success for Pollinations
    def mock_call_pollinations_success(system, user, timeout=None, skip_wait_on_depletion=False):
        call_counts["pollinations"] += 1
        return "Success from pollinations"
    monkeypatch.setattr(client, "_call_pollinations", mock_call_pollinations_success)

    # 8th call should succeed and reset
    result = client._call_ollama("sys", "user")
    assert result == "Success from pollinations"
    assert call_counts["pollinations"] == 7

    with open(temp_state_file, "r") as f:
        state = json.load(f)
    assert state["state"] == "CLOSED"
    assert state["consecutive_402"] == 0
