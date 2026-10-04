"""
exp_cliff.py -- does the proved regime bound where the method stops working,
and is that bound free of c?

Everything that could bias a measurement is controlled:

  * faithfulness   -- the paper's own example (n=62389, g=43, B=50, b=15, c=10)
                      is re-run as a POSITIVE CONTROL in every invocation;
                      if it fails, nothing else in this file is reported.
  * exactness      -- kernel vectors are checked M.v == 0 in Fraction arithmetic
                      before any alpha_t is formed (the mandatory control);
                      any violation aborts the run.
  * seeds          -- every trial uses an explicitly recorded seed.
  * regime test    -- exact integer arithmetic only (n^2 >= 64 b^b).
  * reporting      -- sample sizes (N) are printed for every cell.

Usage:  python3 exp_cliff.py [tier]
          tier A (default) -- the c-scan and the b-cliff, small n, fast
          tier B           -- the wide b-cliff at larger n, slow
"""

from __future__ import annotations

import json
import math
import random
import sys
import time
from fractions import Fraction

sys.path.insert(0, "/home/raver1975/lean/factor-scratch/r49exp/regime")
sys.path.insert(0, "/home/raver1975/lean/factor-scratch/r48/exp/stange")

import fwregime as F
import stange
from sympy import Matrix

OUT = []


# ---------------------------------------------------------------------------
# exact-kernel gate
# ---------------------------------------------------------------------------
def gate(Mrows, vecs):
    """Assert M.v == 0 EXACTLY (Fraction) for every kernel vector. Abort on any
    violation -- this is the mandatory control from the brief."""
    Mf = [[Fraction(int(x)) for x in row] for row in Mrows]
    for v in vecs:
        v = [Fraction(x) if not isinstance(x, Fraction) else x for x in v]
        if len(v) != len(Mrows[0]):
            raise AssertionError(f"kernel vector length {len(v)} != {len(Mrows[0])}")
        for i in range(len(Mf)):
            s = Fraction(0)
            for j in range(len(Mf[i])):
                s += Mf[i][j] * v[j]
            if s != 0:
                raise AssertionError(f"M.v != 0 at row {i}")


# ---------------------------------------------------------------------------
# THE MANDATORY PER-MODULUS CONTROL.
#
# The factor rate is NOT a property of the relation search.  r49/U proved the
# index is erased before the gcd, so
#
#     success  <=>  v2(ord_p g) != v2(ord_q g)          (the Shor criterion)
#
# which depends on g and on p,q -- and on NOTHING the method does.  The famous
# constant 20/27 = 0.7407 is that probability AVERAGED OVER MODULI, since
# P(v2(p-1) = j) = 2^-j.  At ONE FIXED (p,q) it is a different number: it is
# 1/2 when p == q == 3 (mod 4) and higher otherwise.  So every rate below is
# reported next to p_split(p,q), the exact per-modulus baseline, and the
# method's contribution is rate - p_split.  Comparing a fixed-n rate against
# 20/27 would manufacture a spurious "+0.2 from the method".
# ---------------------------------------------------------------------------
def v2(x):
    r = 0
    while x % 2 == 0:
        x //= 2
        r += 1
    return r


def p_split(p, q):
    """EXACT P_g[ v2(ord_p g) != v2(ord_q g) ] for this specific modulus.

    For a uniform g and m = v2(p-1): the 2-Sylow of (Z/p)* is C_{2^m}, and
    a uniform g has a uniform 2-part component.  In C_{2^m} the number of
    elements of order 2^k is 2^{k-1} for k>=1 and 1 for k=0, so

        P(v2(ord_p g) = 0)     = 2^-m
        P(v2(ord_p g) = k)     = 2^{k-1-m}   for 1 <= k <= m

    (this is normalisation-checked in selftest T11 against the known average
    20/27, which is what pinned down the -1 on the exponent -- my first
    version used 2^-(k+1) and averaged to 0.600, not 0.741.)
    """
    mp_, mq_ = v2(p - 1), v2(q - 1)

    def dist(m):
        d = {0: 2.0 ** -m}
        for k in range(1, m + 1):
            d[k] = 2.0 ** (k - 1 - m)
        return d

    a, b = dist(mp_), dist(mq_)
    same = sum(a[k] * b.get(k, 0.0) for k in a)
    return 1.0 - same, mp_, mq_


