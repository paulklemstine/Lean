"""
exp_s1.py -- S1/S2: does Result A's Jacobi conditioning transfer to the
NUMBER-FIELD side?

PREDICTIONS FIXED BEFORE MEASUREMENT
------------------------------------
The number-field analogue of Stange's success event
    v2(ord_p g) != v2(ord_q g)
is, for a base b, the same event with g -> b:
    k_p != k_q,     k_p = v2(ord_p b),  lam_p = v2(p-1) - k_p.

P1 (the transplant works at all).   Conditioning on Jacobi(b/n) = -1 raises
    P(k_p != k_q) from 20/27 = 0.7407 toward 8/9 = 0.8889, ratio 1.2x, on the
    NUMBER-FIELD base.  Same law, same per-cell shape, gain concentrated on
    the diagonal a == b.
    -- This is the thing being tested. If it fails, the transfer is dead and
       S2 has nothing to measure.

P2 (q = 1, by construction).  Jacobi(b/n) is a property of the BASE, chosen
    once per attempt.  It rejects no candidate from any search stream, so
    GAIN = s_C/s_0 exactly.  Shown in the q-table BEFORE the numbers.

P3 (Result C still bites).  The 2-adic coupling measured by Result C lives in
    the SEARCH variable a (V = a^2 - b^k).  Conditioning the BASE b cannot
    create coupling in the search variable.  Concretely: if we condition on b
    and then measure the CRT-independence of the search hit-set, the ratio
    must stay at 1.  If instead the conditioning *does* move that ratio, we
    would have beaten Result C -- which is why it is measured, not assumed.

⚠️ THE INSTRUMENT WAS BROKEN AND IS NOW FIXED.  See `order_mod` in core.py:
the inherited r52exp/design/dcore.py version returns `m` unchanged for every
input, so MM_design.md 3c's `ord_n(g)/n = 1.000` was a broken instrument, not
a property of Stange.  The fixed version agrees with sympy.n_order on 144/144.
This matters here because ord IS the quantity under test.
"""

from __future__ import annotations

import math
import random
import sys
from fractions import Fraction
from math import gcd

from core import (
    calibrate, gen_semiprime, has_power, jac_neg, jac_pos, jacobi, k_profile,
    order_mod, p_split, pooled, q_table, v2, write_json, z_binom,
)

# ==========================================================================
# 0.  THE q-TERM, BEFORE ANY MEASUREMENT
# ==========================================================================
print("=" * 74)
print("0.  THE q-TERM FIRST  (GAIN = (s_C/s_0) q / (1 + q c_cond/c_gen))")
print("=" * 74)
print(f"  {'arm':<42} {'rejects':>8} {'q':>6} {'best GAIN':>10}")
for r in q_table():
    print(f"  {r['arm']:<42} {r['rejects']:>8} {r['q']:>6.3f} {r['best_gain']:>10.3f}"
          f"   {r['note']}")
print()
print("  The Jacobi-on-b arm is LEGAL (q = 1).  So P2 is satisfied by algebra,")
print("  not by measurement -- exactly as for the Stange side.  Everything")
print("  below measures the ONE remaining unknown, s_C/s_0.")
print()

# ==========================================================================
# 1.  EXACT rates from the law, before touching any sample
# ==========================================================================
# Reuse II_baseg's derivation, re-implemented from scratch in Fraction
# arithmetic so the numbers are not copied -- a copied number inherits the
# other agent's possible error.  Cross-checked against `order_mod` measurement
# in section 2.

def lam_law(a: int):
    """P(lam = i) for i in 0..a  where a = v2(p-1).  P(i)=2^-(i+1), P(a)=2^-a."""
    out = {}
    for i in range(a):
        out[i] = Fraction(1, 2 ** (i + 1))
    out[a] = Fraction(1, 2 ** a)
    return out


def succ_uniform(a: int, b: int) -> Fraction:
    """P(k_p != k_q) under uniform b, cell (a, b) = (v2(p-1), v2(q-1))."""
    P = lam_law(a)
    Q = lam_law(b)
    tot = Fraction(0)
    for i, pi in P.items():
        for j, qj in Q.items():
            # k = s - lam ; success iff a - i != b - j
            if a - i != b - j:
                tot += pi * qj
    return tot


def succ_jacneg(a: int, b: int) -> Fraction:
    """P(k_p != k_q) under Jacobi(b/n) = -1.

    Jacobi = -1 forces (b/p)(b/q) = -1, i.e. exactly one of lam_p, lam_q is 0.
    On that branch k = s exactly; on the other, lam >= 1 so k = s - lam.
    """
    if a == b:
        return Fraction(1)      # both cannot be 0 -> disagreement is forced
    m = max(a, b)
    if m < 1:
        return Fraction(0)
    fail = Fraction(1, 2) * Fraction(1, 2 ** abs(a - b))
    return 1 - fail


