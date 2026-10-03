"""
r48 / AXIS-B : "COST TO REACH p" -- the KILLER requirement, MEASURED.

Each measurement runs in a SUBPROCESS with a hard wall-clock cap: a PARI
stack overflow aborts the interpreter and takes the whole run with it
(observed repeatedly in this project), so in-process timing is not safe.

Probes live in _probe_ec.py and _probe_cnb.py (separate files, because
nested f-string escaping generated syntactically invalid code twice).
"""
from __future__ import annotations

import json
import math
import subprocess
import sys

HERE = "/home/raver1975/lean/factor-scratch/r48/exp"


def run_probe(script, args, cap):
    try:
        r = subprocess.run([sys.executable, "-u", f"{HERE}/{script}"] +
                           [str(a) for a in args],
                           capture_output=True, text=True, timeout=cap)
    except subprocess.TimeoutExpired:
        return cap + 1.0, None, f">= {cap}s (killed)"
    for line in r.stdout.splitlines():
        if line.startswith("RESULT"):
            _, dt, v = line.split()
            return float(dt), int(v), "ok"
    err = (r.stderr.strip().splitlines() or ["?"])[-1][:60]
    return float("nan"), None, "CRASH: " + err


if __name__ == "__main__":
    out = {}
    print("=" * 80)
    print("COST TO BUILD |G|  (measured on this host, subprocess-capped)")
    print("=" * 80)

    print("\nEC baseline: #E(F_p) for a random curve over a random p-bit prime")
    print(f"{'p bits':>8} {'sec / order':>13} {'|G| bits':>9}   status")
    ec = {}
    for db in (64, 96, 128, 160):
        dt, m, st = run_probe("_probe_ec.py", (db, 3), 60)
        ec[db] = dt
        print(f"{db:8d} {dt:13.4f} {m.bit_length() if m else -1:9d}   {st}")
        sys.stdout.flush()
    out["ec_seconds_per_order"] = ec

    print("\nClass group: qfbclassno(D) ANALYTIC class number formula")
    print(f"{'D bits':>8} {'sec / h':>13} {'h bits':>8}   status")
    an = {}
    for db in (32, 40, 48, 54, 58, 60, 62, 64, 68, 72):
        dt, h, st = run_probe("_probe_cnb.py", (db, 0), 20)
        an[db] = dt
        print(f"{db:8d} {dt:13.4f} {h.bit_length() if h else -1:8d}   {st}")
        sys.stdout.flush()
    out["classno_analytic_seconds"] = an

    print("\nClass group: qfbclassno(D,1) BUCHMANN-McCURLEY")
    print(f"{'D bits':>8} {'sec / h':>13} {'h bits':>8}   status")
    bm = {}
    for db in (32, 40, 48, 54, 58, 60, 64):
        dt, h, st = run_probe("_probe_cnb.py", (db, 1), 20)
        bm[db] = dt
        print(f"{db:8d} {dt:13.4f} {h.bit_length() if h else -1:8d}   {st}")
        sys.stdout.flush()
    out["classno_bmc_seconds"] = bm

    with open(f"{HERE}/cost.json", "w") as fh:
        json.dump(out, fh, indent=1)
    print("\nwrote cost.json")