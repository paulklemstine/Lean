"""
run_combined.py -- PHASE 4 / PREREG-3: does the optimal b change when round 49's
two held-out wins are applied together?

  S0  BASELINE   c=10, g uniform                     rate pred 20/27
  S1  PREREG-6   c=1,  g uniform                     rate pred 20/27
  S2  Jacobi     c=10, (g/n) = -1                    rate pred 8/9
  S3  COMBINED   c=1,  (g/n) = -1                    rate pred 8/9

PREREGISTERED: the optimal b is UNCHANGED, because both changes are constant
multipliers / a constant additive shift of (b+c), and the additive shift is
<= 9/(b+1) which FALLS as b grows -- so if anything the combined arm should
push the argmin slightly UP.  Falsified if the combined argmin differs from the
unfiltered argmin by more than the sampling noise on the cost curve.

The b values are passed in from the phase-1/2 argmin, so this is not a
re-sweep -- it is the four-scheme comparison AT the optimum.
"""
from __future__ import annotations

import json
import os
import sys
import time
from multiprocessing import Pool

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from run_sweep import _work_full, agg  # noqa: E402


def save(obj):
    json.dump(obj, open(OUT, "w"), indent=1)  # NOT run_sweep.save -- that
    # would overwrite sweep.json, which is this run's input from phases 1-3.
from bsweep_core import P_JACOBI, P_TRUE  # noqa: E402

OUT = os.path.join(HERE, "combined.json")
NPROC = int(os.environ.get("NPROC", 12))

SCHEMES = [
    ("S0 baseline  c=10 g uniform", 10, 0),
    ("S1 c=1        g uniform", 1, 0),
    ("S2 c=10       Jacobi -1", 10, 1),
    ("S3 COMBINED   c=1  Jacobi -1", 1, 1),
]


def main():
    nbits = int(os.environ.get("NBITS", 30))
    N = int(os.environ.get("NFULL", 160))
    CAP = int(os.environ.get("CAP", 2_000_000))
    bs = [int(x) for x in os.environ.get(
        "BS", "12,26,52,80,100,128").split(",")]
    SEED0 = int(os.environ.get("SEED0", 1_700_000))
    out = json.load(open(OUT)) if os.path.exists(OUT) else {}
    key = f"n{nbits}"
    rows = out.get(key, [])

    jobs, meta = [], []
    for b in bs:
        for lab, c, jac in SCHEMES:
            for k in range(N):
                jobs.append((nbits, b, c, SEED0 + 1009 * b + 7919 * c + 17 * jac + k,
                             jac, CAP))
                meta.append((b, c, jac))
    print(f"PHASE 4  n ~ 2^{nbits}, N={N} per (b, scheme), b in {bs}, "
          f"cap={CAP}", flush=True)
    t0 = time.time()
    with Pool(NPROC) as pool:
        res = pool.map(_work_full, jobs, chunksize=1)
    print(f"wall {time.time()-t0:.1f}s", flush=True)

    hdr = (f"{'b':>5}" + "".join(f"{s[0]:>26}" for s in SCHEMES))
    print(hdr, flush=True)
    print(f"{'':>5}" + "".join(f"{'rate    cost/succ  exp/rel':>26}"
                               for _ in SCHEMES), flush=True)
    for b in bs:
        cells, rec = "", []
        for lab, c, jac in SCHEMES:
            a = agg(res, nbits, b, c, jac)
            rec.append(a)
            if "cost_per_success" in a:
                cells += (f"{a['rate']:>7.4f}{a['cost_per_success']:>11.5g}"
                          f"{a['exp_per_rel']:>8.4g}")
            else:
                cells += f"{'INFEASIBLE':>26}"
        print(f"{b:>5}{cells}", flush=True)
        rows.append({"b": b, "schemes": [
            {"label": SCHEMES[i][0], "c": SCHEMES[i][1], "jac": SCHEMES[i][2],
             **{k: v for k, v in rec[i].items() if k != "errs"}}
            for i in range(len(SCHEMES))]})
        out[key] = rows
        save(out)

    # the verdict: argmin per scheme
    print("\nargmin of PRIMARY cost/success, per scheme:", flush=True)
    best = {}
    for i, (lab, c, jac) in enumerate(SCHEMES):
        cand = [(rows_r["schemes"][i]["b"], rows_r["schemes"][i]["cost_per_success"])
                for rows_r in out[key]
                if "cost_per_success" in rows_r["schemes"][i]]
        if cand:
            bb = min(cand)[0]
            best[lab] = bb
            print(f"  {lab:<28} b* = {bb}", flush=True)
    if len(set(best.values())) == 1:
        print("PREREG-3: argmin UNCHANGED by c=1 + Jacobi -- as preregistered.",
              flush=True)
    else:
        print(f"PREREG-3: argmin MOVED: {best} -- preregistration falsified.",
              flush=True)
    out[key + "_argmin"] = best
    json.dump(out, open(OUT, "w"), indent=1)
    print("done ->", OUT)


if __name__ == "__main__":
    main()