TRUNC = 30          # cells a,b < TRUNC; dropped tail mass is 2^-(TRUNC-1)


def geom_mean(fn, upto: int = TRUNC) -> Fraction:
    """E over s ~ Geom(1/2) (the campaign's law for v2(p-1)).

    TRUNCATION IS REPORTED, NEVER SILENT.  Renormalising by the retained mass
    w < 1 biases the mean, so the error is bounded by the DROPPED TAIL MASS
    2^-(upto-1) instead and checked against the closed form.  At upto = 30 that
    bound is 1.9e-9, and the observed deviations from 20/27 and 8/9 are
    9.7e-10 and 4.1e-10 -- inside it.  At upto = 22 (my first choice) the error
    is 2.5e-7 and an assertion at 1e-9 fired: that was the truncation, not a
    wrong law, and the fix was to bound the error rather than loosen the test.
    """
    tot, w = Fraction(0), Fraction(0)
    for a in range(1, upto):
        for b in range(1, upto):
            wgt = Fraction(1, 2 ** a) * Fraction(1, 2 ** b)
            tot += wgt * fn(a, b)
            w += wgt
    return tot / w


print("=" * 74)
print("1.  EXACT RATES FROM THE LAW (Rational arithmetic, re-derived here)")
print("=" * 74)
S0 = geom_mean(succ_uniform)
S1 = geom_mean(succ_jacneg)
print(f"  uniform b   S0 = {float(S0):.6f}   (20/27 = {20/27:.6f})")
print(f"  jac_neg b   S1 = {float(S1):.6f}   ( 8/9 = {8/9:.6f})")
print(f"  ratio           {float(S1/S0):.6f}   (12/10 = {12/10:.6f})")
TAIL = 2.0 ** -(TRUNC - 1)
e0, e1 = abs(float(S0) - 20 / 27), abs(float(S1) - 8 / 9)
print(f"  truncation at a,b < {TRUNC}: dropped tail mass 2^-{TRUNC-1} = {TAIL:.2e}")
print(f"  deviation from 20/27 = {e0:.2e}   from 8/9 = {e1:.2e}   both inside the bound")
assert e0 < TAIL, f"uniform law off by {e0} > tail {TAIL}"
assert e1 < TAIL, f"jac_neg law off by {e1} > tail {TAIL}"
print("  [PASS] both reproduce the recorded constants to within the truncation bound")
print()

print("  per-cell (the gain is ON THE DIAGONAL, and it LOSES off it):")
print(f"  {'a,b':>6} {'uniform':>9} {'jac_neg':>9} {'delta':>9}")
for a, b in [(1, 1), (2, 2), (3, 3), (4, 4), (2, 3), (3, 4), (1, 2), (2, 4)]:
    u, j = float(succ_uniform(a, b)), float(succ_jacneg(a, b))
    print(f"  {str((a,b)):>6} {u:9.4f} {j:9.4f} {j-u:+9.4f}")
print()

# ==========================================================================
# 2.  MEASUREMENT, with per-modulus 2-adic reporting and a calibration first
# ==========================================================================

def run_order_step(n_mod: int, trials: int, bits: int, seed: int):
    """Measure P(k_p != k_q) on the number-field base, per rule, per cell."""
    rng = random.Random(seed)
    per_cell = {}       # cell -> {rule: [hits, n]}
    for _ in range(n_mod):
        r = gen_semiprime(bits, rng)
        if r is None:
            continue
        n, p, q = r
        assert p * q == n
        cell = p_split(p, q)
        d = per_cell.setdefault(cell, {"uniform": [0, 0], "jac_neg": [0, 0]})
        for _ in range(trials):
            # RULE 1: uniform base
            b = rng.randrange(2, n)
            if gcd(b, n) == 1:
                kp = k_profile(b, p, q)
                if kp:
                    d["uniform"][1] += 1
                    d["uniform"][0] += int(kp[0] != kp[1])
            # RULE 2: base chosen with Jacobi(b/n) = -1
            for _ in range(64):                      # bounded rejection
                b = rng.randrange(2, n)
                if gcd(b, n) == 1 and jac_neg(b, n):
                    break
            else:
                continue
            kp = k_profile(b, p, q)
            if kp:
                d["jac_neg"][1] += 1
                d["jac_neg"][0] += int(kp[0] != kp[1])
    return per_cell


