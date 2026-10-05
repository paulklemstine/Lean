#!/usr/bin/env python3
"""
E3: (a) two-sided closure -- the exponent is max(row1, row2), BOTH must move.
    (b) a faithful small-scale implementation of Harvey Alg 4.2/4.3 to confirm the
        cost model describes the REAL algorithm, not just my algebra.

SCOPE GUARD: locally generated semiprimes ONLY, n < 2^40. No RSA-scale factoring,
no cryptographic moduli. This is a structural cost-model check, not an attack.

PREDICTIONS (stated before running):
  P11 The total exponent is max(row1, row2). Improving EITHER row alone leaves
      the total at 1/5. Only simultaneous improvement moves it. (P8 predicted
      that improving row 2 alone would help; that prediction FAILED and the
      corrected claim is this two-sided one.)
  P12 Requirements for 1/6 and 1/8 in terms of BOTH rows simultaneously.
  P13 Alg 4.2 implemented faithfully factors locally generated semiprimes
      n < 2^40 (POSITIVE CONTROL: instrument fires).
  P14 NEGATIVE CONTROL: on a prime input the same code returns "N is prime".
  P15 The measured work W(r) = #pairs + #BSGS candidates is minimised near
      r = N^{1/5}, and the measured total exponent tracks N^{1/5}.
  P16 The interior term N^{1/2}/(r^{1/2}m) really is the BSGS candidate count
      (measured), i.e. the weight 1/2 on r and 1 on m is not an artefact.
"""
from fractions import Fraction as F
import math, random
from sympy import isprime, nextprime, factorint

random.seed(20261004)

# ----------------------------------------------------------------------------
# (a) two-sided closure, in exact rational arithmetic
# ----------------------------------------------------------------------------
def row1_exp(a, b):
    return F(1, 2) / (1 + F(a) + F(b))

def row2_exp(theta):
    return F(theta, 2) / (1 + F(theta, 2))

print("=" * 78)
print("P11 : the total is max(row1, row2) -- BOTH rows must improve")
print("=" * 78)
print(f"  {'Sum w (row1)':>14s} {'theta (screen)':>15s} | {'row1':>7s} {'row2':>7s} "
      f"{'MAX':>7s} | verdict")
print("  " + "-" * 68)
cases = [(F(3,2), F(1,2)), (F(2), F(1,2)), (F(2), F(2,5)), (F(3,2), F(2,5)),
         (F(3), F(2,5)), (F(3), F(1,4)), (F(2), F(3,10))]
for w, th in cases:
    r1, r2 = row1_exp(F(1, 2), w - F(1, 2)), row2_exp(th)
    tot = max(r1, r2)
    if tot == F(1, 5):
        v = "STILL 1/5"
    elif tot < F(1, 5):
        v = "below 1/5  <-- BOTH rows moved"
    else:
        v = "worse"
    print(f"  {str(w):>14s} {str(th):>15s} | {str(r1):>7s} {str(r2):>7s} {str(tot):>7s} | {v}")
print()
print("  rows 1 and 2 are independent constraints on DIFFERENT parameters:")
print("    row 1 (BSGS)   is balanced in (r, m)   -- depends on w_r, w_m")
print("    row 2 (screen) is balanced in r alone   -- depends only on theta")
print("  and row 2's optimum does not involve m, while row 1's optimum is")
print("  attained at the r that row 2 also pins. Hence max, not min.")

print()
print("=" * 78)
print("P12 : what each target needs, per row")
print("=" * 78)
print(f"  {'target':>7s} | {'row1 Sum w':>12s} | {'row2 theta':>11s} | note")
print("  " + "-" * 58)
for e, lbl in [(F(1, 5), "1/5"), (F(1, 6), "1/6"), (F(1, 8), "1/8")]:
    need_w = F(1, 2) / e                    # row1: (1/2)/(1+Sum w) <= e
    need_th = 2 * e / (1 - e)               # row2: (th/2)/(1+th/2) <= e
    print(f"  {lbl:>7s} | {str(need_w):>12s} | {str(need_th):>11s} | "
          f"Harvey: w=3/2, th=1/2")
print()
print("  1/6 needs BOTH  Sum w: 3/2 -> 2   AND  theta: 1/2 -> 2/5")
print("  1/8 needs BOTH  Sum w: 3/2 -> 3   AND  theta: 1/2 -> 1/3")
print("  theta is the exponent of the SMALL-FACTOR SCREEN (Prop 2.5, cost M^theta).")
print("  Strassen gives theta=1/2. 1/6 would need a screen at theta=2/5.")

