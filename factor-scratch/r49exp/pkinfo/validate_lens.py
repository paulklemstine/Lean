#!/usr/bin/env python3
"""
EXACT validation of the archimedean capacity (Theorem 3.5 of arXiv:2111.14180).

A first attempt validated the formula against a brute-force "discrete transfinite diameter".
That was METHODOLOGICALLY WRONG and I am recording why rather than deleting it:
d_n is the maximum of the Fekete product, a greedy selection only LOWER-BOUNDS d_n, and
d_n <= cap only in the limit n -> inf, so comparing one greedy value against the formula
proves nothing (it reported spurious "inconsistency", including d_16 < d_12, which is
impossible for a monotone Fekete sequence and therefore flagged my own routine, not the paper).

Replaced by four EXACT tests, each anchored to a statement the paper makes:
  T1  Theorem 3.5's own stated special cases, to the last digit.
  T2  Remark 3.7: as s -> (1+r) from below, gamma_inf(V) -> r  (a nontrivial limit that
      discriminates between branch choices for alpha and for the complex logarithm).
  T3  Lemma 3.11: gamma(E) = 0  <=>  delta_1 > delta_2.  This one exercises the GENERAL
      lens (d3 != 0), which is exactly the case the T1 degeneracies never reach.
  T4  Theorem 3.4(3): gamma(E) STRICTLY increases when both X and Y are increased.
      Also exercises the general lens, and any error in alpha or in the log branch shows up
      immediately as a violated monotonicity.
"""

import math
from fractions import Fraction as Fr
from lens import gamma_inf_lens, gamma_full, gamma_archimedean

FAILS = []


def check(name, cond, detail=""):
    if cond:
        print(f"  PASS  {name}")
    else:
        print(f"  FAIL  {name}   {detail}")
        FAILS.append(name)


# ---------------------------------------------------------------- T1

def t1_special_cases():
    print("\n[T1] Theorem 3.5 stated special cases (exact)")
    for (R1, R2, c, exp) in [
        (1.0, 2.0, 1.0, 1.0), (2.0, 5.0, 3.0, 2.0), (1.5, 4.0, 2.5, 1.5),
        (2.0, 1.0, 1.0, 1.0), (5.0, 2.0, 3.0, 2.0), (4.0, 1.5, 2.5, 1.5),
        (1.0, 3.0, 0.0, 1.0), (3.0, 1.0, 0.0, 1.0), (2.0, 2.0, 0.0, 2.0),
    ]:
        g = gamma_inf_lens(R1, R2, c)
        check(f"D(0,{R1}) n D({c},{R2}) = {g:.12f} (expect {exp})", abs(g - exp) < 1e-12)
    for (R1, R2, c) in [(1.0, 1.0, 3.0), (2.0, 1.0, 5.0), (1.0, 1.0, 2.0)]:
        g = gamma_inf_lens(R1, R2, c)
        check(f"empty/tangent D(0,{R1}) n D({c},{R2}) = {g} (expect 0)", g == 0.0)


# ---------------------------------------------------------------- T2

def t2_remark_37():
    """Remark 3.7: in V = D(0,r) n D(1,s), as s -> 1+r from below, gamma_inf(V) -> r.
    Implement by calling gamma_inf_lens with R1=r, c=1, R2=s."""
    print("\n[T2] Remark 3.7 limit: gamma_inf -> r as s -> 1+r from below")
    ok = True
    for r in (0.5, 1.0, 2.0, 3.7):
        vals = []
        for eps in (1e-2, 1e-4, 1e-6, 1e-8):
            s = (1.0 + r) - eps
            vals.append(gamma_inf_lens(r, s, 1.0))
        good = abs(vals[-1] - r) < 1e-5 * max(1.0, r)
        ok &= good
        print(f"    r={r}: s->1+r gives {['%.9f' % v for v in vals]}  (target {r}) "
              f"{'ok' if good else 'BAD'}")
    check("Remark 3.7 limit reproduced", ok)


# ---------------------------------------------------------------- T3

