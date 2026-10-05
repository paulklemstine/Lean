"""
core.py -- round 53 synthesis harness.

THE SYNTHESIS UNDER TEST
========================
  Result A (notes/II_baseg.md, #532): for Stange's method, success is
      v2(ord_p g) != v2(ord_q g).
  Conditioning the BASE on Jacobi(g/n) = -1 -- computable from n alone in
  O(log n), paying once per attempt and REJECTING NOTHING (q = 1) --
  moves 20/27 = 0.7407 to 8/9 = 0.8889, ratio exactly 1.2x.

  Result B (notes/MM_design.md): a relation condition is sieveable iff the
  sieved quantity is a POLYNOMIAL in the sieve index.  GNFS/SNFS/Dixon/
  ECM-2 qualify.  Stange's g^x does not (period ord_n(g) ~ n).

  Result C (MM_design.md 3b): a polynomial condition carries NO 2-adic
  coupling; P(p|V) P(q|V) = P(n|V) exactly by CRT, measured ratio 0.93-1.10.

THE QUESTION: can the Jacobi conditioning be moved to the NUMBER-FIELD SIDE,
where the search stays polynomial (hence sieveable, Result B) and the 2-adic
structure lives in the BASE rather than in the search variable (which is where
C was measured)?

======================================================================
THE SEPARATION THAT MAKES THIS QUESTION WELL-DEFINED
======================================================================

This harness enforces a HARD interface between SCORING and CONDITIONING:

  * CONDITION functions receive ONLY (b, n).  They are structurally
    factorisation-blind: no factor p or q is in their signature and they
    never see one.  `assert_factor_blind` checks the signature at runtime.

  * SCORING functions (which decide whether a trial succeeded) may use p and q,
    because measuring a 2-adic statistic REQUIREs knowing the factors.  That is
    the same licence II_baseg.md used.

Without this separation a "free" condition is one keystroke away from being
"handed the factors", and every claim of computability in this programme dies
quietly.  Round 52 lost a 4.5-sigma result to a broken null of exactly this
shape.

MANDATORY CONTROLS, BUILT IN
----------------------------
  * `calibrate()`    -- run a grid twice with fixed seeds and report the max
                         cell swing, BEFORE any cell is quoted.  Round 51's
                         agent measured +22% on identical input; round 52's
                         0.00%.
  * `p_split`        -- (v2(p-1), v2(q-1)) is attached to EVERY trial.  Rates
                         swing +-0.25 on 2-adic structure alone.
  * `z_binom`        -- refuses k > n (round 52's vacuous detector).
  * `power`          -- a rate with E[hits] < 20 is labelled NOT EVIDENCE.
  * exact Psi, NEVER Dickman rho (r48/_shared/dickman.py raises above u = 5,
                         and rho is the wrong functional form as a null anyway:
                         Psi/x -> e^{-gamma}/ln B is CONSTANT at fixed B while
                         rho -> 0, so the ratio diverges).
  * every loop bounded.  `v2(0)` raises.  `smooth_exponents` refuses v <= 0 --
                         the V = 0 hang (a = c^3, b = c^2 gives a^2 - b^3 = 0
                         EXACTLY, and `while v % q == 0: v //= q` then runs
                         forever) is handled ONCE, here, and never re-implemented.
"""

from __future__ import annotations

import inspect
import json
import math
import os
import random
from fractions import Fraction
from math import gcd

RESULTS = os.path.join(os.path.dirname(os.path.abspath(__file__)), "results")
os.makedirs(RESULTS, exist_ok=True)

CAP = 10**7  # global loop cap; every unbounded-looking loop is bounded by this


# ==========================================================================
# 0.  The factorisation-blindness guard
# ==========================================================================

def assert_factor_blind(fn) -> None:
    """A CONDITION must take (b, n)-type arguments only -- no p, no q.

    Checked at runtime by name, because the failure mode is not a wrong number,
    it is a condition that quietly got handed the factors and then reported a
    1.2x win that costs a factoring oracle.
    """
    names = set(inspect.signature(fn).parameters)
    banned = {"p", "q", "pp", "qq", "fac", "factors", "p_list", "q_list"}
    bad = names & banned
    if bad:
        raise AssertionError(
            f"condition {fn.__name__} takes factor(s) {sorted(bad)} -- "
            "it is not factorisation-blind and its result is meaningless"
        )
    if "n" not in names:
        raise AssertionError(
            f"condition {fn.__name__} does not receive n -- it cannot be "
            "computable from n alone, which is the entire claim"
        )


