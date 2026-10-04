"""
exp_e2e.py -- H2/H3: END-TO-END wall clock per factored n, four arms, per modulus.

THE COMPARISON
--------------
  arm A  `stange-uniform`  Stange's own relation finder, uniform base.        (baseline)
  arm B  `stange-jac`      same, Jacobi(g/n) = -1 base.          II_baseg's 1.2x lever
  arm C  `sieve-uniform`   NFS-STYLE relation finding + the SAME Stange kernel/gcd.
  arm D  `sieve-jac`       NFS-style finding + Jacobi base.

C and A differ ONLY in the relation-finding route: same relation CONDITION
(`g^x = prod p_i^{f_i} mod n`), same factor base, same kernel, same gcd, same base
selection.  selftest T8 pins that the two collectors return the same relations for the
same x-stream, so any timing difference is the route and not a different problem.

EVERYTHING IS CHARGED: computing the base, relation collection, the Q-kernel, the gcd.

THE MANDATORY CONTROL
---------------------
Rates are reported PER MODULUS against that modulus's own `p_split` and never pooled
alone.  II_baseg §3b measures moduli spanning [0.5000, 0.9961]; PP_droptest §3.2 shows the
mean `p_split` of the same cell moving by 0.085 between samples.  So each row carries its
cell label and its own predicted rate, and the verdict per modulus is one-sided: is the
observed count consistent with Binomial(N_attempts, p_split)?

`plain NFS` is NOT TIMED HERE and the note must say why: a real NFS at these sizes is
dominated by sieving in C, and PARI/GNFS timings would not be comparable to a Python
pipeline anyway.  What IS comparable is the cost of the phases, which is what H4 measures.
"""

from __future__ import annotations

import json
import math
import random
import sys
import time
from fractions import Fraction
from math import gcd

sys.path.insert(0, "/home/raver1975/lean/factor-scratch/r51exp/hybrid")

import hcore
from hcore import cell_label, diag, p_split, pick_g, run_pipeline

sys.path.insert(0, "/home/raver1975/lean/factor-scratch/r48/exp/stange")
import stange  # noqa: E402

ARMS = ("stange-uniform", "stange-jac", "sieve-uniform", "sieve-jac")


def one_attempt(n, p, q, FB, c, rng, route, base_mode):
    """ONE attempt, every phase charged, returns per-phase times and the factor."""
    g, t_base = pick_g(n, rng, base_mode)
    res = run_pipeline(n, g, FB, c, rng, rel_route=route)
    pt = hcore.PhaseTimes(t_base=t_base, t_rel=res["rel_seconds"],
                          t_LA=res["t_LA"], t_gcd=res["t_gcd"])
    return {"g": g, "factor": res["factor"], "G": res["G"],
            "trials": res["trials"], "dimK": res["dimK"], "rank": res["rank"],
            "times": pt.as_dict()}


def run_arm(moduli, FB_of, c, route, base_mode, max_attempts, seed):
    """Per-modulus: repeat attempts until a factor is found or the cap is hit.
    Wall clock is charged for EVERY attempt, success or not."""
    out = []
    for idx, (n, p, q) in enumerate(moduli):
        FB = FB_of(n)
        pred = p_split(p, q, base_mode)
        rng = random.Random(seed * 100003 + idx)
        attempts, total = 0, hcore.PhaseTimes()
        found = None
        t_wall0 = time.perf_counter()
        while attempts < max_attempts:
            r = one_attempt(n, p, q, FB, c, rng, route, base_mode)
            attempts += 1
            d = r["times"]
            total.t_base += d["t_base"]
            total.t_rel += d["t_rel"]
            total.t_LA += d["t_LA"]
            total.t_gcd += d["t_gcd"]
            if r["factor"] and 1 < r["factor"] < n:
                found = r["factor"]
                break
        wall = time.perf_counter() - t_wall0
        d = total.as_dict()
        out.append({
            "n_bits": n.bit_length(), "cell": cell_label(p, q),
            "diag": diag(p, q), "p_split": float(pred), "attempts": attempts,
            "found": bool(found), "wall": wall, **d,
        })
    return out


def binomial_consistent(hits, N, pred, alpha=1e-4):
    """One-sided: is Binomial(N, pred) consistent with `hits`?

    OO_bneed §4b recorded the failure this replaces: an arbitrary tolerance band
    (`excess_lo >= -0.10`) reported "the method never works" on a modulus where it had
    just factored 23 of 24 times, because the Wilson half-width alone was ~0.09.  Here
    the test is the hypothesis's own: a proper tail probability, no tolerance.
    """
    if N == 0:
        return True, float("nan")
    obs = hits / N
    if pred <= 0:
        return obs <= alpha, 0.0
    if pred >= 1:
        return obs >= 1 - alpha, 0.0
    se = math.sqrt(pred * (1 - pred) / N)
    z = (obs - pred) / se
    # two-sided tail
    pv = math.erfc(abs(z) / math.sqrt(2))
    return pv > alpha, pv


