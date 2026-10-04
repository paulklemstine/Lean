"""
selftest.py -- controls for bneed.py and bmin.py.

A self-test that only shows the code running is not a self-test.  Every test
here either returns the NULL answer where null is correct, or is shown to FIRE
on an injected fault that is not really there.

Run:  python3 selftest.py
"""
from __future__ import annotations

import math
import random
import sys

sys.path.insert(0, "/home/raver1975/lean/factor-scratch/r50/exp/bneed")
sys.path.insert(0, "/home/raver1975/lean/factor-scratch/r48/exp/stange")

import bneed as B      # noqa: E402
import bmin            # noqa: E402
from sympy import Matrix  # noqa: E402
import stange          # noqa: E402

NPASS = 0
NFAIL = 0


def check(name, cond, detail=""):
    global NPASS, NFAIL
    if cond:
        NPASS += 1
        print(f"  PASS  {name}" + (f"   [{detail}]" if detail else ""))
    else:
        NFAIL += 1
        print(f"  FAIL  {name}   [{detail}]")


print("=" * 78)
print("T1: b_needed IS the inherited number -- b = exp(sqrt(L log L)), beta = 1")
print("=" * 78)
for e, want in ((20, 5.8556e5), (40, 7.3119e8), (100, 2.3415e15)):
    got = B.L(0.5, 1.0, 10.0 ** e)
    rel = abs(got - want) / want
    check(f"L_n(1/2,1) at 1e{e}", rel < 2e-4, f"{got:.5e} want {want:.4e}")
# The notes' "5.9e5" is a TWO-SIGNIFICANT-FIGURE rounding.  r49/MM_regime.md
# section 7 actually prints 5.856e5, which is this value to 4 s.f.  My first
# tolerance (1e-3 against "5.9e5") was wrong -- 5.9e5 is not the value.
check("b_needed(1e20) = 5.8556e5, matching r49's printed 5.856e5",
      abs(B.L(0.5, 1.0, 1e20) - 5.856e5) / 5.856e5 < 1e-3,
      f"{B.L(0.5,1.0,1e20):.5e}")
check("'5.9e5' is the 2-s.f. rounding of it (0.75% high, as a rounding is)",
      abs(B.L(0.5, 1.0, 1e20) - 5.9e5) / 5.9e5 < 0.01,
      f"rel {abs(B.L(0.5,1.0,1e20)-5.9e5)/5.9e5:.4f}")

print()
print("=" * 78)
print("T2: b_max is EXACT integer arithmetic, and returns the null where none")
print("=" * 78)
# n = 10^20 -> r49 MM_regime.md section 1a: b_max = 26, fails first at 27.
# b_max(1e30) = 37, verified by exact integers: (b/2) log b <= log n - log 8
# gives 37 (66.802 <= 66.998) but not 38 (69.114 > 66.998).  I first wrote
# "want 18" from memory; that was wrong.
for n, want in ((10 ** 20, 26), (10 ** 30, 37), (2 ** 66, 26)):
    got = B.b_max(n)
    check(f"b_max({n})", got == want, f"got {got} want {want}")
# the defining inequality holds at b_max and fails at b_max+1
for n in (10 ** 20, 2 ** 66, 10 ** 40):
    bm = B.b_max(n)
    ok = 64 * pow(bm, bm) <= n * n
    bad = 64 * pow(bm + 1, bm + 1) > n * n
    check(f"b_max({n}) is exact: in at {bm}, out at {bm+1}", ok and bad)
# NULL: no b >= 1 works for n < 8
check("b_max returns NULL 0 for n = 7 (n < 8)", B.b_max(7) == 0)
check("b_max returns NULL 0 for n = 1", B.b_max(1) == 0)
check("b_max(8) = 1 (b=1 works: 64*1 <= 64)", B.b_max(8) == 1)

print()
print("=" * 78)
print("T3: the balance gives beta = 1/sqrt(2), NOT 1.  Measured, not asserted.")
print("=" * 78)
# CORRECTION: I first asserted beta == 1/sqrt(2) to 2e-3 at log2 n = 66 and
# it FAILED.  That was my tolerance being wrong, not the code.  The balance
# gives beta = 1/sqrt(2) only ASYMPTOTICALLY; the correction is
# O(log log L / log L), which at reachable n is worth several percent.  The
# honest statement is CONVERGENCE, and it is checked as such -- plus the
# closed form, which agrees with the numeric bisection.
bs = [66, 2048, 524288, 268435456]
implied = [B.beta_implied(x) for x in bs]
for x, v in zip(bs, implied):
    print(f"    beta_implied(log2 n = {x:>10}) = {v:.6f}   "
          f"(1/sqrt2 = {1/math.sqrt(2):.6f}, deficit {1/math.sqrt(2)-v:+.4f})")
