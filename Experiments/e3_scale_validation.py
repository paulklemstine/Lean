#!/usr/bin/env python3
"""Experiment E-3: Scale validation of adaptive B1 escalation at 48-64b factors.

H_scale: the adaptive scheduler's coverage advantage WIDENS with factor size.
Budget-capped: each arm gets 240s per instance; solved-within-budget is the metric.
"""
import sys, os, json, time
sys.path.insert(0, os.path.dirname(__file__))
from e2_adaptive_ecm import gen_semiprime, ecm_curves, arm_adaptive, arm_fixed, arm_oracle

BUDGET = 240


def main():
    sizes = [48, 56, 64]
    rows = []
    for s in sizes:
        N = gen_semiprime(s)
        arms = {
            "fixed_11k": lambda: arm_fixed(N, 11000),
            "fixed_250k": lambda: arm_fixed(N, 250000),
            "oracle": lambda: arm_oracle(N, 2 ** s),
            "adaptive": lambda: arm_adaptive(N),
        }
        for name, fn in arms.items():
            t0 = time.perf_counter()
            f, el = fn()
            ok = bool(f) and N % f == 0 and el <= BUDGET
            el_actual = time.perf_counter() - t0
            rows.append({"size": s, "arm": name, "s": round(el_actual, 1),
                         "ok": bool(ok)})
            print(f"  [{name:>10}] p~{s}b: {el_actual:7.1f}s ok={ok}", flush=True)
    out = os.path.join(os.path.dirname(__file__), "e3_results.json")
    json.dump(rows, open(out, "w"), indent=1)
    print("== SUMMARY ==")
    by_arm = {}
    for r in rows:
        by_arm.setdefault(r["arm"], []).append((r["size"], r["ok"], r["s"]))
    for arm, lst in sorted(by_arm.items()):
        solved = sum(1 for _, ok, _ in lst if ok)
        print(f"  {arm:>10}: solved {solved}/{len(lst)} "
              f"{[(sz, round(t)) for sz, ok, t in lst if ok]}")


if __name__ == "__main__":
    main()
