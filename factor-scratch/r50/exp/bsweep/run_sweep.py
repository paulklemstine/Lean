"""
run_sweep.py -- the b-sweep of TOTAL COST (H1, H2, H3), plus PREREG-4.

Phases, in order; each writes its rows to sweep.json as soon as it finishes, so
a timeout cannot destroy a completed phase.

  PHASE 1  COST CURVE.  Relation-finding ONLY (no linear algebra).  exp/rel is
           exact without the algebra, so the whole b-grid is measurable even
           where the full pipeline is not.
  PHASE 2  FULL PIPELINE.  relations -> kernel -> gcd, so the RATE is measured
           and never assumed, and so wall clock is a real end-to-end number.
  PHASE 3  PREREG-4, the b=6 rate anomaly.  RATE ONLY, at high N.
  PHASE 4  PREREG-3, the combined configuration (c=1 and Jacobi(g/n) = -1).

METRICS, labelled everywhere:
  PRIMARY   exp per SUCCESSFUL factor = (b+c) * exp/rel / rate
  SECONDARY exp/rel = exponentiations per RELATION.  A drop here is an
            improvement ONLY if the primary also drops.
  WALL CLOCK is separate: it includes the linear algebra, which is not an
            exponentiation and grows super-linearly in b.

The b-grid is extended past the required [4..64] because the preregistered
Dickman model's argmin (b=200 at 2^30, b=700 at 2^40) lies OUTSIDE it and the
model is still falling at b=64.  Stopping at 64 would report "argmin at the
right edge", which is not a result.
"""
from __future__ import annotations

import json
import math
import os
import random
import sys
import time
from multiprocessing import Pool

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)

from bsweep_core import (  # noqa: E402
    P_JACOBI, P_TRUE, bb_for_b, cost_model_per_success, jacobi_g, rand_g, u_of,
)
from stange import (  # noqa: E402
    build_M, factor_base, fb_exponents, gen_semiprime, order_mod_n,
)
from s2core import factor_from_bounded  # noqa: E402
from dickman import rho  # noqa: E402
from fastnull import nullspace_frac, primitive_fast  # noqa: E402

B_GRID = [int(x) for x in os.environ.get("BGRID",
        "4,6,8,12,16,20,26,32,40,52,64,80,100,128,160,200").split(",")]
FULL_B = [int(x) for x in os.environ.get("FULLB",
        "4,6,8,12,16,20,26,32,40,52,64,80,100,128").split(",")]
OUT = os.path.join(HERE, "sweep.json")
NPROC = int(os.environ.get("NPROC", 12))


def _find(n, g, FB, need, rng, cap):
    rels, seen, exps = [], set(), 0
    while len(rels) < need:
        if exps >= cap:
            return rels, exps, True
        x = rng.randrange(1, n)
        if x in seen:
            continue
        r = pow(g, x, n)
        exps += 1
        e, rem = fb_exponents(r, FB)
        if rem == 1:
            seen.add(x)
            rels.append((e, x))
    return rels, exps, False


def _prep(nbits, b, seed, jac, cap):
    rng = random.Random(seed)
    n, p, q = gen_semiprime(nbits, rng)
    FB = factor_base(bb_for_b(b), n)
    if len(FB) != b:
        raise RuntimeError(f"factor base {len(FB)} != b={b} (a base prime "
                           f"divides n); regenerate")
    g = jacobi_g(n, rng, -1) if jac else rand_g(n, rng)
    return rng, n, p, q, g, FB


def _work_cost(a):
    nbits, b, c, seed, cap = a
    try:
        rng, n, p, q, g, FB = _prep(nbits, b, seed, 0, cap)
        rels, exps, cap_hit = _find(n, g, FB, b + c, rng, cap)
        return dict(nbits=nbits, b=b, c=c, jac=0, exps=exps, cap_hit=cap_hit,
                    err=None, secs=0.0)
    except Exception as e:  # noqa: BLE001
        return dict(nbits=nbits, b=b, c=c, jac=0, exps=0, cap_hit=False,
                    err=repr(e), secs=0.0)


