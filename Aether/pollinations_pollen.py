#!/usr/bin/env python3
"""Pollen budget gate for Pollinations-backed Pi-Agent calls."""

from __future__ import annotations

import json
import os
import time
import uuid
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
    output_chars_per_pollen: float = 125000.0
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
        api_key_file = raw.get("api_key_file")
        api_key_from_file = ""
        if api_key_file:
            try:
                api_key_from_file = Path(api_key_file).expanduser().read_text(encoding="utf-8").strip()
            except Exception:
                api_key_from_file = ""
        api_key = (
            raw.get("api_key")
            or api_key_from_file
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
            output_chars_per_pollen=float(raw.get("output_chars_per_pollen", 125000.0)),
            base_url=raw.get("base_url", "https://gen.pollinations.ai").rstrip("/"),
            api_key=api_key,
            state_path=Path(state_path).expanduser() if state_path else default_state_path,
        )


@dataclass
class PollenReservation:
    """A predicted pollen hold for one outbound Pollinations request."""

    reservation_id: str
    kind: str
    input_chars: int
    predicted_cost: float
    balance_before: Optional[float] = None


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
        self._account_balance_unavailable = False
        self._key_balance_unavailable = False
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
    ) -> PollenReservation:
        """Reserve pollen for a call. Forecasting/deferral removed — always proceeds."""
        if not self.config.enabled:
            return PollenReservation("", kind, input_chars, 0.0)

        cost = self.forecast_cost(kind=kind, input_chars=input_chars, fallback_cost=cost)
        reservation = self._reserve_local(
            cost,
            kind=kind,
            input_chars=input_chars,
            balance_before=None,
        )
        return reservation

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
        reservation: Optional[PollenReservation] = None,
        predicted_cost: float = 0.0,
        actual_cost: Optional[float] = None,
        success: bool = True,
        output_chars: int = 0,
    ) -> None:
        """Accumulate running averages used by future pollen forecasts."""
        if not self.config.enabled:
            return

        if reservation is not None:
            kind = reservation.kind
            input_chars = reservation.input_chars
            predicted_cost = reservation.predicted_cost

        observed = float(actual_cost) if actual_cost is not None else float(predicted_cost)
        if not success:
            observed = max(observed, predicted_cost * 1.25, self._floor_cost(kind) * 2)
        observed = max(0.0, min(observed, self.config.hourly_allowance))

        if reservation is not None:
            self._settle_local_reservation(reservation, actual=observed if success else 0.0)

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
        stats["last_output_chars"] = int(output_chars)
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
        if output_chars > 0:
            output_cost_per_char = observed / output_chars
            stats["avg_output_chars"] = round(
                ewma(float(stats.get("avg_output_chars", 0.0) or 0.0), float(output_chars)),
                3,
            )
            stats["avg_cost_per_output_char"] = round(
                ewma(float(stats.get("avg_cost_per_output_char", 0.0) or 0.0), output_cost_per_char),
                12,
            )

        self._save_state(state)

    def record_response(
        self,
        response: httpx.Response,
        *,
        kind: str = "chat",
        input_chars: int = 0,
        reservation: Optional[PollenReservation] = None,
        predicted_cost: float = 0.0,
        response_json: Optional[Dict[str, Any]] = None,
    ) -> None:
        """Record request cost from response metadata when available."""
        actual_cost = self._extract_cost_from_response(response)
        if actual_cost is None and reservation and reservation.balance_before is not None:
            balance_after = self._get_remote_balance(force=True)
            if balance_after is not None and reservation.balance_before >= balance_after:
                actual_cost = reservation.balance_before - balance_after
        if response_json is None:
            try:
                response_json = response.json()
            except Exception:
                response_json = None
        if actual_cost is None:
            actual_cost = self._estimate_cost_from_usage(response_json)
        output_chars = self._extract_output_chars(response_json)
        self.record_observation(
            kind=kind,
            input_chars=input_chars,
            reservation=reservation,
            predicted_cost=predicted_cost,
            actual_cost=actual_cost,
            success=response.status_code < 400,
            output_chars=output_chars,
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

    def _estimate_cost_from_usage(self, data: Optional[Dict[str, Any]]) -> Optional[float]:
        if not data:
            return None
        usage = data.get("usage") or {}
        prompt_tokens = self._usage_number(usage, "prompt_tokens", "input_tokens", "input_text_tokens")
        completion_tokens = self._usage_number(usage, "completion_tokens", "output_tokens", "output_text_tokens")
        total_tokens = self._usage_number(usage, "total_tokens")
        if total_tokens <= 0:
            total_tokens = prompt_tokens + completion_tokens
        if total_tokens <= 0:
            return None

        input_cost = (prompt_tokens * 4) / self.config.chat_input_chars_per_pollen
        output_cost = (completion_tokens * 4) / self.config.output_chars_per_pollen
        if input_cost + output_cost <= 0:
            input_cost = (total_tokens * 4) / self.config.chat_input_chars_per_pollen
        return min(self.config.hourly_allowance, max(self._floor_cost("chat"), input_cost + output_cost))

    def _extract_output_chars(self, data: Optional[Dict[str, Any]]) -> int:
        if not data:
            return 0
        total = 0
        for choice in data.get("choices", []) or []:
            message = choice.get("message") or {}
            content = message.get("content") or ""
            if isinstance(content, str):
                total += len(content)
        return total

    @staticmethod
    def _usage_number(usage: Dict[str, Any], *keys: str) -> float:
        for key in keys:
            value = usage.get(key)
            if isinstance(value, (int, float)):
                return float(value)
        return 0.0

    def _seconds_until_available(self, cost: float) -> tuple[float, str, Optional[float]]:
        now = time.time()
        if self._forced_reset_at and now < self._forced_reset_at:
            return self._forced_reset_at - now, "Pollinations reported depleted pollen/rate limit", None

        self._roll_local_window(now)
        remote_balance = self._get_remote_balance(force=True)
        available = self._available_pollen(remote_balance)

        if available + 1e-9 < cost:
            return self._next_hour_reset(now) - now, f"available pollen {available:.3f} < forecast {cost:.3f}", remote_balance
        return 0.0, "", remote_balance

    def _get_remote_balance(self, *, force: bool = False) -> Optional[float]:
        if self._remote_balance_unavailable or not self.config.api_key:
            return None

        now = time.time()
        if not force and self._balance_cache and now - self._balance_cache_at < self.config.balance_cache_seconds:
            return self._balance_cache.get("balance")

        client = self.client or httpx.Client(timeout=httpx.Timeout(10.0))
        balance = self._get_account_balance(client)
        if balance is None:
            balance = self._get_key_budget(client)
        if balance is not None:
            self._balance_cache = {"balance": balance}
            self._balance_cache_at = now
            return balance

        self._remote_balance_unavailable = self._account_balance_unavailable and self._key_balance_unavailable
        return None

    def _get_account_balance(self, client: httpx.Client) -> Optional[float]:
        if self._account_balance_unavailable:
            return None
        try:
            response = client.get(
                f"{self.config.base_url}/account/balance",
                headers=self.auth_headers(),
                timeout=10.0,
            )
            if response.status_code in (401, 403, 404):
                self._account_balance_unavailable = True
                print(
                    "[Pollen] Account balance endpoint unavailable for this key; "
                    "trying API key budget metadata."
                )
                return None
            if response.status_code == 402:
                self.mark_depleted_from_response(response)
                return 0.0
            response.raise_for_status()
            data = response.json()
            return float(data.get("balance"))
        except Exception as exc:
            self._account_balance_unavailable = True
            print(f"[Pollen] Could not read account balance ({type(exc).__name__}); trying key metadata.")
            return None

    def _get_key_budget(self, client: httpx.Client) -> Optional[float]:
        if self._key_balance_unavailable:
            return None
        try:
            response = client.get(
                f"{self.config.base_url}/account/key",
                headers=self.auth_headers(),
                timeout=10.0,
            )
            if response.status_code in (401, 403, 404):
                self._key_balance_unavailable = True
                print("[Pollen] API key budget metadata unavailable; using local hourly pollen tracking.")
                return None
            if response.status_code == 402:
                self.mark_depleted_from_response(response)
                return 0.0
            response.raise_for_status()
            data = response.json()
            budget = data.get("pollenBudget")
            if isinstance(budget, (int, float)):
                return float(budget)
            return None
        except Exception as exc:
            self._key_balance_unavailable = True
            print(f"[Pollen] Could not read API key budget ({type(exc).__name__}); using local tracking.")
            return None

    def _available_pollen(self, remote_balance: Optional[float] = None) -> float:
        state = self._load_state()
        reserved = sum(float(item.get("cost", 0.0)) for item in state.get("reserved", {}).values())
        if remote_balance is not None:
            return max(0.0, min(self.config.hourly_allowance, remote_balance) - reserved)

        spent = float(state.get("spent", state.get("used", 0.0)) or 0.0)
        return max(0.0, self.config.hourly_allowance - spent - reserved)

    def _available_label(self, remote_balance: Optional[float] = None) -> str:
        return f"{self._available_pollen(remote_balance):.4f}"

    def _reserve_local(
        self,
        cost: float,
        *,
        kind: str,
        input_chars: int,
        balance_before: Optional[float],
    ) -> PollenReservation:
        self._roll_local_window(time.time())
        state = self._load_state()
        reservation_id = uuid.uuid4().hex[:12]
        state.setdefault("reserved", {})[reservation_id] = {
            "cost": round(cost, 6),
            "kind": kind,
            "input_chars": int(input_chars),
            "created_at": time.time(),
            "balance_before": balance_before,
        }
        state["updated_at"] = time.time()
        self._save_state(state)
        return PollenReservation(reservation_id, kind, input_chars, cost, balance_before)

    def _settle_local_reservation(self, reservation: PollenReservation, *, actual: float) -> None:
        if not reservation.reservation_id:
            return
        self._roll_local_window(time.time())
        state = self._load_state()
        state.setdefault("reserved", {}).pop(reservation.reservation_id, None)
        state["spent"] = round(float(state.get("spent", state.get("used", 0.0)) or 0.0) + actual, 6)
        state["used"] = state["spent"]
        state["updated_at"] = time.time()
        self._save_state(state)

    def _adjust_local_reservation(self, *, predicted: float, actual: float) -> None:
        self._roll_local_window(time.time())
        state = self._load_state()
        spent = float(state.get("spent", state.get("used", 0.0)) or 0.0)
        state["spent"] = round(max(0.0, min(self.config.hourly_allowance, spent - predicted + actual)), 6)
        state["used"] = state["spent"]
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
                "spent": 0.0,
                "used": 0.0,
                "reserved": {},
                "updated_at": now,
                "forecasts": state.get("forecasts", {}),
            })
            self._forced_reset_at = None

    def _load_state(self) -> Dict[str, Any]:
        if not self.config.state_path or not self.config.state_path.exists():
            return {
                "window_start": self._hour_window_start(time.time()),
                "spent": 0.0,
                "used": 0.0,
                "reserved": {},
                "forecasts": {},
            }
        try:
            state = json.loads(self.config.state_path.read_text(encoding="utf-8"))
            if "spent" not in state:
                state["spent"] = float(state.get("used", 0.0) or 0.0)
            state.setdefault("used", state.get("spent", 0.0))
            state.setdefault("reserved", {})
            state.setdefault("forecasts", {})
            return state
        except Exception:
            return {
                "window_start": self._hour_window_start(time.time()),
                "spent": 0.0,
                "used": 0.0,
                "reserved": {},
                "forecasts": {},
            }

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