def flat_rate(per_cell, rule):
    """Instrument-calibration helper: one number per cell so swings are visible."""
    return {str(c): (v[rule][0] / v[rule][1]) for c, v in per_cell.items()
            if v[rule][1] > 0}


print("=" * 74)
print("2.  INSTRUMENT CALIBRATION -- identical input, fixed seeds, run twice")
print("=" * 74)
CAL = calibrate(lambda seed: flat_rate(run_order_step(30, 20, 26, seed=seed), "jac_neg"))
print(f"  cells compared : {CAL['n_cells']}")
print(f"  max cell swing : {CAL['max_swing_pct']:.4f}%   identical = {CAL['identical']}")
print("  (Round 51's agent measured +22% on identical input; round 52's 0.00%.)")
print("  Every rate below is quoted only after this check.")
print()

print("=" * 74)
print("3.  THE ORDER STEP ON THE NUMBER-FIELD BASE  (P1)")
print("=" * 74)
PER_CELL = run_order_step(150, 40, 26, seed=99991)

print(f"  {'cell (a,b)':>12} {'v2(n-1)':>8} {'N_mod':>6} | "
      f"{'unif pred':>9} {'unif obs':>9} {'z':>6} | {'jac pred':>8} {'jac obs':>8} {'z':>7}")
rows = []
for cell in sorted(PER_CELL):
    d = PER_CELL[cell]
    if d["uniform"][1] < 100:
        continue
    a, b_ = cell
    pu, pj = float(succ_uniform(a, b_)), float(succ_jacneg(a, b_))
    ou, nu = d["uniform"]
    oj, nj = d["jac_neg"]
    zu = z_binom(ou, nu, pu)
    zj = ("n/a" if pj >= 1.0 else f"{z_binom(oj, nj, pj):+.2f}")
    v2n = v2(2 ** 26 - 1)
    print(f"  {str(cell):>12} {'-':>8} {'-':>6} | {pu:9.4f} {ou/nu:9.4f} {zu:+6.2f} | "
          f"{pj:8.4f} {oj/nj:8.4f} {zj:>7}")
    rows.append(dict(cell=cell, n_u=nu, k_u=ou, pred_u=pu,
                     n_j=nj, k_j=oj, pred_j=pj))

print()
print("  POOLED (with the between-cell sd, never a pooled average alone):")
for rule, key, nkey in (("uniform", "k_u", "n_u"), ("jac_neg", "k_j", "n_j")):
    cells = [(r[key], r[nkey]) for r in rows]
    p_, m_, sd = pooled(cells)
    print(f"  {rule:>9}: pooled {p_:.4f}   mean-of-cells {m_:.4f}   between-cell sd {sd:.4f}"
          f"   N = {sum(n for _, n in cells)}")
pu_all = pooled([(r["k_u"], r["n_u"]) for r in rows])[0]
pj_all = pooled([(r["k_j"], r["n_j"]) for r in rows])[0]
print(f"  RATIO pooled jac_neg/uniform = {pj_all/pu_all:.4f}   (theory 12/10 = 1.2000)")
print(f"  N = {sum(r['n_u'] for r in rows)} per rule; cells = {len(rows)}")
print()

# ==========================================================================
# 4.  RESULT C: does conditioning the BASE create coupling in the SEARCH?
# ==========================================================================
# Result C measured P(p|V) P(q|V) = P(n|V) for V = a^2 - b^k under UNIFORM b.
# The objection is that conditioning b does not change this.  Measure it under
# BOTH rules, with the same harness and the same CRT-exact sampling.
# If conditioning b moved the ratio, we would have a construction that
# escapes Result C -- so this must be measured, not assumed.

def crt_ratio(n: int, p: int, q: int, b: int, trials: int, seed: int):
    """ratio = [P(p|V)P(q|V)] / P(n|V) with V = a^2 - b^3, CRT-exact sampling.

    Sampling is over a UNIFORM in [0,n) and b FIXED -- the exact regime in which
    P(p|V)P(q|V) = P(n|V) is a theorem by CRT.  Round 52's +4.5 sigma came from
    cycling b through 60 of p's 128 residues, which is a BIASED null.
    """
    rng = random.Random(seed)
    b3 = pow(b, 3, n)
    hit_p = hit_q = hit_n = 0
    for _ in range(trials):
        a = rng.randrange(0, n)
        v = (a * a - b3) % n
        hp, hq = (v % p == 0), (v % q == 0)
        hit_p += hp
        hit_q += hq
        hit_n += (v == 0)
    pp, pq, pn = hit_p / trials, hit_q / trials, hit_n / trials
    if pn == 0 or pp == 0 or pq == 0:
        return None
    return (pp * pq) / pn, trials * pn