# ----------------------------------------------------------------------------
# (b) faithful implementation of Harvey Algorithm 4.2 at small scale
# ----------------------------------------------------------------------------
def alg_4_2_work(n, r, m, alpha, count_only=False):
    """Run Alg 4.2 faithfully, INCLUDING Step (4) (Algorithm 4.1 fallback).

    Returns (factors_or_None, npairs, ncands, nmatched_step3).

    BUG HISTORY (recorded, not hidden):
      (1) first draft used e = a*isqrt(n) + b - cen, but eq (4.1) on p.9 is
          VERBATIM  t_{a,b} := alpha^( a*N + b - ceil((4abN)^{1/2}) ) in Z_N,
          i.e. a*N not a*isqrt(N).  With the wrong exponent, 0 of 8 semiprimes
          factored -- the instrument did not fire at all (vacuous-PASS trap).
      (2) second draft ran only Step (3) and omitted Step (4).  Prop 4.2's
          correctness proof states outright that Step (3) "solves the STRONGER
          congruence (4.3) (a congruence modulo N)" and that on a miss the
          witness survives into Step (4), where Algorithm 4.1 recovers it via
          a GCD modulo p.  Omitting Step 4 gave 2 of 8.  With it: all 8.
    """
    sn = math.isqrt(n)
    npairs = 0
    ncands = 0
    babies = [pow(alpha, i, n) for i in range(m)]
    baby_set = {v: i for i, v in enumerate(babies)}
    a_inv_m = pow(pow(alpha, m, n), -1, n)
    found = None
    nmatched = 0
    leftover = []          # candidates NOT matched in Step (3) -> Step (4) input
    for a in range(1, r + 1):
        for b in range(1, r // a + 1):
            npairs += 1
            cen = math.isqrt(4 * a * b * n)
            cen = cen if cen * cen == 4 * a * b * n else cen + 1
            e = (a * n + b - cen) % n          # <-- eq (4.1): a*N, not a*isqrt(N)
            t = pow(alpha, e, n)
            # Step (2b): "For each integer j in the interval
            #            0 <= j < N^{1/2} / (4 r m (ab)^{1/2})"
            jmax = int(sn / (4 * r * m * math.sqrt(a * b)))
            if jmax <= 0:
                continue
            v = t
            for j in range(jmax):
                ncands += 1
                if not count_only:
                    if v in baby_set:
                        # Step (3): match modulo N, then Lemma 3.1
                        i = baby_set[v]
                        u = i + j * m + cen
                        g = factor_from_u(n, u, a * b)
                        nmatched += 1
                        if g and found is None:
                            found = g
                        # Step 4 removes matched values from the v-list
                    else:
                        leftover.append(v)     # <-- Step (4) input, per Prop 4.2
                v = (v * a_inv_m) % n
    if not count_only and found is None and leftover:
        # Step (4): Algorithm 4.1 collision test, gcd(N, v_h - alpha^i) != 1
        for v in leftover:
            for i in range(m):
                g = math.gcd(n, v - babies[i])
                if 1 < g < n:
                    found = (g, n // g)
                    break
            if found:
                break
    return found, npairs, ncands, nmatched


def factor_from_u(n, u, ab):
    """Lemma 3.1: u = aq+bp iff y^2 - uy + abN has rational roots."""
    disc = u * u - 4 * ab * n
    if disc < 0:
        return None
    s = math.isqrt(disc)
    if s * s != disc:
        return None
    num = u + s
    den = 2
    if num % den:
        num = u - s
    if num % den:
        return None
    p = num // den
    if p > 1 and n % p == 0:
        return (p, n // p)
    return None


def make_semiprime(bits):
    p = nextprime(random.getrandbits(bits // 2))
    q = nextprime(random.getrandbits(bits - bits // 2))
    while q == p or p * q >= 2 ** bits:
        q = nextprime(random.getrandbits(bits - bits // 2))
    return p, q, p * q


print()
print("=" * 78)
print("P13/P14/P15/P16 : faithful Alg 4.2 at small scale (n < 2^40, local semiprimes)")
print("=" * 78)
print(f"  {'bits':>5s} {'n':>14s} {'r':>5s} {'m':>5s} | {'#pairs':>8s} {'#cands':>9s} "
      f"{'result':>22s} | {'W(r)/N^(1/5)':>12s}")
print("  " + "-" * 92)
rowsE = []
for bits in [26, 28, 30, 32, 34, 36, 38, 40]:
    p, q, n = make_semiprime(bits)
    assert isprime(p) and isprime(q) and factorint(n) == {p: 1, q: 1}
    sn = math.isqrt(n)
    r = max(2, int(round(n ** 0.2)))
    m = max(2, int(round(n ** 0.2)))
    if r * m * 4 * r > sn:            # keep jmax >= 1 somewhere
        r = max(2, int(sn / (4 * m * 8)))
    alpha = 2
    if math.gcd(alpha, n) != 1:
        alpha = 3
    found, npairs, ncands, nmatched = alg_4_2_work(n, r, m, alpha, count_only=False)
    ok = found is not None and found[0] * found[1] == n
    W = npairs + ncands
    ratio = W / n ** 0.2
    rowsE.append((bits, n, r, m, npairs, ncands, ok, ratio))
    print(f"  {bits:>5d} {n:>14d} {r:>5d} {m:>5d} | {npairs:>8d} {ncands:>9d} "
          f"{('FACTORED OK' if ok else 'none'):>22s} | {ratio:>12.3f}")

print()
ncell = len(rowsE)
nok = sum(1 for x in rowsE if x[6])
print(f"  P13 cells = {ncell}, factored correctly = {nok}   "
      f"(nonzero check: {'OK' if ncell > 0 else 'VACUOUS!!'})")
print(f"  P16 cands/pairs ratio range: "
      f"{min(x[5]/x[4] for x in rowsE):.1f} .. {max(x[5]/x[4] for x in rowsE):.1f}")
print("       (model: cands ~ N^{1/2}/(r^{1/2}m), pairs ~ r; ratio ~ N^{1/2} r^{-3/2}/m)")

print()
print("  P14 NEGATIVE CONTROL: same code on a PRIME input must report no factors.")
for bits in [26, 32, 40]:
    p = nextprime(random.getrandbits(bits))
    r = max(2, int(round(p ** 0.2)))
    m = max(2, int(round(p ** 0.2)))
    alpha = 2 if math.gcd(2, p) == 1 else 3
    found, npairs, ncands, _mm2 = alg_4_2_work(p, r, m, alpha)
    print(f"    prime, {bits} bits, n={p}: found={found}  (expected None)  "
          f"ok={found is None}")

print()
print("  P15 argmin_r, with the CORRECT objective.")
print("      Two earlier versions of this test FAILED, and the reasons are")
print("      recorded rather than hidden:")
print("        v1: minimised W = #pairs + #cands over ALL r.  VACUOUS -- small r")
print("             gives jmax = 0, so W collapses while covering NOTHING.")
print("        v2: restricted to successful r, but still used the SUM with unit")
print("             weights.  Harvey's cost is a MAX, and it has a third term,")
print("             the screen (N/r)^{1/4}, which DECREASES in r.  A unit-weight")
print("             sum therefore always prefers the smallest usable r, and gave")
print("             r*/N^(1/5) ~ 0.06-0.22.  The metric was wrong, not the model.")
print("      v3 below uses Harvey's actual max-cost, including the screen term.")
print()
for bits in [34, 36, 38, 40]:
    p, q, n = make_semiprime(bits)
    sn = math.isqrt(n)
    m = max(2, int(round(n ** 0.2)))
    rowsP = []
    for r in range(2, 400):
        found, np_, nc_, _mm = alg_4_2_work(n, r, m, 2, count_only=False)
        ok = found is not None and found[0] * found[1] == n
        Mscr = (n / r) ** 0.5
        screen = Mscr ** 0.5                       # Prop 2.5 cost M^{1/2}
        # Harvey's cost is a MAX over {pairs, m, interior, screen}
        cost = max(np_, m, nc_, screen)
        rowsP.append((r, cost, ok))
    good = [x for x in rowsP if x[2]]
    print(f"    n = {n} ({bits} bits)  N^(1/5) = {n**0.2:.1f}  m = {m}   "
          f"successful r: {len(good)}/{len(rowsP)}")
    if good:
        best = min(good, key=lambda z: z[1])
        print(f"      argmin Harvey-cost over SUCCESSFUL r: r*={best[0]}  "
              f"cost={best[1]:.0f}")
        print(f"        r*/N^(1/5) = {best[0]/n**0.2:.2f}    "
              f"cost*/N^(1/5) = {best[1]/n**0.2:.2f}   (predicted both ~ 1)")
        bind = max({"pairs": np_, "m": m, "interior": nc_,
                    "screen": (n/best[0])**0.25}, key=lambda k:
                   {"pairs": np_, "m": m, "interior": nc_,
                    "screen": (n/best[0])**0.25}[k])
        print(f"        binding term at r*: {bind}")
    else:
        print("      NO successful r -- instrument did not fire for this n")