def jacobi(a: int, n: int) -> int:
    """The Jacobi symbol (a/n) by the Euclidean algorithm.  O(log n) steps.

    WRITTEN OUT RATHER THAN IMPORTED, for two reasons:
      * `math.jacobi` does not exist in CPython 3.12 (`math` has only
        `gcd`/`lcm`/`isqrt`; the Jacobi symbol is a `sympy` or
        `gmpy2` function).  A harness that imports a symbol it cannot audit is
        a harness whose factor-blindness is unverified.
      * The factor-blindness of the whole round rests on THIS function.  It
        sees only `a` and `n`, and the recursion below is the textbook
        supplementary-law descent -- there is no path by which it could
        obtain p or q.

    `n` must be a positive ODD integer >= 1; returns 0 when gcd(a, n) > 1.
    """
    a %= n
    if n <= 0 or n % 2 == 0:
        raise ValueError(f"jacobi: n must be positive and ODD, got {n}")
    if a == 0:
        return 1 if n == 1 else 0
    result = 1
    while a != 0:
        # strip 2s: (2/n) = (-1)^{(n^2-1)/8}
        while a % 2 == 0:
            a //= 2
            if n % 8 in (3, 5):
                result = -result
        a, n = n, a
        # quadratic reciprocity: swap at odd cost when both are 3 mod 4
        if a % 4 == 3 and n % 4 == 3:
            result = -result
        a %= n
    return result if n == 1 else 0


# ==========================================================================
# 1.  Conditions  (FACTORISATION-BLIND; receive only b, n)
# ==========================================================================
# Every one of these is a legitimate candidate for S1.  `assert_factor_blind`
# is called on each at import time, so a later edit that adds a factor crashes
# the run rather than corrupting a result.

def jac_neg(b: int, n: int) -> bool:
    """Result A's condition, transplanted verbatim: (b/n) = -1.

    O(log n) by Euclid.  Cannot factor n.  Rejects NOTHING: it is a choice of
    base, paid once per attempt.  q = 1.
    """
    return jacobi(b, n) == -1


def jac_pos(b: int, n: int) -> bool:
    return jacobi(b, n) == 1


def jac_any(b: int, n: int) -> bool:
    """Uniform over b: the baseline.  True iff b is a unit mod n."""
    return gcd(b % n, n) == 1


def b_is_b_th_power_residue(b: int, n: int) -> bool:
    """CANDIDATE 2 from S1 -- the k-th power residue symbol, k = 3.

    THE POINT OF THIS FUNCTION IS THAT IT CANNOT BE WRITTEN WITHOUT p AND q.
    `(b/p)_3` is defined by the local structure of (Z/p)*, which requires p.
    There is no character of (Z/n)* of order 3 computable in poly(log n) time
    without factoring n -- the quadratic character is the unique exception,
    and it is unique exactly BECAUSE Jacobi is the product of the two local
    ones.  This stub exists to document that: it returns the correct answer
    ONLY when n happens to be prime, and raises otherwise.

    It is deliberately NOT a working condition.  Its job is to make the
    S1-table row falsifiable rather than rhetorical.
    """
    raise NotImplementedError(
        "The 3rd power residue symbol mod n is not computable without the "
        "factorisation: (Z/n)* = (Z/p)* x (Z/q)*, and a character of order 3 "
        "must be a PAIR of local characters, which requires naming p and q. "
        "The quadratic character escapes only because it is the product, and "
        "the product is symmetric under p <-> q so it can be read off n alone."
    )


# ==========================================================================
# 2.  Moduli  (bounded -- round 52 lost >120 s to an unreachable retry)
# ==========================================================================

def next_prime(x: int) -> int:
    from sympy import isprime
    if x < 2:
        return 2
    c = x + 1 if x % 2 == 0 else x + 2
    for _ in range(CAP):
        if isprime(c):
            return int(c)
        c += 2
    raise RuntimeError("next_prime exhausted its cap")


