import pytest

def test_locked_phase_a_prompt_version(tmp_path):
    from pi_agent_client import select_phase_a_prompt_version
    
    for _ in range(50):
        c = select_phase_a_prompt_version(workspace_dir=tmp_path)
        assert c == "v19c"

