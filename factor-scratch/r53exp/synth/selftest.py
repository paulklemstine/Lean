"""
selftest.py -- written BEFORE the experiments, and it must be able to FAIL.

Round 52's rule, twice earned: "a z-score against a predicted probability of
exactly 1 is undefined... a test that cannot fire is worse than no test."  So
every detector here has a positive control (must fire) and a negative control
(must NOT fire).  A detector with no negative control is decoration.
"""

from __future__ import annotations

import math
import random
import sys
from math import gcd

from core import (
    Fraction, assert_factor_blind, b_is_b_th_power_residue, exact_psi,
    factor_base, gain, gen_semiprime, has_power, is_qr_mod_n, jac_neg, jac_pos, jacobi,
    k_profile, p_split, pooled, q_table, smooth_exponents, v2, z_binom,
    order_mod,
)

FAILS: list = []
NPASS = 0


def check(cond: bool, label: str, extra: str = "") -> None:
    global NPASS
    if cond:
        NPASS += 1
        print(f"  [PASS] {label} {extra}")
    else:
        FAILS.append(label)
        print(f"  [FAIL] {label} {extra}")


# ==========================================================================
print("=" * 74)
print("T1  the factorisation-blindness guard MUST fire on a cheating condition")
print("=" * 74)


def cheater_uses_p(b, n, p):        # a condition that peeks at a factor
    return p % 2 == 0


def cheater_no_n(b):                # a condition computable from anything
    return True


try:
    assert_factor_blind(cheater_uses_p)
    check(False, "guard rejects a condition that takes p")
except AssertionError as e:
    check("p" in str(e), "guard rejects a condition that takes p", f"({e})")

try:
    assert_factor_blind(cheater_no_n)
    check(False, "guard rejects a condition that does not receive n")
except AssertionError as e:
    check("n" in str(e), "guard rejects a condition that does not receive n")

# and it must ACCEPT the honest ones
ok = True
for f in (jac_neg, jac_pos, b_is_b_th_power_residue):
    try:
        assert_factor_blind(f)
    except AssertionError:
        ok = False
check(ok, "guard ACCEPTS the honest conditions (else it is vacuous)")

# ==========================================================================
print()
print("=" * 74)
print("T2  the 3rd-power-residue candidate is NOT silently implementable")
print("=" * 74)
# The S1-table row for the k-th power residue symbol must be FALSIFIABLE, not
# rhetorical.  If someone ever implements it without p, this test must notice.
try:
    b_is_b_th_power_residue(2, 15)
    check(False, "3rd-power-residue symbol refuses without the factors")
except NotImplementedError as e:
    check("factorisation" in str(e),
          "3rd-power-residue symbol refuses without the factors")

