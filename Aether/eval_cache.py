"""Phase 3 (Lever B): content-hash eval cache.

Caches the fully-evaluated result for a (result_lean + concept + prompt_version)
triple so retries, re-dispatches, and duplicate-theorem cycles with identical
content skip the LLM eval + adversarial critic entirely.

Storage: .aether_workspace/eval_cache.json — a dict keyed by sha256 hex digest.
Each entry: {"ts": float, "value": {quality_score, quality_assessment,
adversarial_result, quality_detail}}. TTL-bounded (default 7 days) and size-
capped (default 5000 entries, evict oldest).
"""
import hashlib
import json
import time
from pathlib import Path
from typing import Any, Optional


class EvalCache:
    def __init__(self, workspace: Path, ttl_seconds: int = 7 * 86400,
                 max_entries: int = 5000):
        self.path = Path(workspace) / "eval_cache.json"
        self.ttl = ttl_seconds
        self.max = max_entries
        self._data: dict = self._load()

    def _load(self) -> dict:
        if not self.path.exists():
            return {}
        try:
            d = json.loads(self.path.read_text(encoding="utf-8"))
            return d if isinstance(d, dict) else {}
        except Exception:
            return {}

    def _save(self) -> None:
        try:
            self.path.parent.mkdir(parents=True, exist_ok=True)
            self.path.write_text(json.dumps(self._data), encoding="utf-8")
        except Exception:
            pass

    @staticmethod
    def key_for(result_lean: str, concept: Any, prompt_version: Optional[str]) -> str:
        """Stable hash of the eval inputs: Lean content + concept identity +
        prompt version. Two cycles with identical (content, concept, prompt)
        produce the same key."""
        h = hashlib.sha256()
        h.update((result_lean or "").encode("utf-8", "ignore"))
        h.update(b"\x1f")
        h.update((getattr(concept, "title", "") or "").encode("utf-8", "ignore"))
        h.update(b"\x1f")
        h.update((getattr(concept, "domain", "") or "").encode("utf-8", "ignore"))
        h.update(b"\x1f")
        h.update((getattr(concept, "research_mode", "") or "").encode("utf-8", "ignore"))
        h.update(b"\x1f")
        h.update((prompt_version or "").encode("utf-8", "ignore"))
        return h.hexdigest()

    def get(self, key: str, now: Optional[float] = None) -> Optional[dict]:
        now = now if now is not None else time.time()
        entry = self._data.get(key)
        if not entry:
            return None
        try:
            if now - float(entry.get("ts", 0)) > self.ttl:
                self._data.pop(key, None)
                return None
            return entry.get("value")
        except Exception:
            return None

    def put(self, key: str, value: dict, now: Optional[float] = None) -> None:
        now = now if now is not None else time.time()
        self._data[key] = {"ts": now, "value": value}
        if len(self._data) > self.max:
            overflow = len(self._data) - self.max
            for k in sorted(self._data, key=lambda kk: self._data[kk].get("ts", 0))[:overflow]:
                self._data.pop(k, None)
        self._save()

    def __len__(self) -> int:
        return len(self._data)