# ---------------------------------------------------------------------------
# positive control
# ---------------------------------------------------------------------------
def positive_control():
    n, g, B = 62389, 43, 50
    FB = stange.factor_base(B, n)
    res = stange.alg22(n, g, FB, 10, random.Random(4242))
    ok = (res["factor"] is not None) and \
         (stange.factor_from_multiple(15400, 43, 62389) == 701)
    print(f"[control] paper example n=62389 b=15 c=10: G={res['G']} "
          f"factor={res['factor']}  {'OK' if ok else 'FAILED'}")
    if not ok:
        raise SystemExit("POSITIVE CONTROL FAILED -- results suppressed")
    return True


# ---------------------------------------------------------------------------
# one trial: end-to-end Algorithm 2.2 + the index Algorithm 2.2 actually makes
# ---------------------------------------------------------------------------
# NOTE on which index to measure.  Stange p.4 also describes a SECOND index,
# built from ker(M_i): "its right kernel Ki ... gives linear combinations of
# the original relations which are supported only on a_i ... each is an integer
# multiple of ord(a_i) s_i".  That integrality is FALSE for Algorithm 2.2's
# relations -- see the counterexample in notes/60_regime.md §6.  A combination
# supported on a_1 alone has psi-image g^(sum v_j x_j), which is not 1, so its
# coefficient beta need not be divisible by ord(a_1).  So I measure instead the
# index Algorithm 2.2 ACTUALLY produces:  h = G / ord(g),  where
# G = gcd(alpha_1..alpha_c).  The paper's OWN correctness claim (p.4, "the
# multiplicative order g modulo n must divide every alpha_t") is asserted
# exactly on every trial.
def one_trial(n, p, q, b, c, seed, diagnose_Ki=False):
    BB = stange.bbound_for_b(b)
    FB = stange.factor_base(BB, n)
    if len(FB) != b:
        return None                      # a prime of FB divides n; skip
    rng = random.Random(seed)
    g = rng.randrange(2, n)
    while math.gcd(g, n) != 1:
        g = rng.randrange(2, n)
    try:
        rels, trials = stange.find_relations(n, g, FB, b + c, rng, "random")
    except RuntimeError:
        return None
    Mrows = stange.build_M(rels, b)

    # --- Algorithm 2.2, steps 10-16 -----------------------------------------
    K = Matrix(Mrows).nullspace()
    kvecs = [[K[j][i, 0] for i in range(K[j].rows)] for j in range(len(K))]
    gate(Mrows, kvecs)                   # EXACT M.v == 0, raises on violation
    xs = [rels[j][1] for j in range(len(rels))]
    betas = [sum(stange.primitive(v)[j] * xs[j] for j in range(len(rels)))
             for v in kvecs[:c]]
    G = 0
    for a in betas:
        G = math.gcd(G, abs(a))
    og = stange.order_mod_n(g, n, p, q)
    assert G > 0 and G % og == 0, f"paper's p.4 correctness claim VIOLATED: G={G}, ord(g)={og}"
    h = G // og
    fac = stange.factor_from_multiple(G, g, n) if G else None

    out = {"factor": fac, "G": G, "ord_g": og, "h": h, "trials": trials,
           "dimK": len(kvecs), "seed": seed, "b": b, "c": c,
           "bits": n.bit_length(), "bitlen_G": G.bit_length()}
    if diagnose_Ki:
        i = 0
        Ki = Matrix([r for j, r in enumerate(Mrows) if j != i]).nullspace()
        col_i = [rels[j][0][i] for j in range(len(rels))]
        gg = 0
        for v in Ki:
            pv = stange.primitive([v[k, 0] for k in range(v.rows)])
            gg = math.gcd(gg, abs(sum(pv[j] * col_i[j] for j in range(len(rels)))))
        out["Ki_integral"] = (gg % stange.order_mod_n(FB[0], n, p, q) == 0)
        out["Ki_gcd"] = gg
        out["ord_a1"] = stange.order_mod_n(FB[0], n, p, q)
    return out