# ==========================================================================
print()
print("=" * 74)
print("T3  Jacobi symbol sanity, and the sign convention Result A relies on")
print("=" * 74)
# (b/p)(b/q) = (b/n).  Verify on moduli where we DO know p and q -- this is the
# identity that makes Result A's trick possible at all, so it must be right.
rng = random.Random(7)
bad = 0
tested = 0
for _ in range(200):
    r = gen_semiprime(20, rng)
    if r is None:
        continue
    n, p, q = r
    assert p * q == n, "gen_semiprime returned (n,p,q) -- unpacking it the other way is bug #3 of II_baseg.md"
    for b in range(2, min(n, 60)):
        if gcd(b, n) != 1:
            continue
        tested += 1
        leg_p = -1 if pow(b, (p - 1) // 2, p) == p - 1 else 1
        leg_q = -1 if pow(b, (q - 1) // 2, q) == q - 1 else 1
        if jacobi(b, n) != leg_p * leg_q:
            bad += 1
check(bad == 0, "(b/p)(b/q) = (b/n) on every unit", f"({tested} checked, {bad} bad)")

# The CRITICAL structural fact Result A rests on, re-verified from scratch:
#   k_p = 0  <=>  b is a QUADRATIC NON-RESIDUE mod p.
# If this fails, the whole transplant dies, so it gets a full enumeration.
#   lam_p = 0  <=>  (b/p) = -1        and        lam_p = v2(p-1) - k_p
# NOT "k_p = 0": at p = 101 (v2(p-1) = 2) a non-residue has k_p = 2, and lam_p = 0.
# This is exactly bug #1 of II_baseg.md -- scoring `k` where the theory is about
# `lam` -- which its own per-cell control caught there and catches here.
bad = 0
tested = 0
nontrivial = 0
for bits in (9, 10, 11, 12):
    for _ in range(6):
        r = gen_semiprime(bits, rng)
        if r is None:
            continue
        n, p, q = r
        for pr in (p, q):
            s_pr = v2(pr - 1)
            for b in range(1, pr):
                kp = v2(order_mod(b, pr))
                lam = s_pr - kp
                qnr = pow(b, (pr - 1) // 2, pr) == pr - 1
                tested += 1
                if (lam == 0) != qnr:
                    bad += 1
                if lam > 0:
                    nontrivial += 1
check(bad == 0, "lam_p = 0  <=>  (b/p) = -1  (the Result-A mechanism, re-derived)",
      f"({tested} enumerated, {bad} bad)")
check(nontrivial > 0, "lam is NOT identically 0 (the test is non-vacuous)",
      f"({nontrivial} cases with lam > 0)")

# ==========================================================================
print()
print("=" * 74)
print("T4  the vacuity detectors: each MUST fire on a planted violation")
print("=" * 74)
try:
    z_binom(30, 10, 0.5)
    check(False, "z_binom refuses k > n")
except ValueError:
    check(True, "z_binom refuses k > n")

# and it must RETURN a sane z, not raise, on a legal call
z = z_binom(500, 1000, 0.5)
check(abs(z) < 3, "z_binom returns the NULL on an honest 50% sampler", f"(z={z:+.2f})")
check(has_power(5) is False and has_power(100) is True,
      "has_power separates under-powered from powered rows")
try:
    v2(0)
    check(False, "v2(0) refuses rather than looping")
except ValueError:
    check(True, "v2(0) refuses rather than looping")

# ==========================================================================
print()
print("=" * 74)
print("T5  smooth_exponents: the V=0 HANG, and non-vacuity")
print("=" * 74)
FB = factor_base(50, 0, exclude_units=False)
# a = 8, b = 4 gives a^2 - b^3 = 64 - 64 = 0 EXACTLY.  The hang class.
check(smooth_exponents(0, FB) is None, "V = 0 is refused, not looped on (a=8,b=4 case)")
check(smooth_exponents(-1, FB) is None, "V < 0 is refused")
# POSITIVE CONTROL: it must also return a correct, full-width vector
ex = smooth_exponents(2 * 3 * 3 * 5, FB)
check(ex is not None and ex[FB.index(2)] == 1 and ex[FB.index(3)] == 2
      and ex[FB.index(5)] == 1 and len(ex) == len(FB),
      "smooth_exponents returns a CORRECT full-width vector (non-vacuous)")
check(smooth_exponents(10**6 + 3, FB) is None, "smooth_exponents rejects a non-smooth value")

# ==========================================================================
print()
print("=" * 74)
def _pf(m):
    out, d = set(), 2
    while d * d <= m:
        if m % d == 0:
            out.add(d)
            while m % d == 0:
                m //= d
        d += 1
    if m > 1:
        out.add(m)
    return out


print("T6  exact Psi vs a brute-force count  (Dickman rho is NOT the null)")
print("=" * 74)
for x, y in ((100, 10), (1000, 25), (50, 5)):
    brute = sum(1 for m in range(1, x + 1)
                if all(pr not in _pf(m) or pr <= y for pr in _pf(m)))
    got = exact_psi(x, y)
    check(got == brute, f"Psi({x},{y}) = {got} matches brute force", f"(brute {brute})")


# ==========================================================================
print()
print("=" * 74)
print("T7  the GAIN law: the q-term must KILL a rejecting condition, by algebra")
print("=" * 74)
# Best case s_C/s_0 = 2, c_cond = 0.  A q < 1 condition is then a guaranteed loss.
check(abs(gain(2.0, 1.0, 1.0, 0.0, 1.0) - 2.0) < 1e-12,
      "q = 1, free condition: GAIN = s_C/s_0 = 2.00 (legal)")
check(gain(2.0, 1.0, 0.5, 0.0, 1.0) <= 1.0,
      "q = 1/2 with s_C/s_0 = 2: GAIN = 1.00 exactly -- break-even AT BEST, killed algebraically",
      f"(GAIN = {gain(2.0, 1.0, 0.5, 0.0, 1.0):.4f})")
# and it is strictly a loss the moment the condition costs anything at all
check(gain(2.0, 1.0, 0.5, 0.001, 1.0) < 1.0,
      "q = 1/2 with a nonzero c_cond: GAIN < 1 strictly (a guaranteed loss)")
check(gain(2.0, 1.0, 1 / 3, 1.0, 1.0) < 1.0,
      "q = 1/3 with a cost: GAIN < 1, a guaranteed loss")
rows = q_table()
check(any(r["q"] < 1 and r["best_gain"] < 1 for r in rows),
      "the q-table contains at least one algebraically-killed arm")

# ==========================================================================
print()
print("=" * 74)
print("T8  order_mod returns a REAL order and can return the NULL")
print("=" * 74)
r = gen_semiprime(20, rng)
n, p, q = r
check(order_mod(2, p) > 0, "order_mod returns a positive order on a prime")
# negative control: a base of order 1 (b = 1) must come back as 1, not as p-1
check(order_mod(1, p) == 1, "order_mod(1) = 1  (null control)")
check(order_mod(p, p) == 0, "order_mod on a non-unit returns 0 (the V=0 guard)")

# ==========================================================================
print()
print("=" * 74)
print("T9  p_split is the mandatory per-modulus profile, and it VARIES")
print("=" * 74)
cells = set()
for bits in range(20, 30):
    for s in range(12):
        r = gen_semiprime(bits, rng)
        if r:
            cells.add(p_split(r[1], r[2]))
check(len(cells) >= 3, "p_split produces MULTIPLE cells (so a pooled rate would be hiding something)",
      f"({len(cells)} distinct cells seen: {sorted(cells)[:8]})")

# ==========================================================================
print()
print("=" * 74)
print("T10  pooled() must expose the between-cell sd -- a pooled rate alone hides")
print("=" * 74)
fake = [(1, 10), (9, 10)]          # two cells at 0.1 and 0.9
p_, m_, sd = pooled(fake)
check(abs(p_ - 0.5) < 1e-12 and sd > 0.5,
      "pooled() = 0.50 with a between-cell sd that reveals the 0.1/0.9 split",
      f"(sd = {sd:.3f})")

# ==========================================================================
print()
print("=" * 74)
print("T11  is_qr_mod_n: the number-field QNR condition, used for SCORING")
print("=" * 74)
r = gen_semiprime(20, rng)
n, p, q = r
ok = True
for x in range(1, min(n, 40)):
    if gcd(x, n) != 1:
        continue
    direct = is_qr_mod_n(x, n, p, q)
    brute = any((y * y - x) % n == 0 for y in range(n))
    if direct != brute:
        ok = False
        break
check(ok, "is_qr_mod_n agrees with brute-force enumeration of squares mod n")

# ==========================================================================
print()
print("=" * 74)
print(f"RESULT: {NPASS} passed, {len(FAILS)} failed")
if FAILS:
    for f in FAILS:
        print("  FAILED:", f)
    sys.exit(1)
print("ALL SELFTESTS PASS")
