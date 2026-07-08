import pytest

def test_thompson_sampling_bandit(tmp_path):
    from pi_agent_client import select_phase_a_prompt_version
    import cycle_analytics
    
    class MockCA:
        def __init__(self, *args, **kwargs):
            pass
        def get_prompt_version_stats(self):
            return {
                "v19": {"count": 50, "avg_quality": 0.9},
                "v19a": {"count": 50, "avg_quality": 0.1},
                "v19b": {"count": 50, "avg_quality": 0.1},
                "v19c": {"count": 50, "avg_quality": 0.1},
                "v19d": {"count": 50, "avg_quality": 0.1},
                "v24": {"count": 50, "avg_quality": 0.1},
                "v25": {"count": 50, "avg_quality": 0.1},
                "v26": {"count": 50, "avg_quality": 0.1},
                "v27": {"count": 50, "avg_quality": 0.1},
                "v28": {"count": 50, "avg_quality": 0.1},
            }
            
    cycle_analytics.CycleAnalytics = MockCA
    
    counts = {}
    for _ in range(200):
        c = select_phase_a_prompt_version(workspace_dir=tmp_path)
        counts[c] = counts.get(c, 0) + 1
        
    assert counts.get("v19", 0) > counts.get("v19a", 0), f"v19={counts.get('v19', 0)} should beat v19a={counts.get('v19a', 0)}"
    
    class MockCA2:
        def __init__(self, *args, **kwargs):
            pass
        def get_prompt_version_stats(self):
            return {
                "v19": {"n": 20, "avg_Q": 0.9},
                "v19a": {"n": 20, "avg_Q": 0.1},
            }
    cycle_analytics.CycleAnalytics = MockCA2
    
    counts2 = {"v19": 0, "v19a": 0}
    for _ in range(200):
        c = select_phase_a_prompt_version(workspace_dir=tmp_path)
        if c in counts2:
            counts2[c] += 1
            
    # Expected ~40 each
    assert counts2["v19"] < 100
    assert counts2["v19a"] > 20