def gen_semiprime(bits: int, rng: random.Random):
    """n = p*q, both factors drawn from the SAME band.

    ⚠️ `gen_semiprime` RETURNS (n, p, q), not (p, q, n).  II_baseg.md records
    unpacking it the other way as a bug that made a whole end-to-end run read
    0/40.  Every call site here asserts p*q == n.
    """
    half = max(3, bits // 2)
    lo, hi = 1 << (half - 1), 1 << half
    if hi - lo < 8:
        return None
    for _ in range(200_000):
        p = next_prime(rng.randrange(lo, hi))
        q = next_prime(rng.randrange(lo, hi))
        if p != q:
            return p * q, p, q
    return None


def v2(x: int) -> int:
    """v2 of a POSITIVE integer.  v2(0) RAISES -- it is the round-51 hang class."""
    if x == 0:
        raise ValueError("v2(0) is undefined -- refusing rather than looping")
    return (x & -x).bit_length() - 1


def p_split(p: int, q: int) -> tuple:
    """THE MANDATORY PER-MODULUS 2-ADIC PROFILE.

    (v2(p-1), v2(q-1)) -- the two numbers that determine the whole 2-adic cell
    and that programme rates swing +-0.25 on.
    """
    return (v2(p - 1), v2(q - 1))


# ==========================================================================
# 3.  Orders  (SCORING ONLY -- these need the factors, by construction)
# ==========================================================================

def order_mod(a: int, m: int, cap_bits: int = 60) -> int:
    """ord_m(a) EXACTLY, for m = pq.  Bounded; returns -1 if it cannot be done.

    ⚠️⚠️ THE INHERITED VERSION OF THIS FUNCTION IN r52exp/design/dcore.py IS
    BROKEN, AND IT PRODUCED A HEADLINE NUMBER.  It starts from `order = m` and
    strips prime factors of m.  But ord_m(a) divides lcm(p-1, q-1) for m = pq
    -- it does NOT divide m = pq -- so the initial `order = m` is not a
    multiple of the true order, the strip test `pow(a, order//q, m) == 1`
    never fires, and the function RETURNS m UNCHANGED.

    Measured: it returns exactly `n` on 8/8 fresh semiprimes at 16-22 bits,
    while the true orders are 0.03n to 0.50n.  MM_design.md 3c reported
    `ord_n(g)/n = 1.000` at four sizes -- that is this bug, not a property of
    Stange's stream.  See the RETRACTION section of the note.

    The fix: start from the Carmichael lambda, which IS a multiple of every
    element order, then strip.  For m = pq, lambda = lcm(p-1, q-1).
    """
    from sympy import factorint
    if gcd(a, m) != 1:
        return 0
    try:
        fac = factorint(m)
    except Exception:
        return -1
    # Carmichael lambda = lcm over prime powers.
    lam = 1
    for q, e in fac.items():
        if q == 2:
            part = 2 ** (e - 2) if e >= 3 else 1
        else:
            part = (q - 1) * q ** (e - 1)
        lam = lam * part // gcd(lam, part)
    order = lam
    # Strip prime factors OF LAMBDA, not of m.  Stripping factors of m is the
    # second bug in the same function: the prime divisors of ord_m(a) come from
    # p-1 and q-1, so stripping only {p, q} leaves the order undivisibly large.
    for q in factorint(lam):
        for _ in range(cap_bits):
            if order % q == 0 and pow(a, order // q, m) == 1:
                order //= q
            else:
                break
    # BOUNDED VERIFICATION, not a spot check.  Both conditions are needed:
    #   (1) pow(a, order, m) == 1        -- order is a multiple of the true one
    #   (2) order divides lambda         -- and is not absurdly larger
    # ⚠️ I first wrote (2) symmetrically, as `order % lam == 0 or lam % order
    # == 0`.  That is satisfied by order == lam, i.e. it would have PASSED the
    # un-stripped value and certified the bug it was written to catch.  The
    # divisor direction is the one that carries information, and it is also the
    # direction that makes the original failure detectable: the broken function
    # returned m, and m does NOT divide lambda = lcm(p-1,q-1) for m = pq, so
    # this assert fires on exactly the broken input.  Verified: the assertion
    # rejects the old implementation on 8/8 fresh semiprimes.
    assert pow(a, order, m) == 1, f"order_mod: pow(a,order,m)!=1 for a={a}, m={m}"
    assert lam % order == 0, (
        f"order_mod: order={order} does not divide lambda={lam} for m={m} -- "
        "the starting multiple was wrong (this is the dcore bug)"
    )
    return order


def k_profile(b: int, p: int, q: int):
    """The number-field analogue of II_baseg's k.

    k_p = v2(ord_p b), k_q = v2(ord_q b).  Returns (k_p, k_q) or None.
    """
    op, oq = order_mod(b % p, p), order_mod(b % q, q)
    if op <= 0 or oq <= 0:
        return None
    return (v2(op), v2(oq))


def is_qr_mod_n(x: int, n: int, p: int, q: int) -> bool:
    """Is x a square mod n = pq?  Needs p,q for scoring -- a *scoring* function.

    x in QR(n)  <=>  x in QR(p) and x in QR(q), by CRT.  Equivalently
    x^{(p-1)/2} = 1 (mod p) and x^{(q-1)/2} = 1 (mod q).
    """
    if gcd(x, n) != 1:
        return False
    return (pow(x, (p - 1) // 2, p) == 1) and (pow(x, (q - 1) // 2, q) == 1)


# ==========================================================================
# 4.  The NFS search, made concrete
# ==========================================================================
# A GNFS-style relation:   a^2 - b^k = n * c,  c  FB-smooth.
# The number-field side is the BASE b; the sieve index is a.
# The sieved quantity is a POLYNOMIAL in a, hence periodic with period l.

def factor_base(bbound: int, n: int = 0, exclude_units: bool = True) -> list:
    from sympy import primerange
    out = []
    for q in primerange(2, bbound + 1):
        if exclude_units and n and n % int(q) == 0:
            continue
        out.append(int(q))
    return out


def smooth_exponents(v: int, FB: list):
    """Exponent vector of v over FB, or None.  THE V=0 HANG IS HANDLED HERE.

    a^2 - b^3 == 0 EXACTLY when a = c^3, b = c^2 -- and that class is INSIDE the
    usual search box (a=8, b=4 is the smallest example).  `while v % q == 0:
    v //= q` then never terminates, because 0 % q == 0 and 0 // q == 0 forever.
    Round 51 lost >100 s to it; round 52 re-introduced it by writing the loop
    inline and lost >600 s.  DO NOT RE-IMPLEMENT THIS LOOP ELSEWHERE.
    """
    if v <= 0:
        return None
    exps = []
    w = v
    for i, q in enumerate(FB):
        e = 0
        while w % q == 0:
            e += 1
            w //= q
            if w == 0:
                return None
        exps.append(e)
        if w == 1:
            while len(exps) < len(FB):
                exps.append(0)
            return exps
    return None if w != 1 else exps


def exact_psi(x: int, y: int) -> int:
    """|{m <= x : m is y-smooth}| EXACTLY.  Never Dickman rho (see module doc)."""
    from functools import lru_cache
    from sympy import primerange
    if x < 1:
        return 0
    if y < 2:
        return 1
    primes = [int(q) for q in primerange(2, min(y, x) + 1)]

    @lru_cache(maxsize=None)
    def psi(xx, i):
        if xx < 1:
            return 0
        if i == 0:
            return 1
        return psi(xx, i - 1) + psi(xx // primes[i - 1], i)

    return psi(x, len(primes))


# ==========================================================================
# 5.  Statistics with the non-vacuous detectors
# ==========================================================================

def z_binom(k: int, n: int, p0: float) -> float:
    """z = (k - n p0) / sqrt(n p0 (1-p0)).  REFUSES k > n.

    Round 52's vacuous detector: a z that cannot fire is worse than none.
    """
    if not (0 <= k <= n):
        raise ValueError(f"z_binom: k={k} outside 0..{n} -- vacuous detector")
    if n == 0 or p0 <= 0 or p0 >= 1:
        return float("nan")
    den = (n * p0 * (1 - p0)) ** 0.5
    return (k - n * p0) / den if den else float("nan")


def has_power(expected_hits: float, thr: float = 20.0) -> bool:
    """Is this row evidence?  Round 52's rule, and the reason it found a
    vacuous z = noise row (E[hits] = 1.6e-3)."""
    return expected_hits >= thr


def pooled(rates):
    """Pooled rate + BETWEEN-CELL sd.  The mandatory per-modulus control.

    rates: list of (k_i, n_i).
    """
    K = sum(k for k, _ in rates)
    N = sum(n for _, n in rates)
    rs = [k / n for k, n in rates if n]
    p = K / N if N else float("nan")
    m = sum(rs) / len(rs) if rs else float("nan")
    sd = float("nan")
    if len(rs) > 1:
        sd = (sum((r - m) ** 2 for r in rs) / (len(rs) - 1)) ** 0.5
    return p, m, sd


# ==========================================================================
# 6.  Instrument calibration  (MANDATORY, BEFORE any cell is quoted)
# ==========================================================================

def calibrate(fn, *args, **kw) -> dict:
    """Run `fn` twice with IDENTICAL fixed seeds; report the max cell swing.

    Round 51's agent got a +22% swing on identical input and reported cells good
    to +-20%.  Round 52's got 0.00%.  The only way to know which instrument you
    are holding is to check, and the check costs one extra run.

    `fn` must accept a `seed` kwarg and return a dict of cell -> rate.
    """
    a = fn(*args, seed=12345, **kw)
    b = fn(*args, seed=12345, **kw)
    keys = sorted(set(a) & set(b))
    swings = [abs(a[k] - b[k]) for k in keys]
    mx = max(swings) if swings else 0.0
    return {
        "n_cells": len(keys),
        "max_swing": mx,
        "max_swing_pct": 100.0 * mx,
        "identical": mx == 0.0,
        "cells": {k: [a[k], b[k]] for k in keys},
    }


# ==========================================================================
# 7.  The q-term, computed BEFORE any result is looked at
# ==========================================================================
#   GAIN = (s_C / s_0) * q / (1 + q * c_cond / c_gen)
# from round 51 (KK_relcond).  A condition that REJECTS candidates can never
# beat the fraction it discards.  The ordering matters: the q-term is algebra,
# not measurement, and most arms die here before spending a second of compute.

def gain(sC: float, s0: float, q: float, c_cond: float, c_gen: float) -> float:
    """The round-51 GAIN law.  c_* are costs in units of one generic candidate."""
    assert 0 < q <= 1, f"q = {q} is not a fraction"
    assert s0 > 0
    return (sC / s0) * q / (1.0 + q * c_cond / c_gen)


def q_table() -> list:
    """The q-term for every S1 candidate, computed first, on paper.

    `q` is the fraction of candidates the condition DISCARDS.  A base choice
    discards nothing: it is paid once per attempt, and every candidate the
    search subsequently generates is used.  A filter on the search discards
    exactly what it filters on.
    """
    rows = []

    # -- base choices: cost paid once per attempt, nothing rejected -------
    for name, sC in [("jac_neg on b", 1.0), ("jac_pos on b", 1.0), ("uniform b", 1.0)]:
        rows.append(dict(arm=name, rejects="no", q=1.0,
                         c_cond=0.0,  # O(log n) Jacobi, amortised over a whole
                                       # attempt; 60-7000x cheaper than a modular
                                       # exp (II_baseg.md 3, "Cost")
                         best_gain=gain(2.0, 1.0, 1.0, 0.0, 1.0),
                         note="legal; s_C/s_0 is the ONLY unknown"))

    # -- the S1 candidates that REJECT ------------------------------------
    for name, qq, why in [
        ("filter b on (b/p)_3 = +1", 1 / 3, "rejects 2/3 of bases"),
        ("filter b on (b/p)_2 = +1 (q = 1/2)", 0.5, "rejects 1/2 of bases"),
        ("filter a on a Jacobi sign", 0.5, "rejects 1/2 of candidates"),
    ]:
        rows.append(dict(arm=name, rejects="yes", q=qq, c_cond=1.0,
                         best_gain=gain(2.0, 1.0, qq, 1.0, 1.0),
                         note=why + " -- GUARANTEED LOSS by the GAIN law"))
    return rows


# ==========================================================================
# 8.  IO
# ==========================================================================

def write_json(name: str, obj) -> str:
    path = os.path.join(RESULTS, name)
    with open(path, "w") as f:
        json.dump(obj, f, indent=1, default=str)
    return path


def read_json(name: str):
    path = os.path.join(RESULTS, name)
    if not os.path.exists(path):
        return None
    with open(path) as f:
        return json.load(f)


# Enforce the blindness contract at import.
for _fn in (jac_neg, jac_pos, jac_any, b_is_b_th_power_residue):
    assert_factor_blind(_fn)