def _work_full(a):
    nbits, b, c, seed, jac, cap = a
    from math import gcd
    try:
        rng, n, p, q, g, FB = _prep(nbits, b, seed, jac, cap)
        t0 = time.perf_counter()
        rels, exps, cap_hit = _find(n, g, FB, b + c, rng, cap)
        t1 = time.perf_counter()
        if cap_hit:
            return dict(nbits=nbits, b=b, c=c, jac=jac, exps=exps,
                        cap_hit=True, ok=False, err=None, secs=t1 - t0,
                        secs_rels=t1 - t0, secs_alg=0.0, secs_strip=0.0, G=0)
        t2 = time.perf_counter()
        K, rank = nullspace_frac(build_M(rels, b))
        xs = [rels[j][1] for j in range(len(rels))]
        G = 0
        for v in K[:c]:
            pv = primitive_fast(v)
            G = gcd(G, abs(sum(pv[j] * xs[j] for j in range(len(rels)))))
        og = order_mod_n(g, n, p, q)
        assert G == 0 or G % og == 0, "ord(g) must divide every alpha_t"
        t3 = time.perf_counter()
        fac = factor_from_bounded(G, g, n) if G else None
        if fac is not None and not (1 < fac < n and n % fac == 0):
            fac = None                       # never credit a trivial gcd
        t4 = time.perf_counter()
        return dict(nbits=nbits, b=b, c=c, jac=jac, exps=exps, cap_hit=False,
                    ok=fac in (p, q), err=None, secs=t4 - t0,
                    secs_rels=t1 - t0, secs_alg=t3 - t2, secs_strip=t4 - t3, G=G)
    except Exception as e:  # noqa: BLE001
        return dict(nbits=nbits, b=b, c=c, jac=jac, exps=0, cap_hit=False,
                    ok=False, err=repr(e), secs=0.0, secs_rels=0.0,
                    secs_alg=0.0, secs_strip=0.0, G=0)


def agg(rows, nbits, b, c, jac=0):
    rs = [r for r in rows if r["nbits"] == nbits and r["b"] == b
          and r["c"] == c and r["jac"] == jac]
    good = [r for r in rs if r["err"] is None]
    done = [r for r in good if not r["cap_hit"]]
    a = dict(nbits=nbits, b=b, c=c, jac=jac, N=len(good), N_capped=len(good) - len(done),
             N_err=len(rs) - len(good), errs=[r["err"] for r in rs if r["err"]][:2])
    a["model_exp_per_rel"] = 1.0 / rho(u_of(b, nbits))
    if not done:
        a["cost_LB"] = (b + c) * (a.get("exp_per_rel", 0)) / P_TRUE
        if good:
            a["cost_LB"] = (b + c) * (min(r["exps"] for r in good) / (b + c)) / P_TRUE
        return a
    N = len(done)
    a["exp_per_rel"] = sum(r["exps"] for r in done) / (N * (b + c))
    a["exp_per_attempt"] = sum(r["exps"] for r in done) / N
    a["secs_per_attempt"] = sum(r.get("secs",0.0) for r in done) / N
    a["secs_rels"] = sum(r.get("secs_rels",0.0) for r in done) / N
    a["secs_alg"] = sum(r.get("secs_alg",0.0) for r in done) / N
    a["secs_strip"] = sum(r.get("secs_strip",0.0) for r in done) / N
    a["f"] = sum(1 for r in done if r.get("ok"))
    a["rate_pred"] = P_JACOBI if jac else P_TRUE
    measured = any("ok" in r for r in done)
    if measured:
        a["rate"] = a["f"] / N
        a["rate_source"] = "MEASURED (full pipeline)"
        a["cost_per_success"] = (b + c) * a["exp_per_rel"] / a["rate"]
        se = math.sqrt(max(a["rate"] * (1 - a["rate"]), 1e-9) / N)
        a["z"] = (a["rate"] - P_TRUE) / se
    else:
        # Phase 1 runs relation finding only: there is no pipeline, hence no
        # measured rate.  The rate is then PREDICTED, not assumed silently --
        # and the prediction is the one PREREG-0 reproduces here and round 49
        # measured over 33 000 instances flat in b, c and n.
        a["rate"] = a["rate_pred"]
        a["rate_source"] = "PREDICTED = 20/27 (no pipeline in phase 1)"
        a["cost_per_success"] = (b + c) * a["exp_per_rel"] / a["rate_pred"]
        a["z"] = None
    a["measured_over_model"] = a["exp_per_rel"] / a["model_exp_per_rel"]
    a["model_cost_per_success"] = cost_model_per_success(b, c, nbits,
                                                         a["rate_pred"])
    a["cost_vs_model"] = a["cost_per_success"] / a["model_cost_per_success"]
    if good and len(good) > N:
        # capped instances give a hard LOWER bound on exp/rel for this b
        a["exp_per_rel_LB_capped"] = (min(r["exps"] for r in good)
                                      / (b + c))
    return a


def save(out):
    json.dump(out, open(OUT, "w"), indent=1)


