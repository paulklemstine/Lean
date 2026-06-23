#!/usr/bin/env python3
"""Shadow-mode watch for the LLM-reduction levers.

The static_gate and critic_gate levers ship in `shadow` mode: they compute the
gate decision, still call the LLM, and log whether the gate agreed with the LLM
(`[Gate] shadow: ... agree=True/False`). Once a lever's agreement is reliably
high AND quality has not drifted, it is safe to flip it to `enabled` (skip the
LLM when the gate is decisive) — that is the whole point of shadow validation.

This script is deterministic and standalone. It:
  1. Parses `.aether_workspace/aether_daemon.log` for shadow agreement samples
     and the latest `[Quality]` rolling-metrics block.
  2. For each lever still in `shadow` mode in config.yaml, checks readiness:
       - >= MIN_SAMPLES shadow samples in the rolling window, AND
       - agreement ratio >= AGREE_THRESHOLD, AND
       - overall weighted avg_Q within QUALITY_TOL of the recorded baseline.
  3. When ready, flips that lever `shadow` -> `enabled` in config.yaml and
     prints a `FLIPPED:` line. Otherwise prints a per-lever `STATUS:` line.

The session cron that invokes this script reads the output and sends a
PushNotification only when a `FLIPPED:` line appears.

Readiness is deliberately conservative: a lever with no baseline yet records one
and waits a round before flipping (so "quality hasn't shifted" is testable), and
critic_gate agreement (a string vocabulary, currently zero samples) only counts
an exact `agree` token as agreement.
"""
from __future__ import annotations

import json
import re
import sys
from datetime import datetime
from pathlib import Path

HERE = Path(__file__).resolve().parent
WORKSPACE = HERE / ".aether_workspace"
LOG = WORKSPACE / "aether_daemon.log"
CONFIG = HERE / "config.yaml"
STATE = WORKSPACE / "shadow_watch_state.json"

# Readiness bar — per CLAUDE.md: ">95% agreement" + "[Quality] avg_Q hasn't shifted".
MIN_SAMPLES = 50          # need this many shadow samples before considering a flip
AGREE_THRESHOLD = 0.95    # >= this fraction of agree=True in the rolling window
QUALITY_TOL = 0.10        # |current avg_Q - baseline avg_Q| must be <= this
WINDOW = 50               # rolling window size (most recent samples)

# Levers that can meaningfully live in shadow mode. lint_gate is already enabled.
LEVERS = ("static_gate", "critic_gate")

STATIC_RE = re.compile(r"\[Gate\] shadow: gate=\S+ llm=\S+ agree=(True|False)")
CRITIC_RE = re.compile(r"\[Gate\] critic shadow: composite=\S+ agreement=(\S+)")
QUALITY_HDR = "[Quality] Rolling metrics"
VERSION_RE = re.compile(r"^\s+\S+:\s+n=(\d+)\s+avg_Q=([0-9.]+)")


def parse_agreement(log_path: Path, lever: str) -> tuple[int, int]:
    """Return (agree_count, total) over the last WINDOW shadow samples for lever."""
    if not log_path.exists():
        return (0, 0)
    regex = STATIC_RE if lever == "static_gate" else CRITIC_RE
    samples: list[bool] = []
    with log_path.open("r", errors="replace") as fh:
        for line in fh:
            m = regex.search(line)
            if not m:
                continue
            tok = m.group(1)
            if lever == "static_gate":
                agree = tok == "True"
            else:
                # critic agreement is a string vocabulary; only an exact
                # "agree" token counts (conservative — never over-counts).
                agree = tok.strip().lower() == "agree"
            samples.append(agree)
    samples = samples[-WINDOW:]
    return (sum(1 for a in samples if a), len(samples))


def _strip_ts(line: str) -> str:
    """Strip a leading `[YYYY-MM-DD HH:MM:SS] ` timestamp prefix if present."""
    if line.startswith("[") and "] " in line:
        return line.split("] ", 1)[1]
    return line


def latest_avg_q(log_path: Path) -> float | None:
    """Weighted overall avg_Q from the most recent [Quality] rolling block."""
    if not log_path.exists():
        return None
    lines = log_path.read_text(errors="replace").splitlines()
    # find last header index (lines may carry a `[timestamp] ` prefix)
    hdr_idx = max((i for i, ln in enumerate(lines) if QUALITY_HDR in _strip_ts(ln)),
                  default=-1)
    if hdr_idx < 0:
        return None
    num_sum = 0.0
    q_sum = 0.0
    for ln in lines[hdr_idx + 1:]:
        body = _strip_ts(ln)
        m = VERSION_RE.match(body)
        if not m:
            # block ends at the first non-version, non-blank, non-comment line
            if body.strip() and not body.lstrip().startswith("#"):
                break
            continue
        n = int(m.group(1))
        q = float(m.group(2))
        num_sum += n * q
        q_sum += n
    if q_sum <= 0:
        return None
    return num_sum / q_sum


