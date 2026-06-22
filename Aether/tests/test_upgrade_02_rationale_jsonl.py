import json
import pytest
from pathlib import Path
from pi_agent_client import PiAgentClient

def test_log_pi_agent_eval(tmp_path, capsys):
    client = PiAgentClient()
    evals_file = tmp_path / "pi_agent_evals.jsonl"
    client.pi_agent_evals_path = evals_file
    
    rationale = {"a": 1}
    client._log_pi_agent_eval(job_id='j1', score=0.55, grade='partial', rationale=rationale)
    
    # Assert file contents
    assert evals_file.exists()
    lines = evals_file.read_text().strip().split('\n')
    assert len(lines) == 1
    
    data = json.loads(lines[0])
    assert "ts" in data
    assert data["job_id"] == "j1"
    assert data["score"] == 0.55
    assert data["grade"] == "partial"
    assert data["rationale"] == rationale
    
    # Assert stdout
    captured = capsys.readouterr()
    assert "[Pi-Agent] eval job=j1 score=0.550 grade=partial" in captured.out
    assert "rationale" not in captured.out