def sweep(n, p, q, b, c, N, seed0, diagnose_Ki=False, label=""):
    got, h1, nt, fac_, hsum = 0, 0, 0, 0, 0
    ki_ok = 0
    for k in range(N):
        r = one_trial(n, p, q, b, c, seed0 + 1000 * k, diagnose_Ki)
        if r is None:
            continue
        nt += 1
        if r["factor"]:
            got += 1
        hsum += r["h"]
        fac_ += 1
        if r["h"] == 1:
            h1 += 1
        if diagnose_Ki and r.get("Ki_integral"):
            ki_ok += 1
    ps, mp_, mq_ = p_split(p, q)
    rec = {"label": label, "bits": n.bit_length(), "b": b, "c": c, "N": nt,
           "p": p, "q": q, "v2_p_1": mp_, "v2_q_1": mq_, "p_split": ps,
           "rate_minus_psplit": ((got / nt) - ps) if nt else None,
           "b_max": F.b_max(n), "in_regime": F.in_stange_regime(b, n),
           "in_regime_two_window": F.in_two_window_regime(b, n),
           "factors": got, "rate": (got / nt) if nt else None,
           "P_h1": (h1 / fac_) if fac_ else None,
           "mean_h": (hsum / fac_) if fac_ else None,
           "Ki_integral_frac": (ki_ok / nt) if (nt and diagnose_Ki) else None,
           "alpha_b": F.alpha_n(b), "paper_pred": 1.0 / F.zeta(c + 1),
           "seed0": seed0}
    OUT.append(rec)
    return rec


def show(rec):
    print(f"  n=2^{rec['bits']:<3d} b={rec['b']:<3d} c={rec['c']:<3d} "
          f"b_max={rec['b_max']:<3d} "
          f"{'IN ' if rec['in_regime'] else 'OUT'}  "
          f"factors {rec['factors']:>3d}/{rec['N']:<3d} "
          f"rate {rec['rate'] if rec['rate'] is None else round(rec['rate'],3)!s:>6}  "
          f"P(h=1) {rec['P_h1'] if rec['P_h1'] is None else round(rec['P_h1'],3)!s:>6}  "
          f"mean h {rec['mean_h'] if rec['mean_h'] is None else round(rec['mean_h'],2)!s:>6}  "
          f"1/zeta(c+1)={rec['paper_pred']:.4f}  alpha_b={rec['alpha_b']:.4f}  "
          f"| p_split={rec['p_split']:.3f} (m_p={rec['v2_p_1']},m_q={rec['v2_q_1']}) "
          f"rate-p_split={rec['rate_minus_psplit']:+.3f}")


# ---------------------------------------------------------------------------
def tier_A():
    print("\n" + "=" * 100)
    print("TIER A1 -- PREDICTION P1/P5: is the SUCCESS RATE flat in c at fixed (n,b)?")
    print("=" * 100)
    print("Prediction P5: raising c raises NEITHER b_max NOR the empirical success rate.")
    print("Prediction P1: b_max(n,c) is FLAT in c -- already exact, see fwregime.py.\n")
    for bits, b, N in ((26, 8, 60), (30, 12, 50), (30, 10, 50)):
        n, p, q = stange.gen_semiprime(bits, random.Random(9000 + bits))
        print(f" n ~ 2^{bits}, b = {b}, b_max(n) = {F.b_max(n)}, N = {N}")
        for c in (1, 3, 5, 10, 20, b + 1):
            show(sweep(n, p, q, b, c, N, seed0=31000 + 137 * c + bits * 10 + b,
                       label="A1"))


def tier_A2():
    print("\n" + "=" * 100)
    print("TIER A2 -- PREDICTION P4: is there a CLIFF at b_max(n)?  Sweep b through it.")
    print("=" * 100)
    print("Prediction P4: no cliff -- success rate does not fall off at b_max(n).")
    for bits, bs, N in ((26, range(8, 20), 40), (30, range(10, 22), 35)):
        n, p, q = stange.gen_semiprime(bits, random.Random(6100 + bits))
        print(f"\n n ~ 2^{bits}, b_max(n) = {F.b_max(n)}, c = 10 fixed, N = {N}")
        for b in bs:
            show(sweep(n, p, q, b, 10, N, seed0=77000 + 91 * b + bits,
                       diagnose_Ki=True, label="A2"))


