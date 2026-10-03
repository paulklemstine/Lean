"""
BB / PRIORITY 1 -- does the x0 = n/4 stride repair deliver a REAL end-to-end
speedup on Stange's relation finder?

AA_stride_sampler.md left this open and listed four things unproven:
  (1) multiplications, not trials;
  (2) the alpha_t kernel is non-degenerate after the repair;
  (3) it actually factors, at an n where cost matters;
  (4) fresh instances.
This file settles all four, and settles (5) -- the RANK of M -- which AA never
looked at and which is a second, independent degeneracy axis.

=============================== PREREGISTERED ===============================
(P1) `stride` at x0 = n/4 with an odd stride s in [n/4, n/2) draws the same
     population as `random`: skew S = (trials/rel) x (measured uniform density)
     lies in [0.6, 1.6].  `stride` at x0 = 1 does NOT (S < 0.7 x S_random).

(P2) COST.  Per candidate:
       random : ~2*log2(x) multiplications  (pow)  + |FB| smoothness reductions
       stride : 1 multiplication                          + |FB| reductions
     so the end-to-end op-ratio (random/stride) at n = 2^40, b = 20 is
       (80 + 20) / (1 + 20)  =  4.8x
     and it GROWS with n, because the numerator grows like log n and the
     denominator does not.  Expect 3-6x at 2^26..2^40 and > 8x at 2^64.

(P3) AXIS 2.  stride_full must give rank(M) = b and zero_frac(alpha) < 0.15.
     RISK PREREGISTERED: under a stride the alpha_t are
       alpha_t = x0 * sum_j v_j + s * sum_j j v_j,
     so a zero alpha needs TWO constraints on v, not one.  I predict this makes
     stride_full slightly WORSE than random, not better, but both are ≪ seq.
     If stride_full's all_zero rate exceeds random's by more than 2x the repair
     is declared unsafe regardless of its cost.

(P4) stride_full ACTUALLY FACTORS, on fresh instances, at an n where the
     round-48 baseline cost (26,213 exponentiations/relation) is the thing being
     beaten.

If any of P1-P4 fails, the saving is reported as illusory.  They are written
here before the first measurement and are not edited afterwards.
==========================================================================
"""

from __future__ import annotations

import math
import random
import sys
import time

sys.path.insert(0, "/home/raver1975/lean/factor-scratch/r52/exp/smooth")
sys.path.insert(0, "/home/raver1975/lean/factor-scratch/r48/exp/stange")
sys.path.insert(0, "/home/raver1975/lean/factor-scratch/r48/_shared")

from harness import (FbTest, hunt, kernel_diagnostics, null_rate, predicted,  # noqa
                     skew, pow_counted, selftest)
from exp_batch import psi_exact, psi_selftest, density                      # noqa
from stange import (factor_base, bbound_for_b, gen_semiprime, factor_from_multiple,
                    kernel_basis, primitive, build_M, order_mod_n)            # noqa


def prereg():
    print(__doc__.split("======")[1].join(["PREREGISTERED PREDICTIONS\n", "====="]))


# ---------------------------------------------------------------------------
# Part A -- rate and COST per relation, by sampler
# ---------------------------------------------------------------------------