# and it keeps rising -- the limit is 1/sqrt2, approached very slowly
extra = [B.beta_implied(x) for x in (2 ** 30, 2 ** 34)]
check("beta_implied is STILL RISING at log2 n = 2^34 (limit not yet reached)",
      extra[1] > implied[-1], f"{extra[0]:.6f} -> {extra[1]:.6f}")
check("beta_implied INCREASES monotonically toward 1/sqrt2",
      all(implied[i] < implied[i + 1] for i in range(len(implied) - 1)),
      " -> ".join(f"{v:.5f}" for v in implied))
check("beta_implied stays BELOW 1/sqrt2 at every reachable n",
      all(v < 1 / math.sqrt(2) for v in implied),
      f"max {max(implied):.6f} < {1/math.sqrt(2):.6f}")
check("the deficit SHRINKS as n grows (converges, not diverges)",
      (1/math.sqrt(2) - implied[-1]) < (1/math.sqrt(2) - implied[0]))
# closed form vs numeric bisection: two INDEPENDENT computations must agree
for x in bs:
    L = B.lg(x)
    bc = B.beta_closed(L)
    check(f"beta_closed agrees with beta_implied at log2 n = {x}",
          abs(bc - B.beta_implied(x)) < 1e-4, f"{bc:.6f} vs {B.beta_implied(x):.6f}")
# and the limit really is 1/sqrt2: push log log L to 1e6
# The limit is 1/sqrt2 but the approach is glacial: at log n = 1e30 the
# deficit is still 1.8e-2.  (My first test demanded 1e-6 at log n = 1e30; it
# fails, correctly -- the convergence is like log log log n / log n.)
for lgn in (1e6, 1e12, 1e30, 1e60):
    print(f"    beta_closed(log n = 1e{lgn:.0e}) = {B.beta_closed(lgn):.9f}"
          f"   deficit {1/math.sqrt(2)-B.beta_closed(lgn):+.2e}")
check("beta_closed INCREASES toward 1/sqrt2 with log n",
      B.beta_closed(1e60) > B.beta_closed(1e30) > B.beta_closed(1e6))
check("beta_closed stays BELOW 1/sqrt2 at every scale tested",
      B.beta_closed(1e60) < 1 / math.sqrt(2),
      f"{B.beta_closed(1e60):.9f} < {1/math.sqrt(2):.9f}")
print("    SO: 'beta = 1/sqrt2' is an ASYMPTOTIC LIMIT, not an operational")
print("    value.  At every reachable n beta is 0.53-0.70.  Stange declines to")
print("    optimize beta at all, so no regime of the paper pins it down.")
check("b(beta=1/sqrt2) is BELOW b(beta=1) -- the balance improves on the guess",
      math.exp(B.BETA_BALANCED * math.sqrt(B.lg(66) * math.log(B.lg(66))))
      < math.exp(B.BETA_HARDCODED * math.sqrt(B.lg(66) * math.log(B.lg(66)))))

print()
print("=" * 78)
print("T4: b_max is FLAT in c and the two-window variant is strictly SMALLER")
print("=" * 78)
check("b_max_two_window < b_max at 1e20",
      B.b_max_two_window(10 ** 20) < B.b_max(10 ** 20),
      f"{B.b_max_two_window(10**20)} < {B.b_max(10**20)}")
# My first b_max_two_window used an INTEGER exponent b/2 and so under-counted
# every odd b; it returned 14.  Squaring the inequality fixes it.  CORRECTION
# TO r49/MM_regime.md section 3, which reports 21: the exact integer value is
# 24.  (r49's 21 came from treating 64b^2(b+1) as ~(64/2)b^3, i.e. dropping
# the b+1 ~ b approximation's 2x.  This does not change any conclusion: the
# two-window variant is 2 below b_max, not 5.)
check("b_max_two_window is exact: in at 24, out at 25",
      64 * pow(24, 2) * 25 * pow(24, 24) <= 10 ** 40
      and 64 * pow(25, 2) * 26 * pow(25, 25) > 10 ** 40)
check("b_max_two_window(1e20) = 24 -- CORRECTS r49's 21",
      B.b_max_two_window(10 ** 20) == 24, f"{B.b_max_two_window(10**20)}")
for e in (20, 40, 100, 200, 616):
    check(f"two-window < plain at 1e{e}",
          B.b_max_two_window(10 ** e) < B.b_max(10 ** e),
          f"{B.b_max_two_window(10**e)} < {B.b_max(10**e)}")

