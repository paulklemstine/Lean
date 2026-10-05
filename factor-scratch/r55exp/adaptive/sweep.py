#!/usr/bin/env python3
"""
sweep.py -- THE MAIN EXPERIMENT.

For each modulus we sweep a grid of (k, m, t) cells and record, per instance:
  * which cells SUCCEED (factor verified by division + primality, see cell.py)
  * the WALL-CLOCK cost of each cell (the cost model, measured not assumed)
  * a VACUITY PROBE: does the same lattice ALSO annihilate a RANDOM point?

From that we price the adaptive rule exactly, with no modelling assumptions:
an adaptive strategy is an ORDERED list of cells; its cost on an instance is the
sum of cell costs up to and including the first success (or the whole list on
failure).  We then compare strategies by (success rate, expected cost).

PREDICTIONS (written before running):
 Q1  best-k distribution: sub-n/4 hits exist at n=48 and n=64, ~none at n=80.
     => the sub-n/4 rate SHRINKS with n.
 Q2  the sub-n/4 hits, when they occur, need LARGE d (=m*t).  The cells that
     produce the win are the EXPENSIVE ones.  => the sweep multiplier exceeds d+1.
 Q3  VACUITY: random-point annihilation rate is ~0 (generic expectation is high:
     T/|polys| per cell).  Prior work found 0/200; confirm independently.
 Q4  EXPECTED VERDICT: negative.  Adaptive beats n/4 only if
     P(sub-n/4 hit) * (cost saved) > P(n/4 hit) * (cost of trying below it).
     Since the n/4 cells are cheap and already succeed on most instances, the
     extra below-n/4 cells are paid on EVERY instance but pay off on a MINORITY.
"""
import sys, os, json, time, random, argparse
sys.path.insert(0, '/home/raver1975/lean/Experiments/UMWWindow')
from coppersmith_lattice import _reduced_polys, evalp, gen_prime
from cell import make_instance, cell

SEED = 20261004
RANDPROBES = 24          # random points per successful cell (vacuity control)
KSPAN = 5                # k = n/4-5 .. n/4
MMAX = 10                # m,t in 2..MMAX  -> 81 cells

def grid(mmax=MMAX):
    """Cells ordered by lattice dimension d=m*t ascending: the cost-greedy order.
    Ties broken by (m,t) so the order is deterministic and instance-independent."""
    cs = [(m, t) for m in range(2, mmax + 1) for t in range(2, mmax + 1)]
    cs.sort(key=lambda mt: (mt[0] * mt[1], mt[0], mt[1]))
    return cs

def vacuity(N, p, nn, k, m, t, rng, nprobe=RANDPROBES):
    """NEGATIVE CONTROL.  cell() accepts on h(x_TRUE)==0.  If the same lattice also
    annihilates a RANDOM point of the same size, the test is VACUOUS -- any small
    lattice contains a low-degree poly vanishing at whatever point you hand it --
    and the 'sub-n/4 successes' carry no information.
    Returns (n_random_probes, n_random_hits, n_polys)."""
    tb = nn // 2 - k
    X = 1 << tb
    p0 = (p >> tb) * X
    polys = _reduced_polys([p0, 1], N, X, m, t)
    if not polys: return 0, 0, 0
    hits = 0
    for _ in range(nprobe):
        xr = rng.randrange(1, X)
        if any(evalp(h, xr) == 0 for h in polys): hits += 1
    return nprobe, hits, len(polys)

def run(nbits, T, mmax=MMAX, kspan=KSPAN, vac=True, out=None):
    cells = grid(mmax)
    # ERROR LOG (mine, r55): this originally used `rng = random.Random(SEED)` and
    # passed rng into make_instance -- but make_instance IGNORES it and calls
    # gen_prime, which reads the GLOBAL random module.  The sweep was therefore
    # UNSEEDED and produced a different instance set on every invocation.  Caught by
    # the calibration check: two runs shared 0 of the instance set.  Seed the global.
    random.seed(SEED)
    rng = random
    rows = []           # one dict per instance
    for i in range(T):
        N, p, q, nn = make_instance(nbits, rng)
        q4 = nn // 4
        ks = [q4 - d for d in range(kspan, 0, -1)] + [q4]   # ascending cost order? no:
        # an adaptive rule goes from n/4 DOWNWARD (widest bound first).
        ks = [q4 - d for d in range(0, kspan + 1)]
        rec = {"nn": nn, "n4": q4, "N": str(N), "cells": {}, "vac": []}
        for k in ks:
            for (m, t) in cells:
                f, dt, npol = cell(N, p, nn, k, m, t)
                ok = bool(f)
                # independent re-verification, not trusting cell()
                if ok:
                    assert N % f == 0 and 1 < f < N and f in (p, q), "BAD FACTOR"
                rec["cells"][f"{k}|{m}|{t}"] = [ok, round(dt, 6), npol]
                if ok and vac:
                    np_, hr, npl = vacuity(N, p, nn, k, m, t, rng)
                    rec["vac"].append([k, m, t, np_, hr, npl])
        rows.append(rec)
        if (i + 1) % 10 == 0:
            print(f"  n={nbits}: {i+1}/{T} instances", flush=True)
    res = {"nbits": nbits, "T": T, "mmax": mmax, "kspan": kspan,
           "seed": SEED, "cells_order": [f"{m},{t}" for m, t in cells], "rows": rows}
    if out:
        json.dump(res, open(out, "w"))
        print(f"  wrote {out} ({os.path.getsize(out)/1e6:.1f} MB)")
    return res

if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("--n", type=int, required=True)
    ap.add_argument("--T", type=int, required=True)
    ap.add_argument("--mmax", type=int, default=MMAX)
    ap.add_argument("--kspan", type=int, default=KSPAN)
    ap.add_argument("--out", type=str, default=None)
    ap.add_argument("--novac", action="store_true")
    a = ap.parse_args()
    t0 = time.time()
    run(a.n, a.T, a.mmax, a.kspan, vac=not a.novac, out=a.out)
    print(f"n={a.n} T={a.T} done in {time.time()-t0:.0f}s")
