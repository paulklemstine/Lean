import tempfile
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).parent))
from pollinations_pollen import PollinationsPollenConfig, PollinationsPollenGate


def test_local_hourly_budget_allows_remaining_pollen_after_chat_call():
    state_path = Path(tempfile.mkdtemp()) / "pollen.json"
    gate = PollinationsPollenGate(
        PollinationsPollenConfig(
            enabled=True,
            defer_when_low=False,
            hourly_allowance=0.4,
            estimated_pollen_per_call=0.008,
            estimated_pollen_per_pi_execution=0.05,
            state_path=state_path,
        )
    )

    gate.wait_and_reserve("chat evaluation", kind="chat", input_chars=5000)
    wait_seconds, reason, _ = gate._seconds_until_available(0.05)

    assert wait_seconds == 0
    assert reason == ""


def test_local_hourly_budget_defers_when_requested_cost_exceeds_remaining():
    state_path = Path(tempfile.mkdtemp()) / "pollen.json"
    gate = PollinationsPollenGate(
        PollinationsPollenConfig(
            enabled=True,
            defer_when_low=False,
            hourly_allowance=0.4,
            estimated_pollen_per_call=0.008,
            state_path=state_path,
        )
    )

    gate.wait_and_reserve("large call", cost=0.392)
    wait_seconds, reason, _ = gate._seconds_until_available(0.05)

    assert wait_seconds > 0
    assert "available pollen" in reason


def test_forecast_accumulates_running_average_by_kind_and_size():
    state_path = Path(tempfile.mkdtemp()) / "pollen.json"
    gate = PollinationsPollenGate(
        PollinationsPollenConfig(
            enabled=True,
            defer_when_low=False,
            hourly_allowance=0.4,
            estimated_pollen_per_call=0.008,
            forecast_safety_multiplier=1.0,
            state_path=state_path,
        )
    )

    gate.record_observation(
        kind="chat",
        input_chars=10000,
        predicted_cost=0.01,
        actual_cost=0.02,
        success=True,
    )
    predicted = gate.forecast_cost(kind="chat", input_chars=20000)

    assert predicted == 0.04


def test_forecast_defers_when_predicted_request_will_not_fit():
    state_path = Path(tempfile.mkdtemp()) / "pollen.json"
    gate = PollinationsPollenGate(
        PollinationsPollenConfig(
            enabled=True,
            defer_when_low=False,
            hourly_allowance=0.4,
            estimated_pollen_per_call=0.008,
            forecast_safety_multiplier=1.0,
            state_path=state_path,
        )
    )

    reservation = gate.wait_and_reserve("prior work", cost=0.38, kind="setup")
    gate.record_observation(reservation=reservation, actual_cost=0.38, success=True)
    gate.record_observation(
        kind="chat",
        input_chars=10000,
        predicted_cost=0.01,
        actual_cost=0.02,
        success=True,
    )
    predicted = gate.forecast_cost(kind="chat", input_chars=20000)
    wait_seconds, reason, _ = gate._seconds_until_available(predicted)

    assert predicted == 0.04
    assert wait_seconds > 0
    assert "available pollen" in reason


def test_reservation_is_released_on_failed_request():
    state_path = Path(tempfile.mkdtemp()) / "pollen.json"
    gate = PollinationsPollenGate(
        PollinationsPollenConfig(
            enabled=True,
            defer_when_low=False,
            hourly_allowance=0.4,
            estimated_pollen_per_call=0.05,
            state_path=state_path,
        )
    )

    reservation = gate.wait_and_reserve("failed call", kind="chat", input_chars=1000)
    gate.record_observation(reservation=reservation, success=False)
    state = gate._load_state()

    assert state["spent"] == 0.0
    assert state["reserved"] == {}


def test_successful_request_settles_reservation_to_actual_cost():
    state_path = Path(tempfile.mkdtemp()) / "pollen.json"
    gate = PollinationsPollenGate(
        PollinationsPollenConfig(
            enabled=True,
            defer_when_low=False,
            hourly_allowance=0.4,
            estimated_pollen_per_call=0.05,
            state_path=state_path,
        )
    )

    reservation = gate.wait_and_reserve("successful call", kind="chat", input_chars=1000)
    gate.record_observation(reservation=reservation, actual_cost=0.012, success=True)
    state = gate._load_state()

    assert state["spent"] == 0.012
    assert state["reserved"] == {}