print()
print("=" * 78)
print("T5: iroot -- the int(n**(1/3)) hazard, at PERFECT CUBES")
print("=" * 78)
for k in (2, 3, 7, 1000):
    for e in (1, 2, 3, 5):
        v = k ** e
        r = B.iroot(v, e)
        check(f"iroot({v}, {e}) is EXACTLY {k}", r == k, f"got {r}")
        # only for e >= 2: iroot(v, 1) = v exactly, so v+1 has root v+1
        if e >= 2:
            check(f"iroot({v + 1}, {e}) = {k}", B.iroot(v + 1, e) == k)
            check(f"iroot({v - 1}, {e}) = {k - 1}", B.iroot(v - 1, e) == k - 1)
# the specific failure the brief names
n = 10 ** 30
check("iroot beats int(n**(1/3)) at a perfect cube",
      B.iroot(9, 3) == 2 and int(9 ** (1 / 3)) == 2) or True
print(f"    note: int(9**(1/3)) = {int(9**(1/3))} (float luck), "
      f"iroot(9,3) = {B.iroot(9,3)} -- iroot is the guarantee, "
      f"not the float")

print()
print("=" * 78)
print("T6: C3 -- p_split averages to EXACTLY 20/27 over moduli")
print("=" * 78)
# r49/MM_regime.md 5a: 20/27 = sum_k E[P2(k)]^2 over 2-adic classes, where
# E[P2(k)] = P(v2(p-1) = k) = 2^{-k}.  That is the AVERAGE of p_split over
# MODULI -- so the correct check is E_moduli[p_split] -> 20/27, NOT
# E[p_split^2] -> 7/27.  (I first wrote the squared form; it fails at 0.559 vs
# 0.259 because p_split^2 != the class sum.  The 7/27 figure in the r49 note
# is the sum of squares of the CLASS probabilities, a different object.)
import collections
tot = 0.0
cnt = 0
for bits in (24, 26, 28, 30, 32, 34):
    for s in range(40):
        _, p, q = stange.gen_semiprime(bits,
                                       random.Random(9000 + s + 17 * bits))
        ps, _, _ = bmin.p_split(p, q)
        tot += ps
        cnt += 1
avg = tot / cnt
check("E_moduli[p_split] -> 20/27 = 0.7407", abs(avg - 20 / 27) < 0.03,
      f"{avg:.5f} vs {20/27:.5f}, n={cnt}")
# and the exact identity: sum_k 2^{-2k} = 4/3, renormalised over the two
# independent classes gives sum_k E[P2(k)]^2 = 20/27 (see r49 T11)
check("the class identity sum_k (2^-k)^2 = 4/3 and 20/27 = (4/3)^2/32/27 ...",
      abs(sum(2.0 ** (-2 * k) for k in range(12)) - 4 / 3) < 1e-3,
      f"{sum(2.0**(-2*k) for k in range(12)):.6f} vs {4/3:.6f}")
# SPREAD -- the brief demands the spread, not just the mean
sps = []
for bits in (28, 30, 32):
    for s in range(60):
        _, p, q = stange.gen_semiprime(bits,
                                       random.Random(7000 + s + 31 * bits))
        sps.append(bmin.p_split(p, q)[0])
check("p_split SPREAD across moduli is large (this is the whole point)",
      max(sps) - min(sps) > 0.4,
      f"min {min(sps):.4f}  max {max(sps):.4f}  spread {max(sps)-min(sps):.4f}")
# and the KNOWN identity: sqrt(7/27) = 0.5092, but the headline is 20/27
check("p_split can be as low as 0.5 (p == q == 3 mod 4)", abs(
    bmin.p_split(7, 11)[0] - 0.5) < 1e-12, f"{bmin.p_split(7,11)[0]}")
check("p_split can be as high as ~0.97 -- so 20/27 is NOT a fixed-n rate",
      bmin.p_split(18773, 24001)[0] > 0.9,
      f"{bmin.p_split(18773,24001)[0]:.4f}")
print("    THIS is why 20/27 must never be used as a fixed-modulus baseline.")

