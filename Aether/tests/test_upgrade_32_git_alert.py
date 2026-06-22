import subprocess
from unittest.mock import MagicMock
import pytest
import aether_tick

def test_git_push_alert(tmp_path, monkeypatch, capsys):
    original_run = subprocess.run
    # Hermetic: redirect REPO_ROOT so last_update.json / dashboard writes land in tmp_path
    monkeypatch.setattr(aether_tick, "REPO_ROOT", tmp_path)
    def mock_run(cmd, *args, **kwargs):
        mock_res = MagicMock()
        mock_res.returncode = 0
        mock_res.stdout = b""
        mock_res.stderr = b""
        
        # Determine if text=True was passed
        text_mode = kwargs.get('text', False)
        
        if "diff-index" in cmd:
            mock_res.returncode = 1 # has local changes
            return mock_res
        if "commit" in cmd:
            if text_mode:
                mock_res.stdout = ""
                mock_res.stderr = ""
            return mock_res
        if "status" in cmd:
            if text_mode:
                mock_res.stdout = "M file.py"
                mock_res.stderr = ""
            else:
                mock_res.stdout = b"M file.py"
            return mock_res
        if "stash" in cmd:
            if text_mode:
                mock_res.stdout = ""
                mock_res.stderr = ""
            return mock_res
        if "fetch" in cmd:
            return mock_res
        if "merge" in cmd:
            return mock_res
        if "push" in cmd:
            mock_res.returncode = 1
            if text_mode:
                mock_res.stderr = "fatal: remote rejected"
                mock_res.stdout = ""
            else:
                mock_res.stderr = b"fatal: remote rejected"
            return mock_res
            
        if text_mode:
            mock_res.stdout = ""
            mock_res.stderr = ""
        return mock_res
        
    monkeypatch.setattr(subprocess, "run", mock_run)
    monkeypatch.setattr(aether_tick, "_check_core_file_changes", lambda *args: False)
    
    aether_tick.rebuild_commit_push()
    
    captured = capsys.readouterr()
    assert "[ALERT] git_publish_failed step=push" in captured.out