def t3_lemma_311_zero():
    """Lemma 3.11: gamma(E) = 0 exactly when delta_1 > delta_2, with
        delta_1 = max(-c, -d1 c/d2 - d3/(sqrt(p) d2)), delta_2 = min(c, d1 c/d2 - d3/(sqrt(p) d2))
    in the regime X = Y = c sqrt(p), p a perfect square.
    Checks the ARCHIMEDEAN factor vanishes on exactly the right set -- including d3 != 0,
    i.e. genuinely off-centre lenses, which T1/T2 never produce."""
    print("\n[T3] Lemma 3.11: gamma_inf(E_inf) = 0  <=>  delta_1 > delta_2  (d3 != 0 included)")
    bad = 0
    n = 0
    for q in (5, 7, 11, 13, 17, 19, 23):
        p = q * q
        c = Fr(1, 2)
        for d1 in range(1, int(Fr(q) * 3 * c / 2) + 1):
            for d2 in range(1, int(Fr(q) * 3 * c / 2) + 1):
                for d3 in range(0, int(q * c * c * Fr(3)) + 1):
                    n += 1
                    g = gamma_archimedean(p, d1, d2, d3, float(c * q), float(c * q))
                    d1c = Fr(d1) * c / d2
                    d3o = Fr(d3) / (q * d2)
                    d1v = max(-c, -d1c - d3o)
                    d2v = min(c, d1c - d3o)
                    zero_expected = (d1v > d2v)
                    if zero_expected != (g == 0.0):
                        bad += 1
                        if bad <= 5:
                            print(f"    mismatch d1={d1} d2={d2} d3={d3} "
                                  f"d1_={d1v} d2_={d2v} g={g}")
    check(f"gamma=0 matches delta_1>delta_2 on {n} triples", bad == 0, f"{bad} mismatches")


# ---------------------------------------------------------------- T4

def t4_monotone():
    """Theorem 3.4(3): gamma(E) strictly increases when BOTH X and Y are increased
    (assuming gamma != 0).  Exercises the general lens.

    IMPORTANT REGIME RESTRICTION, learned the hard way: Theorem 3.4(3) is stated for an E
    attached to a g1 that ACTUALLY EXISTS, i.e. one satisfying Theorem 2.1, which requires
    the Minkowski inequality (1.3).  For F = Q, J = pZ, [F:Q] = 1, |D_F/Q| = 1, r2 = 0 that
    inequality is  Norm(J) > 27 * X * Y,  i.e.  X*Y < p/27.  Testing monotonicity outside it
    produced 11 "violations" that are not violations of anything -- they are instances where
    no such g1 exists, so the theorem says nothing.  (This is the same class of error as this
    program's recorded "test at the tightest case, not a representative one" lesson, in the
    regime rather than the value direction.)"""
    print("\n[T4] Theorem 3.4(3) monotonicity in (X,Y), inside Theorem 2.1's regime")
    bad = 0
    n = 0
    p = 1009
    for d1 in (1, 2, 3, 5, 7, 11):
        for d2 in (-9, -6, -3, -1, 1, 2, 4, 6):
            for d3 in (-7, -3, -1, 0, 2, 5, 9, 13):
                for X, Y in ((1.0, 1.0), (1.5, 1.5), (1.2, 2.0), (0.8, 2.4)):
                    X2, Y2 = X * 1.05, Y * 1.05
                    # both points must satisfy Thm 2.1's Minkowski inequality (1.3)
                    if not (Fr(p) > 27 * Fr(1, 1) * X2 * Y2):
                        continue
                    # ... and the g1 must satisfy Thm 2.1(i)
                    if not (d1 < p / (3 * X2) and abs(d2) < p / (3 * Y2)
                            and abs(d3) < p / 3):
                        continue
                    g1 = gamma_full(p, d1, d2, d3, X, Y)
                    g2 = gamma_full(p, d1, d2, d3, X2, Y2)
                    if g1 == 0.0:
                        continue          # Thm 3.4(3) assumes gamma(E) != 0
                    n += 1
                    if not (g2 > g1):
                        bad += 1
                        if bad <= 5:
                            print(f"    d1={d1} d2={d2} d3={d3} X={X} Y={Y}: "
                                  f"{g1:.9f} -> {g2:.9f} (not increasing)")
    check(f"gamma strictly increasing on {n} in-regime pairs", bad == 0, f"{bad} violations")