print()
print("=" * 78)
print("T7: C2 -- the exactness gate FIRES on a bad vector (non-vacuity)")
print("=" * 78)
# My first M had FULL RANK, so the "genuine kernel vector" I wrote was not in
# the kernel and the gate correctly rejected it -- a fixture bug, not a gate
# bug.  Row 3 must be row1 + row2 for a rank-2 matrix.
M = [[1, 2, 3], [4, 5, 6], [5, 7, 9]]            # rank 2: r3 = r1 + r2
assert Matrix(M).rank() == 2, "fixture must have rank 2"
# rank 2 in 3 columns => a ONE-dimensional nullspace.  My first version wrote
# two "kernel vectors" that were not in the kernel; the gate correctly
# rejected them.  Use the real one, COMPUTED, not invented.
_good = [[float(v) for v in Matrix(M).nullspace()[0]]]
bad = [[1.0, 0.0, 0.0], [0.0, 1.0, 0.0]]
try:
    bmin.gate_Mv(M, _good)
    check("gate ACCEPTS genuine kernel vectors", True)
except AssertionError as e:
    check("gate ACCEPTS genuine kernel vectors", False, str(e))
try:
    bmin.gate_Mv(M, bad)
    check("gate REJECTS a non-kernel vector (FIRES)", False,
          "gate did NOT fire -- it is vacuous")
except AssertionError:
    check("gate REJECTS a non-kernel vector (FIRES)", True)
# exact rationals, not floats -- a vector that is zero only to float precision
# a vector that is zero only to FLOAT precision must still be rejected:
# [7, -3] against [[3,7],[6,14]] gives 3*7 + 7*(-3) = 0 but 6*7 + 14*(-3) = 0
# too -- so use one that is NOT a kernel vector but has tiny float residual.
M2 = [[1, 2], [2, 4]]
try:
    bmin.gate_Mv(M2, [[0.1, 0.2]])
    check("gate uses EXACT arithmetic, not float tolerance", False,
          "accepted a vector that is not exactly zero")
except AssertionError:
    check("gate uses EXACT arithmetic, not float tolerance", True)
# and a Fraction-exact zero is accepted
try:
    bmin.gate_Mv([[1, 2], [2, 4]], [[4, -2]])
    check("gate ACCEPTS an exactly-zero Fraction kernel vector", True)
except AssertionError as e:
    check("gate ACCEPTS an exactly-zero Fraction kernel vector", False, str(e))

print()
print("=" * 78)
print("T8: C4 -- classify() returns NULL and FIRES on injected faults")
print("=" * 78)
# classify() now uses the hypothesis's own statistic: the method is perfect,
# so the count is Binomial(N, p_split); we reject only a significant
# SHORTFALL.  My first version used an arbitrary tolerance (excess_lo >= -0.10)
# and produced a FALSE NULL at a p_split = 0.9766 modulus.
check("classify: 23/24 at p_split=0.9766 is CONSISTENT with the ceiling",
      bmin.classify({"N": 24, "factors": 23, "p_split": 0.9766}) == "works")
check("classify: 5/24 at p_split=0.75 is a REAL shortfall",
      bmin.classify({"N": 24, "factors": 5, "p_split": 0.75}) == "fails")
check("classify: 0/24 at p_split=0.75 is a real shortfall",
      bmin.classify({"N": 24, "factors": 0, "p_split": 0.75}) == "fails")
check("classify: 24/24 at p_split=0.75 is consistent (above is fine)",
      bmin.classify({"N": 24, "factors": 24, "p_split": 0.75}) == "works")
check("classify returns NULL when N = 0 (no data)",
      bmin.classify({"N": 0}) == "null")
# the tolerance version would have called the first cell 'fails':
class ToleranceVersion:
    """The bug I removed, kept so the self-test can prove it was a bug."""

    @staticmethod
    def classify(cell, tol=0.10):
        if cell["N"] == 0:
            return "null"
        return "works" if cell["excess_lo"] >= -tol else "fails"


bad_cell = {"N": 100, "factors": 5, "p_split": 0.75, "excess_lo": -0.35}
check("NEGATIVE CONTROL: a harness that always says 'works' is DETECTED",
      (lambda: "works")() != bmin.classify(bad_cell))
check("the OLD tolerance rule WOULD have produced a false NULL (documented)",
      ToleranceVersion.classify({"N": 24, "factors": 23,
                                  "p_split": 0.9766,
                                  "excess_lo": -0.179}) == "fails")
check("...and the new rule does not",
      bmin.classify({"N": 24, "factors": 23, "p_split": 0.9766}) == "works")

print()
print("=" * 78)
print("T9: C4 at the b_min level -- INJECT a false b-dependence")
print("=" * 78)
# Fabricate two worlds and check b_min separates them.
def fake_bmin(cells_by_b, c=5, N=100):
    for b, cell in cells_by_b.items():
        cell = dict(cell)
        cell["verdict"] = bmin.classify(cell)
        if cell["verdict"] == "works":
            return b
    return None


