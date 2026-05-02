#!/usr/bin/env python3
"""Pollen budget gate for Pollinations-backed Pi-Agent calls."""

from __future__ import annotations

import json
import os
import time
from dataclasses import dataclass
from pathlib import Path
from typing import Any, Dict, Optional

import httpx


@dataclass
class PollinationsPollenConfig:
    enabled: bool = True
    defer_when_low: bool = True
    hourly_allowance: float = 0.4
    min_balance: float = 0.0
    estimated_pollen_per_call: float = 0.008
    estimated_pollen_per_pi_execution: float = 0.05
    balance_cache_seconds: int = 60
    reset_buffer_seconds: int = 10
    max_sleep_seconds: int = 30
    forecast_safety_multiplier: float = 1.35
    forecast_alpha: float = 0.25
    chat_input_chars_per_pollen: float = 250000.0
    pi_execution_input_chars_per_pollen: float = 50000.0
    base_url: str = "https://gen.pollinations.ai"
    api_key: str = ""
    state_path: Optional[Path] = None

    @classmethod
    def from_dict(
        cls,
        raw: Optional[Dict[str, Any]],
        *,
        default_state_path: Optional[Path] = None,
    ) -> "PollinationsPollenConfig":
        raw = raw or {}
        api_key = (
            raw.get("api_key")
            or os.getenv(raw.get("api_key_env", "POLLINATIONS_API_KEY"), "")
            or os.getenv("OPENAI_API_KEY", "")
            or ""
        )
        state_path = raw.get("state_path")
        return cls(
            enabled=raw.get("enabled", True),
            defer_when_low=raw.get("defer_when_low", True),
            hourly_allowance=float(raw.get("hourly_allowance", 0.4)),
            min_balance=float(raw.get("min_balance", 0.0)),
            estimated_pollen_per_call=float(raw.get("estimated_pollen_per_call", 0.008)),
            estimated_pollen_per_pi_execution=float(raw.get("estimated_pollen_per_pi_execution", 0.05)),
            balance_cache_seconds=int(raw.get("balance_cache_seconds", 60)),
            reset_buffer_seconds=int(raw.get("reset_buffer_seconds", 10)),
            max_sleep_seconds=int(raw.get("max_sleep_seconds", 30)),
            forecast_safety_multiplier=float(raw.get("forecast_safety_multiplier", 1.35)),
            forecast_alpha=float(raw.get("forecast_alpha", 0.25)),
            chat_input_chars_per_pollen=float(raw.get("chat_input_chars_per_pollen", 250000.0)),
            pi_execution_input_chars_per_pollen=float(raw.get("pi_execution_input_chars_per_pollen", 50000.0)),
            base_url=raw.get("base_url", "https://gen.pollinations.ai").rstrip("/"),
            api_key=api_key,
            state_path=Path(state_path).expanduser() if state_path else default_state_path,
        )


