"""
run_baseline.py -- PREREG-0, the MANDATORY GATE.  Runs BEFORE any sweep.

r48's own kill configurations on seeds disjoint from r48 (7-11) and r49
(>= 77000), through MY code path (bsweep_core.attempt_counted), with the
bounded stripper -- validated identical to the full stripper on every non-null
instance in self-test W4.

Accept: pooled rate in [0.70, 0.85], |z| vs 20/27| < 3.
FAIL  => stop, do not sweep.

Parallel over 16 cores; each instance is independent and seeded.
"""
from __future__ import annotations

import json
import math
import os
import sys
import time
from multiprocessing import Pool

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from bsweep_core import P_TRUE, one  # noqa: E402

CONFIGS = [
    # (nbits, b, c, N, label)  -- r48's configurations, verbatim
    (20, 15, 10, 60, "~2^20 b=15 c=10"),
    (26, 8, 5, 60, "~2^26 b=8 c=5"),
    (26, 8, 10, 60, "~2^26 b=8 c=10"),
    (30, 12, 10, 50, "~2^30 b=12 c=10"),
    (40, 20, 10, 30, "~2^40 b=20 c=10"),
]
SEED0 = 900_000          # disjoint from r48's 7-11 and r49's >= 77000


def _work(a):
    nbits, b, c, seed = a
    try:
        return one(nbits, b, c, seed, cap=40_000_000)
    except Exception as e:  # noqa: BLE001
        return {"error": repr(e), "nbits": nbits, "b": b, "c": c, "seed": seed}


def run():
    jobs, meta = [], []
    for nbits, b, c, N, lab in CONFIGS:
        for k in range(N):
            jobs.append((nbits, b, c, SEED0 + 7919 * (nbits + 3 * b + 5 * c) + k))
            meta.append((nbits, b, c))
    print(f"PREREG-0 baseline: {len(jobs)} instances, seeds {SEED0}+, "
          f"target {P_TRUE:.6f}", flush=True)
    t0 = time.time()
    with Pool(16) as pool:
        res = pool.map(_work, jobs, chunksize=1)
    print(f"wall clock {time.time()-t0:.1f}s", flush=True)

    out, F, Ntot, errs = [], 0, 0, 0
    print(f"\n{'band':<22}{'b':>4}{'c':>4}{'N':>6}{'factors':>10}{'rate':>8}"
          f"{'z vs 20/27':>12}{'exp/rel':>10}{'exp/attempt':>13}{'secs/att':>10}")
    for nbits, b, c, N, lab in CONFIGS:
        rs = [r for r, m in zip(res, meta) if m == (nbits, b, c)]
        good = [r for r in rs if "error" not in r]
        errs += len(rs) - len(good)
        f = sum(1 for r in good if r["ok"])
        Ntot += len(good)
        F += f
        se = math.sqrt(P_TRUE * (1 - P_TRUE) / max(len(good), 1))
        er = sum(r["exps"] for r in good) / max(len(good), 1) / (b + c)
        ea = sum(r["exps"] for r in good) / max(len(good), 1)
        sc = sum(r["secs"] for r in good) / max(len(good), 1)
        print(f"{lab:<22}{b:>4}{c:>4}{len(good):>6}{f:>6}/{len(good):<3}"
              f"{f/max(len(good),1):>8.4f}{(f/max(len(good),1)-P_TRUE)/se:>+12.2f}"
              f"{er:>10.0f}{ea:>13.0f}{sc:>10.2f}", flush=True)
        out.append({"nbits": nbits, "b": b, "c": c, "N": len(good), "f": f,
                    "rate": f / max(len(good), 1),
                    "z": (f / max(len(good), 1) - P_TRUE) / se,
                    "exp_per_rel": er, "exp_per_attempt": ea,
                    "secs_per_attempt": sc})
    rate = F / max(Ntot, 1)
    se = math.sqrt(P_TRUE * (1 - P_TRUE) / Ntot)
    z = (rate - P_TRUE) / se
    print(f"\nPOOLED {F}/{Ntot} = {rate:.4f}   z vs 20/27 = {z:+.2f}   "
          f"errors={errs}")
    verdict = ("PASS" if 0.70 <= rate <= 0.85 and abs(z) < 3 else "FAIL")
    print(f"PREREG-0: {verdict}")
    json.dump({"rows": out, "F": F, "N": Ntot, "rate": rate, "z": z,
               "verdict": verdict, "seed0": SEED0},
              open(os.path.join(os.path.dirname(os.path.abspath(__file__)),
                                "baseline.json"), "w"), indent=1)
    return verdict == "PASS"


if __name__ == "__main__":
    sys.exit(0 if run() else 1)