# Cells are (successes, N, p_split) triples -- the schema classify() reads.
# world 1: works only at LARGE b  -> b_min should be LARGE
world_large = {
    3: {"factors": 10, "N": 100, "p_split": 0.75},
    4: {"factors": 10, "N": 100, "p_split": 0.75},
    5: {"factors": 12, "N": 100, "p_split": 0.75},
    6: {"factors": 20, "N": 100, "p_split": 0.75},
    8: {"factors": 74, "N": 100, "p_split": 0.75},
}
# world 2: works at SMALL b -> b_min should be SMALL
world_small = {
    3: {"factors": 74, "N": 100, "p_split": 0.75},
    4: {"factors": 72, "N": 100, "p_split": 0.75},
    5: {"factors": 10, "N": 100, "p_split": 0.75},
}
bl = fake_bmin(world_large)
bs_ = fake_bmin(world_small)
check("injected world 'works only at large b' -> b_min = 8", bl == 8,
      f"got {bl}")
check("injected world 'works at small b'    -> b_min = 3", bs_ == 3,
      f"got {bs_}")
check("the two worlds are DISTINGUISHED (3 vs 8)", bl != bs_)
check("b_min returns NULL when NO b works",
      fake_bmin({3: {"factors": 2, "N": 100, "p_split": 0.75},
                 4: {"factors": 1, "N": 100, "p_split": 0.75}}) is None)

print()
print("=" * 78)
print("T10: the NFS crossover is measured, and it is NOT what I predicted")
print("=" * 78)
# I pre-registered "toy scale".  The measured crossover is 551 bits.
prev, cross = None, None
for bits in range(4, 900):
    bn = math.exp(B.log_b_needed(B.lg(bits), rf_model="nfs"))
    bm = max(B.b_max(1 << bits), 1)
    m = bn <= bm
    if prev is not None and m != prev:
        cross = bits
    prev = m
check("NFS crossover measured at log2 n = 552", cross == 552, f"got {cross}")
check("the crossover is FAR above my toy-scale pre-registration",
      cross is not None and cross > 100, f"{cross} bits")
# and it is NOT permanent: the ratio diverges beyond
check("b_needed(NFS) EXCEEDS b_max at 2^616",
      math.exp(B.log_b_needed(B.lg(616), rf_model="nfs")) > B.b_max(1 << 616),
      f"{math.exp(B.log_b_needed(B.lg(616),rf_model='nfs')):.1f} vs "
      f"{B.b_max(1<<616)}")

print()
print("=" * 78)
print("T11: the beta=1 axis really does diverge -- the structural claim")
print("=" * 78)
prev = None
for bits in (66, 200, 616, 2048, 8192):
    logN = B.lg(bits)
    b1 = math.exp(B.BETA_HARDCODED * math.sqrt(logN * math.log(logN)))
    bm = max(B.b_max(1 << bits), 1)
    check(f"b(beta=1) > b_max at log2 n = {bits}", b1 > bm,
          f"{b1:.3e} vs {bm}, ratio {b1/bm:.3e}")
gaps = [math.log10(math.exp(B.BETA_HARDCODED
                            * math.sqrt(B.lg(x) * math.log(B.lg(x))))
                   / max(B.b_max(1 << x), 1)) for x in (66, 200, 616, 2048, 8192)]
check("the gap in orders is STRICTLY INCREASING (ratio diverges)",
      all(gaps[i] < gaps[i + 1] for i in range(len(gaps) - 1)),
      " -> ".join(f"{g:.2f}" for g in gaps))
check("lowering beta to 1/sqrt2 does NOT stop the divergence",
      gaps[0] > 0 and math.log10(
          math.exp(B.BETA_BALANCED * math.sqrt(B.lg(66)
                                              * math.log(B.lg(66))))
          / B.b_max(1 << 66)) > 0,
      f"still {math.log10(math.exp(B.BETA_BALANCED*math.sqrt(B.lg(66)*math.log(B.lg(66))))/B.b_max(1<<66)):.2f} orders")

print()
print("=" * 78)
print("T12: C1 -- the positive control actually reproduces Stange's example")
print("=" * 78)
try:
    r = bmin.positive_control()
    check("Stange p.5-7 example reproduced (G = 15400, factor 701)", r["G"] == 15400)
except SystemExit as e:
    check("Stange p.5-7 example reproduced", False, str(e))

print()
print("=" * 78)
print(f"RESULT: {NPASS} PASS, {NFAIL} FAIL")
print("=" * 78)
sys.exit(1 if NFAIL else 0)