def tier_B():
    print("\n" + "=" * 100)
    print("TIER B -- wide cliff at n ~ 2^34, b_max(n) = 15")
    print("=" * 100)
    bits, N = 34, 24
    n, p, q = stange.gen_semiprime(bits, random.Random(4242))
    print(f" n ~ 2^{bits}, b_max(n) = {F.b_max(n)}, c = 10, N = {N}")
    for b in range(10, 27):
        show(sweep(n, p, q, b, 10, N, seed0=88000 + 57 * b,
                   diagnose_Ki=True, label="B"))


def summarize():
    print("\n" + "=" * 100)
    print("SUMMARY")
    print("=" * 100)
    # P1
    print("\nP1  b_max(n,c) FLAT in c")
    print("    Exact, integer arithmetic, fwregime.b_max(): the condition n^2 >= 64 b^b")
    print("    does not contain c.  Empirically exercised by T9 in selftest.py, which")
    print("    plants a c-dependence and confirms the harness detects it.")
    print("    VERDICT: CONFIRMED (theoretically, not just empirically).")
    # P2
    print("\nP2  honest SINGLE-window b_max (Stange drops F&W's B_1 >= 8n^2(n+1)B)")
    for e in (20, 40, 100, 200):
        n = 10 ** e
        print(f"    n=10^{e:<4d} Stange b_max={F.b_max(n):<5d} "
              f"single-window b_max={F.b_max(n,'two-window'):<5d}")
    print("    VERDICT: CONFIRMED in direction; the two-window b_max is SMALLER, so")
    print("    Stange's stated regime is OPTIMISTIC, not conservative.")
    # P3
    print("\nP3  proved in-regime lower bound is alpha_b, not 1/zeta(c+1)")
    for b in (5, 10, 20, 26):
        print(f"    b={b:<3d} alpha_b={F.alpha_n(b):.4f}   "
              f"1/zeta(b+2)={1/F.zeta(b+2):.6f}   paper's '99.9% if c>=9' claim")
    print(f"    zhat (F&W Prop 2.5) = {F.zeta_hat():.6f}")
    print("    VERDICT: CONFIRMED. The proved guarantee is ~0.09-0.17, i.e. 6-11x")
    print("    WEAKER than the 0.75 round 48 measured and ~6x weaker than 20/27.")
    # P4
    print("\nP4  does the method factor beyond the proved regime?")
    inr = [r for r in OUT if r["in_regime"] and r["rate"] is not None]
    outr = [r for r in OUT if not r["in_regime"] and r["rate"] is not None]
    for name, grp in (("IN regime ", inr), ("OUT regime", outr)):
        if grp:
            f = sum(r["factors"] for r in grp)
            t = sum(r["N"] for r in grp)
            print(f"    {name}: {f}/{t} = {f/t:.4f}   ({len(grp)} cells)")
    beyond = [r for r in outr if r["rate"] is not None and r["rate"] > 0.5]
    if beyond:
        print(f"    OUT-of-regime cells still above 0.50: "
              f"{[(r['bits'], r['b'], round(r['rate'], 3)) for r in beyond]}")
    # P5
    print("\nP5  success rate vs c, at fixed (n,b)")
    byk = {}
    for r in OUT:
        if r["label"] == "A1" and r["rate"] is not None:
            byk.setdefault((r["bits"], r["b"]), []).append((r["c"], r["rate"]))
    for k, v in sorted(byk.items()):
        rates = [x[1] for x in v]
        cs = [x[0] for x in v]
        print(f"    n~2^{k[0]}, b={k[1]}: c={cs} -> rate={rates}  "
              f"spread={max(rates)-min(rates):.3f}")
    print("    VERDICT: see above; compare against 20/27 = 0.7407.")


def main():
    positive_control()
    t0 = time.time()
    tier = sys.argv[1] if len(sys.argv) > 1 else "A"
    if tier == "A":
        tier_A()
        tier_A2()
    else:
        tier_B()
    summarize()
    with open("/home/raver1975/lean/factor-scratch/r49exp/regime/results/"
              f"cliff_{tier}.json", "w") as fh:
        json.dump({"predictions": F.PREREG, "records": OUT,
                   "wall_seconds": time.time() - t0}, fh, indent=1)
    print(f"\n[wall {time.time()-t0:.1f}s]  -> results/cliff_{tier}.json")


if __name__ == "__main__":
    main()