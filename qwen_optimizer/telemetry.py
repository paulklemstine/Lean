"""Telemetry logging with JSON persistence."""

import csv
import json
import os
from dataclasses import dataclass, asdict
from datetime import datetime
from typing import List, Optional

import matplotlib.pyplot as plt
import pandas as pd


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


@dataclass
class TelemetryComparison:
    """Summary statistics comparing stages."""

    baseline_vram_mb: float
    optimized_vram_mb: float
    vram_reduction_pct: float
    speedup_decode: float
    best_stage: str


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

    def export_csv(self, csv_path: str):
        """Export telemetry entries to a CSV file."""
        if not self.entries:
            return
        keys = asdict(self.entries[0]).keys()
        with open(csv_path, "w", newline="", encoding="utf-8") as f:
            writer = csv.DictWriter(f, fieldnames=keys)
            writer.writeheader()
            for e in self.entries:
                writer.writerow(asdict(e))
        print(f"Telemetry exported to {csv_path}")

    def plot_comparison(self, save_path: Optional[str] = None):
        """Generate comparison charts for VRAM, throughput, and latency."""
        if not self.entries:
            print("No entries to plot.")
            return

        df = pd.DataFrame([asdict(e) for e in self.entries])

        fig, axes = plt.subplots(1, 3, figsize=(15, 4))

        axes[0].bar(df["stage"], df["vram_mb"], color="steelblue")
        axes[0].set_ylabel("VRAM (MB)")
        axes[0].set_title("VRAM Usage by Stage")
        axes[0].tick_params(axis="x", rotation=45)

        axes[1].bar(df["stage"], df["tokens_per_sec_decode"], color="forestgreen")
        axes[1].set_ylabel("Tokens/sec")
        axes[1].set_title("Decode Throughput")
        axes[1].tick_params(axis="x", rotation=45)

        axes[2].bar(df["stage"], df["latency_tpot_ms"], color="coral")
        axes[2].set_ylabel("ms/token")
        axes[2].set_title("Time Per Output Token")
        axes[2].tick_params(axis="x", rotation=45)

        plt.tight_layout()
        if save_path:
            plt.savefig(save_path, dpi=150)
            print(f"Chart saved to {save_path}")
        else:
            plt.show()

    def compare_stages(self, baseline_stage: str, optimized_stage: str) -> Optional[TelemetryComparison]:
        """Compare two stages and return summary statistics."""
        baseline = next((e for e in self.entries if e.stage == baseline_stage), None)
        optimized = next((e for e in self.entries if e.stage == optimized_stage), None)
        if not baseline or not optimized:
            return None

        vram_reduction = 1.0 - optimized.vram_mb / baseline.vram_mb
        speedup = optimized.tokens_per_sec_decode / baseline.tokens_per_sec_decode if baseline.tokens_per_sec_decode > 0 else 0.0

        return TelemetryComparison(
            baseline_vram_mb=baseline.vram_mb,
            optimized_vram_mb=optimized.vram_mb,
            vram_reduction_pct=vram_reduction * 100,
            speedup_decode=speedup,
            best_stage=optimized_stage if vram_reduction > 0 else baseline_stage,
        )