class PollinationsPollenGate:
    """Blocks Pollinations LLM calls until enough hourly pollen is available.

    Pollinations exposes account balance endpoints for keys with account
    permissions. Publishable keys may not have those permissions, so this also
    keeps a local non-rollover hourly budget. The local budget uses conservative
    estimates per operation, instead of reserving the whole 0.4 hourly allowance
    for every small chat-completions call.
    """

    def __init__(
        self,
        config: PollinationsPollenConfig,
        *,
        client: Optional[httpx.Client] = None,
    ):
        self.config = config
        self.client = client
        self._balance_cache: Optional[Dict[str, Any]] = None
        self._balance_cache_at = 0.0
        self._remote_balance_unavailable = False
        self._forced_reset_at: Optional[float] = None

        if self.config.state_path:
            self.config.state_path.parent.mkdir(parents=True, exist_ok=True)

    @property
    def api_key(self) -> str:
        return self.config.api_key

    def auth_headers(self) -> Dict[str, str]:
        if not self.config.api_key:
            return {}
        return {"Authorization": f"Bearer {self.config.api_key}"}

    def wait_and_reserve(
        self,
        label: str = "Pi-Agent call",
        cost: Optional[float] = None,
        *,
        kind: str = "chat",
        input_chars: int = 0,
    ) -> float:
        """Wait until pollen is available, then reserve predicted hourly budget."""
        if not self.config.enabled:
            return 0.0

        cost = self.forecast_cost(kind=kind, input_chars=input_chars, fallback_cost=cost)
        while True:
            wait_seconds, reason = self._seconds_until_available(cost)
            if wait_seconds <= 0:
                self._reserve_local(cost)
                print(
                    f"[Pollen] Reserved {cost:.4f} pollen for {label} "
                    f"(kind={kind}, input_chars={input_chars})."
                )
                return cost

            reset_at = time.strftime("%Y-%m-%d %H:%M:%S", time.localtime(time.time() + wait_seconds))
            print(
                f"[Pollen] Deferring {label}: {reason}. "
                f"Waiting {wait_seconds:.0f}s until reset around {reset_at}."
            )
            if not self.config.defer_when_low:
                return cost
            time.sleep(min(wait_seconds, max(1, self.config.max_sleep_seconds)))

    def forecast_cost(
        self,
        *,
        kind: str = "chat",
        input_chars: int = 0,
        fallback_cost: Optional[float] = None,
    ) -> float:
        """Predict pollen needed for a request from running averages."""
        if fallback_cost is not None:
            return max(0.0, float(fallback_cost))

        state = self._load_state()
        stats = state.get("forecasts", {}).get(kind, {})
        floor = self._floor_cost(kind)
        estimates = [floor]

        avg_cost = float(stats.get("avg_cost", 0.0) or 0.0)
        if avg_cost > 0:
            estimates.append(avg_cost)

        avg_cost_per_char = float(stats.get("avg_cost_per_char", 0.0) or 0.0)
        if input_chars > 0 and avg_cost_per_char > 0:
            estimates.append(avg_cost_per_char * input_chars)
        elif input_chars > 0:
            estimates.append(input_chars / self._chars_per_pollen(kind))

        max_cost = float(stats.get("max_cost", 0.0) or 0.0)
        if max_cost > 0:
            estimates.append(max_cost * 0.75)

        predicted = max(estimates) * max(1.0, self.config.forecast_safety_multiplier)
        return round(min(max(predicted, floor), self.config.hourly_allowance), 6)

    def record_observation(
        self,
        *,
        kind: str = "chat",
        input_chars: int = 0,
        predicted_cost: float = 0.0,
        actual_cost: Optional[float] = None,
        success: bool = True,
    ) -> None:
        """Accumulate running averages used by future pollen forecasts."""
        if not self.config.enabled:
            return

        observed = float(actual_cost) if actual_cost is not None else float(predicted_cost)
        if not success:
            observed = max(observed, predicted_cost * 1.5, self._floor_cost(kind) * 2)
        observed = max(0.0, min(observed, self.config.hourly_allowance))

        if actual_cost is not None and predicted_cost > 0:
            self._adjust_local_reservation(predicted=float(predicted_cost), actual=observed)

        state = self._load_state()
        forecasts = state.setdefault("forecasts", {})
        stats = forecasts.setdefault(kind, {})
        count = int(stats.get("count", 0))
        alpha = self.config.forecast_alpha if count else 1.0

        def ewma(old: float, new: float) -> float:
            return new if count == 0 else (alpha * new) + ((1.0 - alpha) * old)

        stats["count"] = count + 1
        stats["avg_cost"] = round(ewma(float(stats.get("avg_cost", 0.0) or 0.0), observed), 8)
        stats["max_cost"] = round(max(float(stats.get("max_cost", 0.0) or 0.0), observed), 8)
        stats["last_cost"] = round(observed, 8)
        stats["last_predicted_cost"] = round(float(predicted_cost), 8)
        stats["last_input_chars"] = int(input_chars)
        stats["updated_at"] = time.time()

        if input_chars > 0:
            cost_per_char = observed / input_chars
            stats["avg_input_chars"] = round(
                ewma(float(stats.get("avg_input_chars", 0.0) or 0.0), float(input_chars)),
                3,
            )
            stats["avg_cost_per_char"] = round(
                ewma(float(stats.get("avg_cost_per_char", 0.0) or 0.0), cost_per_char),
                12,
            )

        self._save_state(state)

    def record_response(
        self,
        response: httpx.Response,
        *,
        kind: str = "chat",
        input_chars: int = 0,
        predicted_cost: float = 0.0,
    ) -> None:
        """Record request cost from response metadata when available."""
        actual_cost = self._extract_cost_from_response(response)
        self.record_observation(
            kind=kind,
            input_chars=input_chars,
            predicted_cost=predicted_cost,
            actual_cost=actual_cost,
            success=response.status_code < 400,
        )

    def mark_depleted_from_response(self, response: httpx.Response) -> None:
        """Remember server-side depletion/rate-limit resets from a response."""
        if response.status_code not in (402, 429):
            return

        retry_after = response.headers.get("retry-after")
        if retry_after:
            try:
                self._forced_reset_at = time.time() + max(0.0, float(retry_after))
                return
            except ValueError:
                pass
        self._forced_reset_at = self._next_hour_reset(time.time())

    def _extract_cost_from_response(self, response: httpx.Response) -> Optional[float]:
        for header in (
            "x-pollen-cost",
            "x-pollinations-pollen-cost",
            "x-credit-cost",
            "x-credits-used",
        ):
            value = response.headers.get(header)
            if value:
                try:
                    return max(0.0, float(value))
                except ValueError:
                    pass
        return None

    def _seconds_until_available(self, cost: float) -> tuple[float, str]:
        now = time.time()
        if self._forced_reset_at and now < self._forced_reset_at:
            return self._forced_reset_at - now, "Pollinations reported depleted pollen/rate limit"

        self._roll_local_window(now)
        state = self._load_state()
        used = float(state.get("used", 0.0))
        local_remaining = max(0.0, self.config.hourly_allowance - used)
        if self.config.hourly_allowance > 0 and local_remaining + 1e-9 < cost:
            return self._next_hour_reset(now) - now, (
                f"local hourly pollen remaining {local_remaining:.3f} < needed {cost:.3f}"
            )

        remote_balance = self._get_remote_balance()
        required_balance = max(cost, self.config.min_balance)
        if remote_balance is not None and remote_balance + 1e-9 < required_balance:
            return self._next_hour_reset(now) - now, (
                f"remote pollen balance {remote_balance:.3f} < needed {required_balance:.3f}"
            )

        return 0.0, ""

    def _get_remote_balance(self) -> Optional[float]:
        if self._remote_balance_unavailable or not self.config.api_key:
            return None

        now = time.time()
        if self._balance_cache and now - self._balance_cache_at < self.config.balance_cache_seconds:
            return self._balance_cache.get("balance")

        client = self.client or httpx.Client(timeout=httpx.Timeout(10.0))
        try:
            response = client.get(
                f"{self.config.base_url}/account/balance",
                headers=self.auth_headers(),
                timeout=10.0,
            )
            if response.status_code in (401, 403, 404):
                self._remote_balance_unavailable = True
                print(
                    "[Pollen] Account balance endpoint unavailable for this key; "
                    "using local hourly pollen tracking."
                )
                return None
            if response.status_code == 402:
                self.mark_depleted_from_response(response)
                return 0.0
            response.raise_for_status()
            data = response.json()
            balance = float(data.get("balance"))
            self._balance_cache = {"balance": balance}
            self._balance_cache_at = now
            return balance
        except Exception as exc:
            self._remote_balance_unavailable = True
            print(f"[Pollen] Could not read remote balance ({type(exc).__name__}); using local tracking.")
            return None

    def _reserve_local(self, cost: float) -> None:
        self._roll_local_window(time.time())
        state = self._load_state()
        state["used"] = round(float(state.get("used", 0.0)) + cost, 6)
        state["updated_at"] = time.time()
        self._save_state(state)

    def _adjust_local_reservation(self, *, predicted: float, actual: float) -> None:
        self._roll_local_window(time.time())
        state = self._load_state()
        used = float(state.get("used", 0.0))
        state["used"] = round(max(0.0, min(self.config.hourly_allowance, used - predicted + actual)), 6)
        state["updated_at"] = time.time()
        self._save_state(state)

    def _floor_cost(self, kind: str) -> float:
        if kind in {"pi_execution", "pi-coding-agent"}:
            return self.config.estimated_pollen_per_pi_execution
        return self.config.estimated_pollen_per_call

    def _chars_per_pollen(self, kind: str) -> float:
        if kind in {"pi_execution", "pi-coding-agent"}:
            return max(1.0, self.config.pi_execution_input_chars_per_pollen)
        return max(1.0, self.config.chat_input_chars_per_pollen)

    def _roll_local_window(self, now: float) -> None:
        state = self._load_state()
        current_window = self._hour_window_start(now)
        if int(state.get("window_start", 0)) != current_window:
            self._save_state({
                "window_start": current_window,
                "used": 0.0,
                "updated_at": now,
                "forecasts": state.get("forecasts", {}),
            })
            self._forced_reset_at = None

    def _load_state(self) -> Dict[str, Any]:
        if not self.config.state_path or not self.config.state_path.exists():
            return {"window_start": self._hour_window_start(time.time()), "used": 0.0, "forecasts": {}}
        try:
            state = json.loads(self.config.state_path.read_text(encoding="utf-8"))
            state.setdefault("forecasts", {})
            return state
        except Exception:
            return {"window_start": self._hour_window_start(time.time()), "used": 0.0, "forecasts": {}}

    def _save_state(self, state: Dict[str, Any]) -> None:
        if not self.config.state_path:
            return
        tmp = self.config.state_path.with_suffix(self.config.state_path.suffix + ".tmp")
        tmp.write_text(json.dumps(state, indent=2, sort_keys=True), encoding="utf-8")
        tmp.replace(self.config.state_path)

    def _next_hour_reset(self, now: float) -> float:
        return ((int(now) // 3600) + 1) * 3600 + self.config.reset_buffer_seconds

    @staticmethod
    def _hour_window_start(now: float) -> int:
        return (int(now) // 3600) * 3600