def main():
    n_mod = int(sys.argv[1]) if len(sys.argv) > 1 else 40
    bits = int(sys.argv[2]) if len(sys.argv) > 2 else 26
    b = int(sys.argv[3]) if len(sys.argv) > 3 else 15
    c = int(sys.argv[4]) if len(sys.argv) > 4 else 10
    max_att = int(sys.argv[5]) if len(sys.argv) > 5 else 12
    seed = int(sys.argv[6]) if len(sys.argv) > 6 else 4321

    rng = random.Random(seed)
    moduli = []
    while len(moduli) < n_mod:
        n, p, q = stange.gen_semiprime(bits, rng)
        assert p * q == n
        moduli.append((n, p, q))

    def FB_of(n):
        FB = stange.factor_base(stange.bbound_for_b(b), n)
        assert len(FB) == b, (len(FB), b)
        return FB

    print(f"H2 END-TO-END -- {n_mod} fresh semiprimes ~2^{bits}, b={b}, c={c}, "
          f"cap {max_att} attempts, seed {seed}")
    print("=" * 78)

    results = {}
    for arm in ARMS:
        route = "stange" if arm.startswith("stange") else "sieve"
        bmode = "jac_neg" if arm.endswith("jac") else "uniform"
        t0 = time.perf_counter()
        rows = run_arm(moduli, FB_of, c, route, bmode, max_att, seed)
        el = time.perf_counter() - t0
        results[arm] = rows
        hits = sum(1 for r in rows if r["found"])
        tot_wall = sum(r["wall"] for r in rows)
        tot = {"rel": sum(r["t_rel"] for r in rows),
               "LA": sum(r["t_LA"] for r in rows),
               "gcd": sum(r["t_gcd"] for r in rows),
               "base": sum(r["t_base"] for r in rows)}
        S = sum(tot.values())
        print(f"\n{arm:>16}: {hits}/{n_mod} factored in {el:7.2f}s wall "
              f"({tot_wall/max(1,hits)*1000:8.1f} ms per FACTORED n)")
        print(f"{'':>18}  charged: base {tot['base']*1e3:8.1f} ms  "
              f"rel {tot['rel']*1e3:10.1f} ms  LA {tot['LA']*1e3:8.1f} ms  "
              f"gcd {tot['gcd']*1e3:7.2f} ms")
        print(f"{'':>18}  frac:   base {tot['base']/S*100:5.2f}%  "
              f"REL {tot['rel']/S*100:6.2f}%  LA {tot['LA']/S*100:5.2f}%  "
              f"gcd {tot['gcd']/S*100:5.3f}%")

    # ---- per-modulus 2-adic control, each arm against ITS OWN cell ----
    print()
    print("=" * 78)
    print("PER-MODULUS 2-ADIC CONTROL (never pooled against 20/27)")
    print("=" * 78)
    for arm in ARMS:
        rows = results[arm]
        ok = 0
        flag = []
        for r in rows:
            good, pv = binomial_consistent(1 if r["found"] else 0, r["attempts"],
                                           r["p_split"])
            ok += int(good)
            if not good:
                flag.append(f"{r['cell']}:{r['attempts']}t,{r['p_split']:.3f}")
        print(f"  {arm:>16}: {ok}/{len(rows)} moduli consistent with their own p_split"
              + (f"   flagged: {', '.join(flag[:6])}" if flag else ""))
    print()
    print("  NOTE the spread of p_split across these moduli:")
    pr = [r["p_split"] for r in results[ARMS[0]]]
    print(f"    min {min(pr):.4f}  max {max(pr):.4f}  spread {max(pr)-min(pr):.4f}")
    nd = sum(1 for r in results[ARMS[0]] if r["diag"])
    print(f"    diagonal (a==b) cells: {nd}/{n_mod};  these are where II_baseg's lever "
          f"pays 94/94 and off-diagonal it LOSES.")

    # ---- paired comparison: A vs C (same modulus, same kernel, different RF) ----
    print()
    print("=" * 78)
    print("PAIRED: identical moduli, identical kernel+gcd, ONLY relation-finding differs")
    print("=" * 78)
    for ua, sa in (("stange-uniform", "sieve-uniform"), ("stange-jac", "sieve-jac")):
        A, S = results[ua], results[sa]
        relA = sum(r["t_rel"] for r in A)
        relS = sum(r["t_rel"] for r in S)
        wA = sum(r["wall"] for r in A)
        wS = sum(r["wall"] for r in S)
        print(f"  {ua} -> {sa}:")
        print(f"    relation-finding only: {relA:.3f}s -> {relS:.3f}s  "
              f"(ratio {relS/relA:.3f}x, i.e. {'cheaper' if relS<relA else 'DEARER'})")
        print(f"    total charged wall:    {wA:.3f}s -> {wS:.3f}s  (ratio {wS/wA:.3f}x)")

    with open("e2e_out.json", "w") as f:
        json.dump({"config": {"n_mod": n_mod, "bits": bits, "b": b, "c": c,
                              "max_attempts": max_att, "seed": seed},
                   "results": results}, f, indent=1)
    print("\nwrote e2e_out.json")


if __name__ == "__main__":
    main()