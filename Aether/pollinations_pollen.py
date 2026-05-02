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
    min_balance: float = 0.4
    estimated_pollen_per_call: float = 0.4
    balance_cache_seconds: int = 60
    reset_buffer_seconds: int = 10
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
            min_balance=float(raw.get("min_balance", raw.get("estimated_pollen_per_call", 0.4))),
            estimated_pollen_per_call=float(raw.get("estimated_pollen_per_call", 0.4)),
            balance_cache_seconds=int(raw.get("balance_cache_seconds", 60)),
            reset_buffer_seconds=int(raw.get("reset_buffer_seconds", 10)),
            base_url=raw.get("base_url", "https://gen.pollinations.ai").rstrip("/"),
            api_key=api_key,
            state_path=Path(state_path).expanduser() if state_path else default_state_path,
        )


class PollinationsPollenGate:
    """Blocks Pollinations LLM calls until enough hourly pollen is available.

    Pollinations exposes account balance endpoints for keys with account
    permissions. Publishable keys may not have those permissions, so this also
    keeps a local non-rollover hourly budget. The local budget is intentionally
    conservative: by default one Pi-Agent LLM call consumes the full 0.4 pollen
    available in the current hour.
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

    def wait_and_reserve(self, label: str = "Pi-Agent call", cost: Optional[float] = None) -> None:
        """Wait until pollen is available, then reserve local hourly budget."""
        if not self.config.enabled:
            return

        cost = float(cost if cost is not None else self.config.estimated_pollen_per_call)
        while True:
            wait_seconds, reason = self._seconds_until_available(cost)
            if wait_seconds <= 0:
                self._reserve_local(cost)
                return

            reset_at = time.strftime("%Y-%m-%d %H:%M:%S", time.localtime(time.time() + wait_seconds))
            print(
                f"[Pollen] Deferring {label}: {reason}. "
                f"Waiting {wait_seconds:.0f}s until reset around {reset_at}."
            )
            if not self.config.defer_when_low:
                return
            time.sleep(wait_seconds)

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
        if remote_balance is not None and remote_balance + 1e-9 < max(cost, self.config.min_balance):
            return self._next_hour_reset(now) - now, (
                f"remote pollen balance {remote_balance:.3f} < needed {max(cost, self.config.min_balance):.3f}"
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

    def _roll_local_window(self, now: float) -> None:
        state = self._load_state()
        current_window = self._hour_window_start(now)
        if int(state.get("window_start", 0)) != current_window:
            self._save_state({"window_start": current_window, "used": 0.0, "updated_at": now})
            self._forced_reset_at = None

    def _load_state(self) -> Dict[str, Any]:
        if not self.config.state_path or not self.config.state_path.exists():
            return {"window_start": self._hour_window_start(time.time()), "used": 0.0}
        try:
            return json.loads(self.config.state_path.read_text(encoding="utf-8"))
        except Exception:
            return {"window_start": self._hour_window_start(time.time()), "used": 0.0}

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
