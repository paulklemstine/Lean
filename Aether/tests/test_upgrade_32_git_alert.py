import subprocess
from unittest.mock import MagicMock
import pytest
import aether_tick

def test_git_push_alert(monkeypatch, capsys):
    original_run = subprocess.run
    
    def mock_run(cmd, *args, **kwargs):
        if "commit" in cmd:
            mock_res = MagicMock()
            mock_res.returncode = 0
            mock_res.stdout = b""
            mock_res.stderr = b""
            return mock_res
        if "status" in cmd:
            mock_res = MagicMock()
            mock_res.stdout = "M file.py"
            mock_res.stderr = ""
            return mock_res
        if "stash" in cmd:
            mock_res = MagicMock()
            mock_res.returncode = 0
            mock_res.stdout = ""
            mock_res.stderr = ""
            return mock_res
        if "merge" in cmd:
            mock_res = MagicMock()
            mock_res.returncode = 0
            mock_res.stdout = ""
            mock_res.stderr = ""
            return mock_res
        if "fetch" in cmd:
            mock_res = MagicMock()
            mock_res.returncode = 0
            return mock_res
        if "push" in cmd:
            mock_res = MagicMock()
            mock_res.returncode = 1
            mock_res.stderr = "fatal: remote rejected"
            mock_res.stdout = ""
            return mock_res
        return original_run(cmd, *args, **kwargs)
        
    monkeypatch.setattr(subprocess, "run", mock_run)
    monkeypatch.setattr(aether_tick, "_check_core_file_changes", lambda *args: False)
    
    aether_tick.rebuild_commit_push()
    
    captured = capsys.readouterr()
    assert "[ALERT] git_publish_failed step=push" in captured.out
