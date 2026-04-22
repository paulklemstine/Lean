"""Telemetry logging with JSON persistence."""

import json
import os
from dataclasses import dataclass, asdict
from datetime import datetime
from typing import List, Optional


@dataclass
class TelemetryEntry:
    """A single telemetry record."""

    timestamp: str
    stage: str
    model_name: str
    quantization: str
    vram_mb: float
    tokens_per_sec_prefill: float
    tokens_per_sec_decode: float
    perplexity: Optional[float]
    latency_ttft_ms: float
    latency_tpot_ms: float
    notes: str = ""


class TelemetryLogger:
    """Accumulates benchmark results and persists them to a JSON file.

    On Colab, point ``log_file`` to a Google Drive path for persistence.
    """

    def __init__(self, log_file: str):
        self.log_file = log_file
        self.entries: List[TelemetryEntry] = []
        self._load_existing()

    def _load_existing(self):
        if os.path.exists(self.log_file):
            with open(self.log_file, "r", encoding="utf-8") as f:
                data = json.load(f)
                self.entries = [TelemetryEntry(**e) for e in data]

    def _save(self):
        os.makedirs(os.path.dirname(self.log_file) or ".", exist_ok=True)
        with open(self.log_file, "w", encoding="utf-8") as f:
            json.dump([asdict(e) for e in self.entries], f, indent=2)

    def log(self, entry: TelemetryEntry):
        self.entries.append(entry)
        self._save()

    def summary(self):
        print("\n" + "=" * 80)
        print(f"Telemetry Summary ({len(self.entries)} entries)")
        print("=" * 80)
        for e in self.entries:
            ppl = f"PPL={e.perplexity:.2f}" if e.perplexity else "PPL=N/A"
            print(
                f"{e.timestamp[:19]} | {e.stage:22s} | "
                f"VRAM={e.vram_mb:8.1f}MB | Tok/s={e.tokens_per_sec_decode:7.2f} | {ppl}"
            )