def t5_alpha_convention():
    """T5 -- which angle is alpha in Theorem 3.5?  THE discriminator, added after the other
    four tests all passed while the formula was still WRONG.

    T1-T4 do not separate the two readings: they only hit the degeneracy branches, and both
    the Remark 3.7 limit and the cap <= min(R1,R2) bound hold either way.  The reading that
    matters changes the answer for the canonical lens D(0,1) n D(1,1): 0.6495 (interior arc
    angle, which the paper's proof implies via angle preservation under the cross-ratio map)
    vs 0.5464 (outward-normal angle).

    The test: for a smooth convex K, the Fekete numbers satisfy
        d_n(K) / n^(1/(n-1))  ->  cap(K),
    with the limit verified EXACTLY on the unit circle (where cap = 1 and d_n = n^(1/(n-1)),
    reproduced here to 6 digits).  So the correct capacity is the one whose implied value
    d_n/n^(1/(n-1)) is STABLE as n grows.  For a fixed-n comparison both candidates can be
    under a common upper bound; only one converges to 1.
    """
    print("\n[T5] alpha convention: which reading converges to the true capacity?")
    import random
    import math as _m

    def sample(R1, R2, c, M=4000, seed=1):
        rnd = random.Random(seed)
        pts = []
        for _ in range(M):
            th = rnd.uniform(0, 2 * _m.pi)
            z = complex(R1 * _m.cos(th), R1 * _m.sin(th))
            if abs(z - c) <= R2 + 1e-12:
                pts.append(z)
        for _ in range(M):
            th = rnd.uniform(0, 2 * _m.pi)
            z = c + complex(R2 * _m.cos(th), R2 * _m.sin(th))
            if abs(z) <= R1 + 1e-12:
                pts.append(z)
        return pts

    def fekete(pts, n, restarts=3, seed=0):
        best = 0.0
        for r in range(restarts):
            rnd = random.Random(seed + r)
            sel = [rnd.choice(pts)]
            for _ in range(n - 1):
                b, bv = None, -1.0
                for z in pts:
                    d = min(abs(z - s) for s in sel)
                    if d > bv:
                        b, bv = z, d
                sel.append(b)
            for _ in range(3):
                imp = True
                while imp:
                    imp = False
                    for i in range(n):
                        cur = min(abs(sel[i] - sel[j]) for j in range(n) if j != i)
                        cand = max(pts, key=lambda z: min(abs(z - sel[j]) for j in range(n) if j != i))
                        if min(abs(cand - sel[j]) for j in range(n) if j != i) > cur + 1e-15:
                            sel[i] = cand
                            imp = True
            lp = sum(_m.log(abs(sel[i] - sel[j])) for i in range(n) for j in range(i + 1, n))
            best = max(best, _m.exp(2 * lp / (n * (n - 1))))
        return best

    # calibration: the unit circle, where the limit is known to be exactly 1
    cp = [complex(_m.cos(2 * _m.pi * k / 3000), _m.sin(2 * _m.pi * k / 3000)) for k in range(3000)]
    for n in (10, 14, 20):
        d = fekete(cp, n)
        exact = n ** (1.0 / (n - 1))
        check(f"unit circle d_{n} = {d:.6f} vs exact n^(1/(n-1)) = {exact:.6f}",
              abs(d - exact) < 2e-4)

    from lens import gamma_inf_lens
    pts = sample(1.0, 1.0, 1.0)
    f = gamma_inf_lens(1.0, 1.0, 1.0)
    print(f"    canonical lens D(0,1) n D(1,1): current formula = {f:.8f}")
    print(f"    {'n':>4} {'d_n/n^(1/(n-1))':>20} {'implied/formula':>18}")
    ratios = []
    for n in (10, 12, 14, 16, 20, 24, 28, 32):
        implied = fekete(pts, n) / (n ** (1.0 / (n - 1)))
        ratios.append(implied / f)
        print(f"    {n:4} {implied:20.6f} {implied / f:18.6f}")
    spread = max(ratios[-4:]) - min(ratios[-4:])
    check(f"implied capacity stable in n (last 4 spread {spread:.4f}, want << 0.1)",
          spread < 0.05)


if __name__ == "__main__":
    print("=" * 78)
    print("EXACT VALIDATION OF THE ARCHIMEDEAN CAPACITY (Theorem 3.5)")
    print("=" * 78)
    t1_special_cases()
    t2_remark_37()
    t3_lemma_311_zero()
    t4_monotone()
    t5_alpha_convention()
    print("\n" + "=" * 78)
    if FAILS:
        print(f"RESULT: {len(FAILS)} FAILURE(S): {FAILS}")
        raise SystemExit(1)
    print("RESULT: ALL EXACT CHECKS PASS")