def main():
    NCOST = int(os.environ.get("NCOST", 20))
    N6 = int(os.environ.get("N6", 600))
    NFULL = int(os.environ.get("NFULL", 120))
    CAP = int(os.environ.get("CAP", 2_000_000))
    SEED0 = int(os.environ.get("SEED0", 950_000))
    out = json.load(open(OUT)) if os.path.exists(OUT) else {}

    # ---------------- PHASE 1 ------------------------------------------------
    for nbits in (30, 40):
        print(f"\n{'='*118}\nPHASE 1  COST CURVE (relation finding only, no linear algebra)"
              f"\n           n ~ 2^{nbits}, c=1, N={NCOST}/b, cap={CAP}\n{'='*118}", flush=True)
        jobs = [(nbits, b, 1, SEED0 + 104729 * nbits + 17 * b + k, CAP)
                for b in B_GRID for k in range(NCOST)]
        t0 = time.time()
        with Pool(NPROC) as pool:
            res = pool.map(_work_cost, jobs, chunksize=1)
        print(f"wall {time.time()-t0:.1f}s", flush=True)
        print(f"{'b':>5}{'BB':>5}{'u':>8}{'model 1/rho':>14}{'MEAS exp/rel':>15}"
              f"{'meas/model':>12}{'exp/attempt':>15}"
              f"{'PRIMARY (b+c)*exp/rel/rate':>27}{'model primary':>16}", flush=True)
        rows = []
        for b in B_GRID:
            a = agg(res, nbits, b, 1)
            rows.append(a)
            u = u_of(b, nbits)
            if "exp_per_rel" in a:
                print(f"{b:>5}{bb_for_b(b):>5}{u:>8.3f}{a['model_exp_per_rel']:>14.4g}"
                      f"{a['exp_per_rel']:>15.4g}{a['measured_over_model']:>12.3f}"
                      f"{a['exp_per_attempt']:>15.4g}"
                      f"{a['cost_per_success']:>27.5g}"
                      f"{a['model_cost_per_success']:>16.4g}", flush=True)
            else:
                print(f"{b:>5}{bb_for_b(b):>5}{u:>8.3f}{a['model_exp_per_rel']:>14.4g}"
                      f"{'--':>15}{'--':>12}{'--':>15}"
                      f"INFEASIBLE (>={a.get('cost_LB',0):.4g})".rjust(27)
                      + f"{'':>16}", flush=True)
        out[f"phase1_n{nbits}_c1"] = rows
        save(out)

    # ---------------- PHASE 2 ------------------------------------------------
    for nbits in (30, 40):
        print(f"\n{'='*118}\nPHASE 2  FULL PIPELINE (relations -> kernel -> gcd): "
              f"MEASURED rate + WALL CLOCK"
              f"\n           n ~ 2^{nbits}, c=1, N={NFULL}/b\n{'='*118}", flush=True)
        jobs = [(nbits, b, 1, SEED0 + 555_555 + 104729 * nbits + 17 * b + k,
                 0, CAP) for b in FULL_B for k in range(NFULL)]
        t0 = time.time()
        with Pool(NPROC) as pool:
            res = pool.map(_work_full, jobs, chunksize=1)
        print(f"wall {time.time()-t0:.1f}s", flush=True)
        print(f"{'b':>5}{'N':>6}{'factors':>10}{'rate':>8}{'z vs 20/27':>12}"
              f"{'exp/rel':>10}{'PRIMARY cost/succ':>19}{'model':>13}"
              f"{'secs/att':>10}{'rels':>9}{'alg':>9}{'strip':>8}", flush=True)
        rows = []
        for b in FULL_B:
            a = agg(res, nbits, b, 1)
            rows.append(a)
            if "cost_per_success" in a:
                print(f"{b:>5}{a['N']:>6}{a['f']:>5}/{a['N']:<4}{a['rate']:>8.4f}"
                      f"{a['z']:>+12.2f}{a['exp_per_rel']:>10.4g}"
                      f"{a['cost_per_success']:>19.5g}"
                      f"{a['model_cost_per_success']:>13.4g}"
                      f"{a['secs_per_attempt']:>10.2f}{a['secs_rels']:>9.2f}"
                      f"{a['secs_alg']:>9.2f}{a['secs_strip']:>8.3f}", flush=True)
            else:
                print(f"{b:>5}{a['N']:>6}  INFEASIBLE / all capped "
                      f"(N_capped={a['N_capped']})", flush=True)
        out[f"phase2_n{nbits}_c1"] = rows
        save(out)

    # ---------------- PHASE 3: PREREG-4, the b=6 rate anomaly ---------------
    print(f"\n{'='*118}\nPHASE 3  PREREG-4  the b=6 RATE anomaly (RATE ONLY, not cost)"
          f"\n           n ~ 2^30, b=6, c=10, N=600 fresh seeds, g uniform\n{'='*118}", flush=True)
    jobs = [(30, 6, 10, 1_300_000 + k, 0, 8_000_000) for k in range(N6)]
    t0 = time.time()
    with Pool(NPROC) as pool:
        res = pool.map(_work_full, jobs, chunksize=1)
    a = agg(res, 30, 6, 10)
    out["phase3_b6_rate"] = a
    save(out)
    if "rate" in a:
        print(f"b=6 rate = {a['f']}/{a['N']} = {a['rate']:.4f}   "
              f"z vs 20/27 = {a['z']:+.2f}   wall {time.time()-t0:.1f}s", flush=True)
        print("PREREG-4: " + ("CONSISTENT with 20/27 (anomaly was chance)"
                              if abs(a["z"]) < 3 else "ANOMALY IS REAL -- b=6 excluded"),
              flush=True)
    else:
        print("b=6: all instances capped; PREREG-4 NOT ANSWERED", flush=True)

    save(out)
    print("\ndone ->", OUT)


if __name__ == "__main__":
    main()