print("=" * 74)
print("4.  RESULT C ON THE NUMBER-FIELD SIDE, under BOTH rules  (P3)")
print("=" * 74)
print(f"  {'bits':>5} {'rule':>9} {'moduli':>7} {'trials':>10} {'ratio':>7} {'z':>6} "
      f"{'E[hits]':>9} {'power':>6}")
crt_rows = []
for bits in (12, 13, 14, 15):
    for rule in ("uniform", "jac_neg"):
        acc, trials_tot, mods = 0.0, 0, 0
        rng = random.Random(4242 + bits)
        per_size_hits = 0.0
        # Enough moduli that a conditioned base is always findable.  The first
        # version asked for 4 moduli and collected 2-3, and the `jac_neg` arm
        # produced NO rows at all -- it was the DECISIVE section and it was
        # silently empty.  Under-powered rows are the round-52 failure mode and
        # they do not announce themselves; they just print nothing.
        for _ in range(12):
            r = gen_semiprime(bits, rng)
            if r is None:
                continue
            n, p, q = r
            assert p * q == n
            for _ in range(3):
                if rule == "jac_neg":
                    found = False
                    for _ in range(256):        # bounded, generous
                        b = rng.randrange(2, n)
                        if gcd(b, n) == 1 and jac_neg(b, n):
                            found = True
                            break
                    if not found:
                        continue
                else:
                    b = rng.randrange(2, n)
                    if gcd(b, n) != 1:
                        continue
                got = crt_ratio(n, p, q, b, 60000, seed=rng.randrange(10**6))
                if got:
                    acc += got[0]
                    per_size_hits += got[1]
                    trials_tot += 60000
                    mods += 1
        if mods == 0:
            print(f"  {bits:5d} {rule:>9} {'--':>7} {'--':>10} {'--':>7} {'--':>6} "
                  f"{'--':>9} {'EMPTY':>6}")
            crt_rows.append(dict(bits=bits, rule=rule, ratio=None,
                                 note="no conditioned base found -- EXCLUDED"))
            continue
        ratio = acc / mods
        exp_hits = per_size_hits / mods
        z = (ratio - 1) * (exp_hits ** 0.5) if exp_hits > 0 else float("nan")
        ok = has_power(exp_hits)
        print(f"  {bits:5d} {rule:>9} {mods:7d} {trials_tot:10d} {ratio:7.3f} {z:+6.2f} "
              f"{exp_hits:9.1f} {'YES' if ok else 'NO':>6}")
        crt_rows.append(dict(bits=bits, rule=rule, ratio=ratio, z=z,
                             exp_hits=exp_hits, power=ok, n_moduli=mods))
print()
print("  Predicted by CRT EXACTLY: ratio = 1.000 for every row, under BOTH rules.")
print("  A conditioned base that moved this ratio would be a construction")
print("  escaping Result C.  Read the two jac_neg rows against 1.000.")
print()

# ==========================================================================
# 5.  THE 2-ADIC PROFILE -- per modulus, never pooled
# ==========================================================================
print("=" * 74)
print("5.  PER-MODULUS 2-ADIC PROFILE (p_split), not a pooled average")
print("=" * 74)
rng = random.Random(777)
prof = {}
for _ in range(120):
    r = gen_semiprime(26, rng)
    if r is None:
        continue
    n, p, q = r
    cell = p_split(p, q)
    d = prof.setdefault(cell, [0, 0])
    for _ in range(40):
        for _ in range(64):
            b = rng.randrange(2, n)
            if gcd(b, n) == 1 and jac_neg(b, n):
                break
        else:
            continue
        kp = k_profile(b, p, q)
        if kp:
            d[1] += 1
            d[0] += int(kp[0] != kp[1])
print(f"  {'cell (a,b)':>12} {'N':>8} {'P(k_p!=k_q) | jac_neg':>24} {'exact pred':>11}")
for cell in sorted(prof):
    k, n_ = prof[cell]
    if n_ < 200:
        continue
    pred = float(succ_jacneg(*cell))
    print(f"  {str(cell):>12} {n_:8d} {k/n_:24.4f} {pred:11.4f}")
print()
print("  Cells where the prediction spans a wide range are where a pooled rate")
print("  would be hiding the most.  The diagonal predicts 1.0000 exactly.")
print()

write_json("s1.json", dict(
    S0=float(S0), S1=float(S1), ratio=float(S1 / S0),
    calibration=CAL,
    cells=rows,
    crt=crt_rows,
    q_table=q_table(),
))
print("wrote results/s1.json")
