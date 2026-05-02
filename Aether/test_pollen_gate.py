import tempfile
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).parent))
from pollinations_pollen import PollinationsPollenConfig, PollinationsPollenGate


def test_local_hourly_budget_defers_after_one_full_allowance():
    state_path = Path(tempfile.mkdtemp()) / "pollen.json"
    gate = PollinationsPollenGate(
        PollinationsPollenConfig(
            enabled=True,
            defer_when_low=False,
            hourly_allowance=0.4,
            estimated_pollen_per_call=0.4,
            state_path=state_path,
        )
    )

    gate.wait_and_reserve("test")
    wait_seconds, reason = gate._seconds_until_available(0.4)

    assert wait_seconds > 0
    assert "local hourly pollen" in reason
