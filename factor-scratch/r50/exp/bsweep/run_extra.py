"""
run_extra.py -- three follow-ups the first sweep forced.

E1  EXTEND THE COST CURVE.  At n ~ 2^40 the cost curve is STILL FALLING at
    b=200, so the argmin was not bracketed.  PREREG-2 says: if the argmin runs
    off the end, report "no argmin found up to b_max" -- but only after trying
    further, and only the relation-finding cost is needed, so this is cheap.

E2  HIGHER-N RATE CHECK AT THE SMALLEST b.  The full pipeline gave b=4 a rate
    of 0.8475 (z=+3.22) and b=6 a rate of 0.8167 (z=+2.15) at N=120, against
    20/27 -- the OPPOSITE sign to round 49's b=6 anomaly (z=-2.48).  A 3.2-sigma
    deviation is either a real small-b effect or a one-off, and at N=120 the
    two are not distinguishable.  Re-run at N=600 with fresh seeds.

E3  G == 0 DIAGNOSTIC.  A small-b rate anomaly would have TWO possible
    mechanisms -- the order step, or the relation search returning no usable
    multiple (G=0) -- and they are different claims.  Separated here.
"""
from __future__ import annotations

import json
import math
import os
import sys
import time
from multiprocessing import Pool

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from run_sweep import _work_cost, _work_full, agg  # noqa: E402
from bsweep_core import P_TRUE, u_of  # noqa: E402

OUT = os.path.join(HERE, "extra.json")
NPROC = int(os.environ.get("NPROC", 12))


def main():
    what = os.environ.get("WHAT", "E1,E2,E3")
    N = int(os.environ.get("N", 20))
    CAP = int(os.environ.get("CAP", 2_000_000))
    out = json.load(open(OUT)) if os.path.exists(OUT) else {}

    if "E1" in what:
        EXT = [int(x) for x in os.environ.get(
            "EXT", "256,320,400,500,700,1000").split(",")]
        for nbits in (30, 40):
            print(f"\n{'='*112}\nE1  EXTENDED COST CURVE  n ~ 2^{nbits}, c=1, "
                  f"N={N}/b, b in {EXT}\n{'='*112}", flush=True)
            jobs = [(nbits, b, 1, 2_400_000 + 104_729 * nbits + 17 * b + k, CAP)
                    for b in EXT for k in range(N)]
            t0 = time.time()
            with Pool(NPROC) as pool:
                res = pool.map(_work_cost, jobs, chunksize=1)
            print(f"wall {time.time()-t0:.1f}s", flush=True)
            print(f"{'b':>6}{'BB':>6}{'u':>8}{'model 1/rho':>14}"
                  f"{'MEAS exp/rel':>15}{'meas/model':>12}"
                  f"{'PRIMARY cost/succ':>21}{'model primary':>16}", flush=True)
            rows = []
            for b in EXT:
                a = agg(res, nbits, b, 1)
                rows.append(a)
                u = u_of(b, nbits)
                if "exp_per_rel" in a:
                    print(f"{b:>6}{int(round(2**0)):>0}{u:>8.3f}"
                          f"{a['model_exp_per_rel']:>14.4g}{a['exp_per_rel']:>15.4g}"
                          f"{a['measured_over_model']:>12.3f}"
                          f"{a['cost_per_success']:>21.5g}"
                          f"{a['model_cost_per_success']:>16.4g}", flush=True)
                else:
                    print(f"{b:>6}{'':>6}{u:>8.3f}{a['model_exp_per_rel']:>14.4g}"
                          f"{'INFEASIBLE':>15}", flush=True)
            out[f"E1_n{nbits}"] = rows
            json.dump(out, open(OUT, "w"), indent=1)

    if "E2" in what:
        N2 = int(os.environ.get("N2", 600))
        bs = [int(x) for x in os.environ.get("BS2", "4,6,8,12").split(",")]
        print(f"\n{'='*112}\nE2  HIGH-N RATE CHECK at the smallest b, "
              f"n ~ 2^30, c=1, N={N2}/b, fresh seeds\n{'='*112}", flush=True)
        jobs = [(30, b, 1, 2_900_000 + 31 * b + k, 0, CAP)
                for b in bs for k in range(N2)]
        t0 = time.time()
        with Pool(NPROC) as pool:
            res = pool.map(_work_full, jobs, chunksize=1)
        print(f"wall {time.time()-t0:.1f}s", flush=True)
        print(f"{'b':>5}{'N':>7}{'factors':>11}{'rate':>9}{'z vs 20/27':>12}"
              f"{'G==0':>7}{'PRIMARY cost/succ':>21}", flush=True)
        rows = []
        for b in bs:
            a = agg(res, 30, b, 1)
            g0 = sum(1 for r in res if r["b"] == b and r["err"] is None
                     and not r["cap_hit"] and r["G"] == 0)
            a["G0"] = g0
            rows.append(a)
            print(f"{b:>5}{a['N']:>7}{a['f']:>6}/{a['N']:<4}{a['rate']:>9.4f}"
                  f"{a['z']:>+12.2f}{g0:>7}{a['cost_per_success']:>21.5g}",
                  flush=True)
        # Pooled small-b vs large-b rate: does rate really depend on b?
        small = [r for r in res if r["b"] in bs and r["err"] is None
                 and not r["cap_hit"]]
        f = sum(1 for r in small if r["ok"])
        N = len(small)
        rate = f / N
        se = math.sqrt(rate * (1 - rate) / N)
        print(f"POOLED b in {bs}: {f}/{N} = {rate:.4f}, z vs 20/27 = "
              f"{(rate-P_TRUE)/se:+.2f}", flush=True)
        out["E2"] = {"rows": rows, "pooled_b": bs, "f": f, "N": N,
                     "rate": rate, "z": (rate - P_TRUE) / se}
        json.dump(out, open(OUT, "w"), indent=1)

    print("\ndone ->", OUT, flush=True)


if __name__ == "__main__":
    main()