def current_modes(config_path: Path) -> dict[str, str]:
    """Read the llm_reduction block and return {lever: mode} for tracked levers."""
    modes: dict[str, str] = {}
    if not config_path.exists():
        return modes
    in_block = False
    block_indent = None
    for raw in config_path.read_text().splitlines():
        if raw.rstrip().startswith("llm_reduction:"):
            in_block = True
            block_indent = len(raw) - len(raw.lstrip())
            continue
        if in_block:
            if not raw.strip() or raw.lstrip().startswith("#"):
                continue
            indent = len(raw) - len(raw.lstrip())
            # block ends at a line indented <= the header (a new top-level key)
            if indent <= block_indent:
                break
            for lever in LEVERS:
                m = re.match(rf"\s*{lever}:\s*(\S+)", raw)
                if m:
                    modes[lever] = m.group(1).split("#", 1)[0].strip()
    return modes


def flip_to_enabled(config_path: Path, lever: str) -> bool:
    """Rewrite `  <lever>: shadow` -> `  <lever>: enabled` in the llm_reduction block."""
    if not config_path.exists():
        return False
    text = config_path.read_text()
    lines = text.splitlines(keepends=True)
    in_block = False
    block_indent = None
    changed = False
    for i, raw in enumerate(lines):
        if raw.rstrip().startswith("llm_reduction:"):
            in_block = True
            block_indent = len(raw) - len(raw.lstrip())
            continue
        if in_block:
            indent = len(raw) - len(raw.lstrip())
            if raw.strip() and not raw.lstrip().startswith("#") and indent <= block_indent:
                in_block = False
                continue
            m = re.match(rf"(\s*){lever}:\s*shadow(\s.*)?$", raw)
            if m:
                rest = m.group(2) or ""
                lines[i] = f"{m.group(1)}{lever}: enabled{rest}"
                if not lines[i].endswith("\n"):
                    lines[i] += "\n"
                changed = True
                break
    if changed:
        config_path.write_text("".join(lines))
    return changed


def load_state() -> dict:
    if STATE.exists():
        try:
            return json.loads(STATE.read_text())
        except Exception:
            pass
    return {"baselines": {}, "flipped": {}}


def save_state(st: dict) -> None:
    STATE.parent.mkdir(parents=True, exist_ok=True)
    STATE.write_text(json.dumps(st, indent=2, sort_keys=True))


def main() -> int:
    modes = current_modes(CONFIG)
    if not modes:
        print("NOOP: could not read llm_reduction modes from config.yaml")
        return 0

    state = load_state()
    avg_q = latest_avg_q(LOG)
    now = datetime.now().isoformat(timespec="seconds")
    flipped_any = False

    for lever in LEVERS:
        mode = modes.get(lever, "off")
        if mode != "shadow":
            print(f"STATUS: {lever} mode={mode} — not in shadow, skipping")
            continue

        agree, n = parse_agreement(LOG, lever)
        ratio = (agree / n) if n else 0.0
        ready = False
        reason = ""

        if n < MIN_SAMPLES:
            reason = f"only {n}/{MIN_SAMPLES} samples"
        elif ratio < AGREE_THRESHOLD:
            reason = f"agreement {ratio*100:.0f}% < {AGREE_THRESHOLD*100:.0f}%"
        elif avg_q is None:
            reason = "no [Quality] avg_Q available"
        else:
            base = state["baselines"].get(lever)
            if base is None:
                # Record a baseline this round; wait for the next to confirm
                # quality has not shifted before flipping.
                state["baselines"][lever] = {"avg_q": avg_q, "set_at": now}
                reason = f"baseline recorded avg_Q={avg_q:.3f}; waiting one round"
            else:
                drift = abs(avg_q - base["avg_q"])
                if drift > QUALITY_TOL:
                    reason = f"avg_Q drifted {base['avg_q']:.3f}->{avg_q:.3f} (>{QUALITY_TOL})"
                    # reset baseline so a new stable window can re-qualify
                    state["baselines"][lever] = {"avg_q": avg_q, "set_at": now}
                else:
                    ready = True
                    reason = f"agree={ratio*100:.0f}% n={n} avg_Q stable ({base['avg_q']:.3f}->{avg_q:.3f})"

        if ready:
            ok = flip_to_enabled(CONFIG, lever)
            if ok:
                state["flipped"][lever] = now
                flipped_any = True
                print(f"FLIPPED: {lever} shadow->enabled ({reason})")
            else:
                reason = "config edit failed"
                print(f"STATUS: {lever} mode=shadow agree={ratio*100:.0f}% n={n} ready=False reason={reason}")
        else:
            print(f"STATUS: {lever} mode=shadow agree={ratio*100:.0f}% n={n} ready=False reason={reason}")

    save_state(state)
    if not flipped_any:
        qstr = f" avg_Q={avg_q:.3f}" if avg_q is not None else ""
        print(f"NOOP: nothing ready{qstr}")
    return 0


if __name__ == "__main__":
    sys.exit(main())