def part_A(bits_ladder=(26, 33), b=12, need=30, seeds=(810001, 810002, 810003),
           cap=20_000_000):
    print("=" * 84)
    print(f"PART A -- smoothness rate and COST per relation, b={b}")
    print("=" * 84)
    print("  NULL = exact Psi(2^bits, B)/2^bits (NOT Dickman: at u=5..8 rho is ~5-9x")
    print("  low, see harness ST3b).  ops = modular multiplications + FB reductions.")
    print()
    print(f"{'bits':>5} {'sampler':>12} {'rels':>5} {'trials/rel':>11} {'1/dens':>10} "
          f"{'mults/rel':>11} {'smops/rel':>10} {'ops/rel':>11} {'S':>6} {'flag':>7}")
    results = {}
    for bits in bits_ladder:
        agg, dens = {}, None
        for sd in seeds:
            rng = random.Random(sd)
            n, p, q = gen_semiprime(bits, rng)
            BB = bbound_for_b(b)
            FB = factor_base(BB, n)
            g = 2
            dens, _ = density(n, FB)
            for sname, kw in (("random", {}),
                              ("stride", dict(x0=n // 4,
                                              stride=random.Random(sd + 2).randrange(
                                                  n // 4, n // 2) | 1)),
                              ("seq", dict())):
                h = hunt(n, g, FB, need, random.Random(sd + 3), sname, cap=cap, **kw)
                if len(h["rels"]) < 5:
                    print(f"  !! {sname} stalled at bits={bits} "
                          f"({len(h['rels'])} rels in {h['trials']:,} trials)")
                    continue
                a = agg.setdefault(sname, {"rel": 0, "tr": 0, "mu": 0, "so": 0})
                a["rel"] += len(h["rels"])
                a["tr"] += h["trials"]
                a["mu"] += h["mults"]
                a["so"] += h["smoothops"]
        for key, a in agg.items():
            tpr = a["tr"] / a["rel"]
            mpr = a["mu"] / a["rel"]
            spr = a["so"] / a["rel"]
            opr = mpr + spr
            S = skew(tpr, dens)
            flag = "DEGEN" if S < 0.7 else ("ok" if S <= 1.5 else "RICH")
            print(f"{bits:>5} {key:>12} {a['rel']:>5} {tpr:>11.1f} {1/dens:>10.1f} "
                  f"{mpr:>11.1f} {spr:>10.1f} {opr:>11.1f} {S:>6.2f} {flag:>7}")
            results[(bits, key)] = {"tpr": tpr, "mpr": mpr, "spr": spr, "opr": opr,
                                    "S": S, "null": dens, "rel": a["rel"]}
        if (bits, "random") in results and (bits, "stride") in results:
            r, s_ = results[(bits, "random")], results[(bits, "stride")]
            print(f"{'':>5} {'==> SAVING':>12} {'':>5} {'':>11} {'':>10} "
                  f"{r['opr']/s_['opr']:>10.2f}x {'':>10} {r['opr']/s_['opr']:>10.2f}x"
                  f"   (random ops/rel / stride ops/rel)")
        print()
    return results


def part_A40(b=12, need=12, seeds=(811001, 811002), cap=60_000_000):
    """The 2^40 row separately: the relation-finding cost is the bottleneck."""
    bits = 40
    print("=" * 84)
    print(f"PART A(40) -- n ~ 2^40, b={b}, only {need} relations per seed "
          f"(the density makes this expensive)")
    print("=" * 84)
    agg = {}
    dens = None
    for sd in seeds:
        rng = random.Random(sd)
        n, p, q = gen_semiprime(bits, rng)
        BB = bbound_for_b(b)
        FB = factor_base(BB, n)
        g = 2
        dens, _ = density(n, FB)
        for sname, kw in (("random", {}),
                          ("stride", dict(x0=n // 4,
                                          stride=random.Random(sd + 2).randrange(
                                              n // 4, n // 2) | 1))):
            t0 = time.perf_counter()
            h = hunt(n, g, FB, need, random.Random(sd + 3), sname, cap=cap, **kw)
            a = agg.setdefault(sname, {"rel": 0, "tr": 0, "mu": 0, "so": 0, "w": 0.0})
            a["rel"] += len(h["rels"])
            a["tr"] += h["trials"]
            a["mu"] += h["mults"]
            a["so"] += h["smoothops"]
            a["w"] += time.perf_counter() - t0
            print(f"    seed {sd} [{sname}] {len(h['rels'])} rels in "
                  f"{h['trials']:,} trials ({time.perf_counter()-t0:.0f}s)")
    print()
    print(f"{'sampler':>12} {'rels':>5} {'trials/rel':>11} {'1/dens':>10} "
          f"{'mults/rel':>12} {'smops/rel':>10} {'ops/rel':>12} {'S':>6} {'secs':>7}")
    for key, a in agg.items():
        tpr = a["tr"] / a["rel"]
        mpr = a["mu"] / a["rel"]
        spr = a["so"] / a["rel"]
        opr = mpr + spr
        S = skew(tpr, dens)
        flag = "DEGEN" if S < 0.7 else ("ok" if S <= 1.5 else "RICH")
        print(f"{key:>12} {a['rel']:>5} {tpr:>11.1f} {1/dens:>10.1f} {mpr:>12.1f} "
              f"{spr:>10.1f} {opr:>12.1f} {S:>6.2f} {a['w']:>7.0f}  {flag}")
    if "random" in agg and "stride" in agg:
        r, s_ = agg["random"], agg["stride"]
        ro = r["mu"] / r["rel"] + r["so"] / r["rel"]
        so = s_["mu"] / s_["rel"] + s_["so"] / s_["rel"]
        print()
        print(f"  ==> SAVING: mults {r['mu']/r['rel'] / (s_['mu']/s_['rel']):.2f}x, "
              f"ops {ro/so:.2f}x, wall {r['w']/s_['w']:.2f}x")
    print()
    return agg


# ---------------------------------------------------------------------------
# Part B -- the two degeneracy axes on REAL relation sets
# ---------------------------------------------------------------------------

def part_B(bits=36, b=12, c=6, n_inst=8):
    print("=" * 78)
    print(f"PART B -- degeneracy panel on real relation sets "
          f"(n~2^{bits}, b={b}, c={c}, {n_inst} fresh instances)")
    print("=" * 78)
    print(f"{'sampler':>12} {'rank<b':>7} {'zero_frac':>10} {'all_zero':>9} "
          f"{'G/ord(g)':>10} {'rel':>4}")
    out = {}
    for sname in ("random", "stride", "seq", "squares"):
        zb = zf = az = 0.0
        tot_zero = tot_all = tot_n = 0
        gs = []
        for i in range(n_inst):
            sd = 820000 + i
            rng = random.Random(sd)
            n, p, q = gen_semiprime(bits, rng)
            BB = bbound_for_b(b)
            FB = factor_base(BB, n)
            g = 2
            kw = {}
            if sname == "stride":
                kw = dict(x0=n // 4,
                          stride=random.Random(sd + 7).randrange(n // 4, n // 2) | 1)
            h = hunt(n, g, FB, b + c, random.Random(sd + 11), sname,
                     cap=3_000_000, **kw)
            if len(h["rels"]) < b + c:
                continue
            dg = kernel_diagnostics(h["rels"], b, c)
            tot_n += 1
            if not dg["rank_full"]:
                zb += 1
            if dg["all_zero"]:
                tot_all += 1
            zf += dg["zero_frac"]
            og = order_mod_n(g, n, p, q)
            gs.append(0 if dg["G"] == 0 else dg["G"] // og if dg["G"] % og == 0 else -1)
            out.setdefault(sname, []).append(dg)
        if tot_n == 0:
            print(f"{sname:>12}      -- all instances stalled")
            continue
        good = sum(1 for v in gs if v == 1)
        print(f"{sname:>12} {zb:>3}/{tot_n:<3} {zf/tot_n:>10.3f} "
              f"{tot_all:>4}/{tot_n:<4} {good:>5}/{tot_n:<5} {tot_n:>4}")
    return out


# ---------------------------------------------------------------------------
# Part C -- END TO END.  Does it factor, and how many multiplications?
# ---------------------------------------------------------------------------

def attempt(n, p, q, g, FB, b, c, sampler, rng, kw=None, cap=6_000_000):
    """One full Algorithm-2.2 attempt.  Returns dict with factor and COUNTS."""
    t0 = time.perf_counter()
    h = hunt(n, g, FB, b + c, rng, sampler, cap=cap, **(kw or {}))
    rels = h["rels"]
    if len(rels) < b + c:
        return {"factor": None, "stalled": True, "mults": h["mults"],
                "trials": h["trials"], "smoothops": h["smoothops"],
                "secs": time.perf_counter() - t0, "relations": len(rels)}
    Mrows = build_M(rels, b)
    K, rank = kernel_basis(Mrows)
    xs = [rels[j][1] for j in range(len(rels))]
    cc = min(c, len(K))
    betas = [sum(primitive(v)[j] * xs[j] for j in range(len(rels))) for v in K[:cc]]
    G = 0
    for a in betas:
        from math import gcd
        G = gcd(G, abs(a))
    fac = factor_from_multiple(G, g, n) if G else None
    return {"factor": fac, "G": G, "rank": rank, "dimK": len(K),
            "mults": h["mults"], "trials": h["trials"], "smoothops": h["smoothops"],
            "ops": h["mults"] + h["smoothops"], "secs": time.perf_counter() - t0,
            "relations": len(rels)}


def part_C(bits=40, b=20, c=8, n_inst=6, seed0=830000):
    print("=" * 78)
    print(f"PART C -- END TO END (n~2^{bits}, b={b}, c={c}, bbound={bbound_for_b(b)}, "
          f"{n_inst} FRESH instances, seeds {seed0}+)")
    print("=" * 78)
    print("  'mults' counts modular multiplications to GENERATE all candidates;")
    print("  'smops' counts FB-smoothness reductions; 'ops' is the comparable sum.")
    print()
    tot = {}
    for sname in ("random", "stride"):
        got = 0
        M = T = S = TT = 0
        W = 0.0
        rows = []
        for i in range(n_inst):
            sd = seed0 + i
            rng = random.Random(sd)
            n, p, q = gen_semiprime(bits, rng)
            BB = bbound_for_b(b)
            FB = factor_base(BB, n)
            g = 2
            kw = {}
            if sname == "stride":
                kw = dict(x0=n // 4,
                          stride=random.Random(sd + 3).randrange(n // 4, n // 2) | 1)
            r = attempt(n, p, q, g, FB, b, c, sname, random.Random(sd + 5), kw)
            rows.append(r)
            if r.get("factor") in (p, q):
                got += 1
                M += r["mults"]; T += r["trials"]; S += r["smoothops"]
                TT += r["ops"]; W += r["secs"]
        tot[sname] = {"got": got, "mults": M, "smops": S, "ops": TT, "secs": W}
        print(f"  [{sname}] factors {got}/{n_inst}")
        for r in rows:
            print(f"      n=2^{r.get('relations', 0) and ''}"
                  f"rel={r['relations']:>3} trials={r['trials']:>8} "
                  f"mults={r['mults']:>9} smops={r['smoothops']:>8} "
                  f"ops={r['ops']:>9} rank={r.get('rank')} "
                  f"factor={'YES' if r.get('factor') in (p, q) else 'no'} "
                  f"{r['secs']:.1f}s")
        if got:
            print(f"      per SUCCESS: trials/attempt={T//got} mults/attempt={M//got} "
                  f"smops/attempt={S//got} ops/attempt={TT//got} wall={W/got:.1f}s")
        print()
    if tot["random"]["got"] and tot["stride"]["got"]:
        print(f"  ==> END-TO-END SAVING on ops/attempt: "
              f"{tot['random']['ops']/tot['stride']['ops']:.2f}x")
        print(f"  ==> END-TO-END SAVING on mults only: "
              f"{tot['random']['mults']/tot['stride']['mults']:.2f}x")
        print(f"  ==> wall-clock (python, includes the linear algebra): "
              f"{tot['random']['secs']/tot['stride']['secs']:.2f}x")
    return tot


if __name__ == "__main__":
    if not selftest():
        sys.exit(1)
    print()
    prereg()
    which = sys.argv[1] if len(sys.argv) > 1 else "ABC"
    if not psi_selftest():
        sys.exit(1)
    if "A" in which:
        part_A()
    if "4" in which:
        part_A40()
    if "B" in which:
        part_B()
    if "C" in which:
        part_C()
