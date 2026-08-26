#!/usr/bin/env python3
"""Experiment E-2: Adaptive B1-escalation ECM vs static schedules.

H_adapt: when the factor size is UNKNOWN, an adaptive scheduler that escalates
B1 geometrically (starting cheap so small factors are caught fast) achieves
time-to-factor within noise of the ORACLE static schedule (B1 chosen knowing
the true factor size), and dominates any single fixed B1 across a mixed-size
workload.

Arms:
  fixed_low   : B1=11000 always        (common small-factor default)
  fixed_high  : B1=250000 always       (common large-factor default)
  adaptive    : B1 starts 1500, x3.16 escalation every k failed curves,
                k growing with level (cheap exploration, expensive confirmation)
  oracle      : B1 matched to true factor size (upper bound for static)

Workload: balanced semiprimes, smaller factor drawn from {18,24,30,36,42} bits,
2 trials each, interleaved round-robin so drift affects all arms equally.
"""
import subprocess
import statistics
from pathlib import Path
import json

ECM = "/usr/bin/ecm"


def gen_semiprime(pb):
    from gmpy2 import mpz, next_prime, mpz_urandomb, random_state
    RNG = random_state(pb * 7919)
    q = next_prime(mpz_urandomb(RNG, pb) | (mpz(1) << (pb - 1)))
    p = next_prime(mpz_urandomb(RNG, pb) | (mpz(1) << (pb - 1)))
    return mpz(p) * mpz(q)


def ecm_curves(N, B1, curves, timeout=90):
    """Run up to `curves` curves at B1; return (found_factor|None, elapsed_s)."""
    import time
    t0 = time.perf_counter()
    try:
        proc = subprocess.run(
            [ECM, "-c", str(curves), "-q", str(B1)],
            input=str(N), capture_output=True, text=True, timeout=timeout)
        el = time.perf_counter() - t0
        for line in proc.stdout.strip().splitlines():
            for tok in line.split():
                if tok.isdigit():
                    f = int(tok)
                    if 1 < f < N:
                        return f, el
    except subprocess.TimeoutExpired:
        return None, time.perf_counter() - t0
    return None, time.perf_counter() - t0


def arm_fixed(N, B1):
    f, el = ecm_curves(N, B1, 400, timeout=240)
    return f, el


def arm_oracle(N, p):
    table = {18: 2000, 24: 5000, 30: 11000, 36: 60000, 42: 260000}
    B1 = table.get(int(p).bit_length(), 11000)
    f, el = ecm_curves(N, B1, 400, timeout=240)
    return f, el


ADAPT_LEVELS = [(1500, 3), (4800, 6), (15000, 12), (48000, 24),
                (150000, 48), (480000, 96)]


def arm_adaptive(N):
    import time
    total = 0.0
    for B1, k in ADAPT_LEVELS:
        f, el = ecm_curves(N, B1, k, timeout=180)
        total += el
        if f:
            return f, total
        if total > 300:
            break
    return None, total


def main():
    sizes = [18, 24, 30, 36, 42]
    workload = [(s, i) for i in range(2) for s in sizes]  # interleaved
    rows = []
    for idx, (s, trial) in enumerate(workload):
        N = gen_semiprime(s)
        arms = {
            "fixed_low": lambda: arm_fixed(N, 11000),
            "fixed_high": lambda: arm_fixed(N, 250000),
            "oracle": lambda: arm_oracle(N, 2 ** s),
            "adaptive": lambda: arm_adaptive(N),
        }
        for name, fn in arms.items():
            f, el = fn()
            ok = bool(f) and N % f == 0
            rows.append({"size": s, "trial": trial, "arm": name,
                         "s": round(el, 3), "ok": ok})
            print(f"  [{name:>10}] p~{s:>2}b t#{trial}: "
                  f"{el:7.2f}s ok={ok}")

    # aggregate
    print("\n== RESULTS (median time-to-factor by size) ==")
    summary = {}
    for name in ("fixed_low", "fixed_high", "oracle", "adaptive"):
        per_size = {}
        for r in rows:
            if r["arm"] == name and r["ok"]:
                per_size.setdefault(r["size"], []).append(r["s"])
        medians = {k: round(statistics.median(v), 2) for k, v in sorted(per_size.items())}
        solved = sum(len(v) for v in per_size.values())
        total_time = sum(sum(v) for v in per_size.values())
        summary[name] = {"medians": medians, "solved": f"{solved}/10",
                         "total_s": round(total_time, 1)}
        print(f"  {name:>10}: solved={solved}/10 total={total_time:8.1f}s {medians}")

    out = Path(__file__).parent / "e2_results.json"
    out.write_text(json.dumps({"rows": rows, "summary": summary}, indent=1))


if __name__ == "__main__":
    main()
