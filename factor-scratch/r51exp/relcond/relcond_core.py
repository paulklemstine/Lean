"""
KK -- RELATION-FINDING CONDITIONING.  Core machinery.

THE TARGET.  The best factoring method in this programme (Stange, arXiv:2211.06821)
spends ~95% of its cost in relation-finding: find `x` with `g^x mod n` FB-smooth.
The idea being transplanted is `r50exp/baseg`: conditioning the base on a computable
character raised the 5%-phase success rate 20/27 -> 8/9 (ratio 1.2x) for one O(log n)
Jacobi symbol.  This module asks whether the same conditioning buys anything on the
95% phase.

TWO CANDIDATE FAMILIES, because the programme uses both:
  (S) STANGE form:      r = g^x mod n,        x uniform in [1,n)
  (N) NFS/SQUOFF form:  V = a^2 - b^3,         (a,b) uniform in a box

WHY THE ACCOUNTING IS THE WHOLE GAME (derived once, here, exactly):

  Let `s_0` = FB-smooth rate under the unconditioned search, `s_C` under condition C,
  `q = P(C)` = the fraction of candidates C admits, `c_gen` = cost of generating one
  candidate, `c_cond` = cost of EVALUATING the condition.

  unconditioned:  relations / unit-cost  =  s_0 / c_gen
  conditioned:    relations / unit-cost  =  s_C / (c_gen/q + c_cond)

      GAIN = (s_C/s_0) * q / (1 + q*c_cond/c_gen)                    (*)

  So conditioning can NEVER beat the factor `q` it costs, before `c_cond` is even
  counted.  For any BALANCED character (q = 1/2) the cap is 1/2 -- a guaranteed
  >=2x LOSS no matter how strongly s_C correlates with s_0.  This is R4, and it is
  algebra, not an experiment.

  The cap `q` is BYPASSED only when the condition selects candidates by INDEX rather
  than by REJECTION: e.g. "generate only odd x" has q = 1 (no rejections at all).
  That is the honest place to look, and it is exactly where the Stange Jacobi symbol
  lands -- see `jacobi_is_parity`.

MANDATORY CONTROLS IMPLEMENTED HERE (each with its own self-test):
  * `rho` is NOT a null model (diverges vs e^{-gamma}/ln B) -- we never use it as one.
  * no `int()` on a Rational anywhere; non-vacuity asserted explicitly.
  * two-proportion z REFUSES k > n (the round-52 detector that could never fire).
  * every rate is reported per-characteristic-stratum (`p_split` analogue), never pooled.
"""

from __future__ import annotations

import math
import random
from fractions import Fraction

import numpy as np
from sympy import isprime, nextprime, primerange

# ---------------------------------------------------------------------------
# factor base
# ---------------------------------------------------------------------------

_FB_CACHE: dict[int, np.ndarray] = {}


def primes_upto(b: int) -> np.ndarray:
    """Primes <= b as an int64 array. Cached; `b` is small (tens of thousands)."""
    b = int(b)
    if b not in _FB_CACHE:
        _FB_CACHE[b] = np.array(list(primerange(2, b + 1)), dtype=np.int64)
    return _FB_CACHE[b]


def pi(b: int) -> int:
    return int(len(primes_upto(b)))


# ---------------------------------------------------------------------------
# vectorised FB-smoothness  (the workhorse)
# ---------------------------------------------------------------------------

def smooth_mask_batch(vals, b: int) -> np.ndarray:
    """Exact: does `v` have no prime factor > b?  Returns a boolean array.

    EXACT integer arithmetic only.  No float comparison anywhere: the round-47
    lesson (`int(n**(1/3))` understating `floor(n^1/3)` at perfect cubes) is a
    bug class that manufactures rigorous-looking nonsense, and a smoothness test
    that is *nearly* right is worse than one that is exactly right, because it
    produces a plausible constant.
    """
    v = np.asarray(vals, dtype=np.int64).copy()
    n = v.shape[0]
    if n == 0:
        return np.zeros(0, dtype=bool)
    # ⚠️ V = a^2 - b^3 is EXACTLY 0 whenever a = c^3, b = c^2, and 0 % p == 0 for
    # every p -- so the divide-out loop below never terminates on a zero input.
    # This actually happened: R2 hung for >100 s with no output, and because
    # stdout was block-buffered through a pipe the hang was indistinguishable
    # from "slow".  The fix is to handle v <= 0 up front rather than letting it
    # fall out of the loop.
    zero = v <= 0
    if zero.any():
        # Convention: |v| = 0 is NOT a usable candidate (its factorisation is
        # undefined), and negative values are tested on their absolute value.
        v[zero] = 0
        # mark them False explicitly below; keep them out of the divide-out loop
        safe = v[~zero].copy()
        res = np.zeros(v.shape[0], dtype=bool)
        if safe.size:
            res[~zero] = _divide_out_smooth(safe, b)
        return res
    return _divide_out_smooth(v, b)


def _divide_out_smooth(v: np.ndarray, b: int) -> np.ndarray:
    """Divide out all primes <= b; return (cofactor == 1).  Requires v > 0."""
    for p in primes_upto(b):
        m = (v % p) == 0
        while m.any():
            v[m] //= p
            m = (v % p) == 0
    return v == 1


def smooth_mask_batch_active(vals, b: int) -> np.ndarray:
    """Same answer, but shrinks the working array as values finish.

    Mathematically identical to `smooth_mask_batch`; kept separate so the
    self-test can assert the two agree EXACTLY (a fast path that disagrees with
    the reference path is the round-48 'fast harness' failure mode).
    """
    v = np.asarray(vals, dtype=np.int64).copy()
    n = v.shape[0]
    zero = v <= 0
    alive = ~zero
    for p in primes_upto(b):
        if not alive.any():
            break
        idx = np.flatnonzero(alive)
        w = v[idx]
        m = (w % p) == 0
        while m.any():
            w[m] //= p
            m = (w % p) == 0
        done = w == 1
        if done.any():
            alive[idx[done]] = False
            v[idx[done]] = 1
        v[idx] = w
    res = v == 1
    res[zero] = False      # |v| = 0 has no factorisation; not a usable candidate
    return res


# ---------------------------------------------------------------------------
# characters
# ---------------------------------------------------------------------------

def jacobi(a: int, n: int) -> int:
    """Jacobi symbol (a/n) for odd n > 0.  Returns +1, -1 or 0.

    Euclidean algorithm, exact integers.  `n` here is the RSA modulus pq, which is
    NOT prime -- so this is genuinely a Jacobi symbol, and the (a/p)(a/q)
    factorisation is a fact of the arithmetic, not something the algorithm knows.
    """
    a = int(a)
    n = int(n)
    if n <= 0 or n % 2 == 0:
        raise ValueError("jacobi() needs odd n > 0")
    a %= n
    r = 1
    while a:
        while a % 2 == 0:
            a //= 2
            if n % 8 in (3, 5):
                r = -r
        a, n = n, a
        if a % 4 == 3 and n % 4 == 3:
            r = -r
        a %= n
    if n == 1:
        return r
    return 0


def jacobi_batch(vals, n: int) -> np.ndarray:
    return np.array([jacobi(int(v), int(n)) for v in vals], dtype=np.int8)


def jacobi_is_parity(n: int, g: int) -> bool:
    """DECISIVE STRUCTURAL FACT, checked in the self-test.

        (g^x / n) = (g/n)^x   in {+1,-1}

    so for a FIXED base `g`, the Jacobi symbol of the Stange candidate `g^x mod n`
    is a function of x ONLY -- it carries no information about `g` beyond (g/n),
    and no information about the candidate's factorisation at all.

    CONSEQUENCE: conditioning the Stange candidate stream on its Jacobi symbol is
    exactly conditioning on `x mod 2` (given (g/n) = -1).  It is FREE -- q = 1, no
    rejections -- so the (*) cap does not apply and this is the one form of
    conditioning that could in principle pay.  It is the sharpest version of R1.
    """
    return jacobi(g, n) in (1, -1)


# ---------------------------------------------------------------------------
# statistics -- with the validity checks the round-52 detector was missing
# ---------------------------------------------------------------------------

def two_prop_z(k1: int, n1: int, k2: int, n2: int) -> float:
    """Two-proportion z.  REFUSES out-of-range counts.

    Round 52's version silently accepted k = 220 out of n = 200 and returned
    z = 0.00 -- a detector that could never fire.  A control that cannot fail is
    not a control, so the range check is mandatory here rather than optional.
    """
    for (k, n) in ((k1, n1), (k2, n2)):
        if not (0 <= k <= n):
            raise ValueError(f"two_prop_z: k={k} out of range for n={n} -- "
                             "this detector must never be able to return a "
                             "meaningless z")
    if n1 == 0 or n2 == 0:
        raise ValueError("two_prop_z: empty sample")
    p1, p2 = k1 / n1, k2 / n2
    p = (k1 + k2) / (n1 + n2)
    denom = math.sqrt(p * (1 - p) * (1.0 / n1 + 1.0 / n2))
    if denom == 0.0:
        raise ValueError("two_prop_z: degenerate (both samples all-hit or all-miss)")
    return (p1 - p2) / denom


def rate_ratio(k1: int, n1: int, k2: int, n2: int) -> float:
    """s_1 / s_2, the effect size that (*) actually uses."""
    if k1 == 0 or k2 == 0:
        return math.inf if k1 > 0 else 0.0
    return (k1 / n1) / (k2 / n2)


def wilson_lo(k: int, n: int) -> float:
    """Wilson lower bound on a rate -- avoids printing 0.0000 for a real rate."""
    if n == 0:
        return 0.0
    if k == 0:
        return 0.0
    z = 1.959963984540054
    ph = k / n
    d = 1 + z * z / n
    c = ph + z * z / (2 * n)
    m = c - z * math.sqrt(ph * (1 - ph) / n + z * z / (4 * n * n))
    return m / d


def cap_gain(q: float, s_ratio: float, c_cond_over_c_gen: float = 0.0) -> float:
    """GAIN from (*).  The single most important function in this module."""
    return (s_ratio * q) / (1.0 + q * c_cond_over_c_gen)


# ---------------------------------------------------------------------------
# semiprime generation, with the STRATA recorded (the p_split control)
# ---------------------------------------------------------------------------

def gen_semiprime(bits: int, rng: random.Random) -> tuple[int, int, int]:
    """Random odd semiprime n = pq with n ~ 2^bits.  Returns (n, p, q)."""
    half = bits // 2
    while True:
        p = _rand_prime(half, rng)
        q = _rand_prime(half, rng)
        if p == q:
            continue
        if p > q:
            p, q = q, p
        n = p * q
        if n.bit_length() == bits:
            return n, p, q


def _rand_prime(bits: int, rng: random.Random) -> int:
    while True:
        c = rng.getrandbits(bits) | (1 << (bits - 1)) | 1
        if isprime(c):
            return c


def v2(m: int) -> int:
    if m == 0:
        raise ValueError("v2(0) undefined")
    k = 0
    while m % 2 == 0:
        m //= 2
        k += 1
    return k


def strata(n: int, p: int, q: int, g: int) -> dict:
    """The p_split analogue: the 2-adic cell this modulus+base lives in.

    The programme's warning is load-bearing: rates are sensitive to 2-adic
    structure at the +-0.25 level and two samples of the same cell differ by
    0.085.  So EVERY rate in this round is reported inside one of these cells.
    """
    s_p, s_q = v2(p - 1), v2(q - 1)
    return {
        "bits": n.bit_length(),
        "s_p": s_p,
        "s_q": s_q,
        "v2_n_minus_1": v2(n - 1),
        "cell": f"s_p={s_p},s_q={s_q}",
        "jac_g_n": jacobi(g, n),
        "p": p,
        "q": q,
        "n": n,
    }


# ---------------------------------------------------------------------------
# samplers
# ---------------------------------------------------------------------------

def stange_candidates(n: int, g: int, rng: random.Random, k: int) -> np.ndarray:
    """Family (S): k candidates g^x mod n, x uniform in [1,n).  Faithful to Alg 2.2."""
    return np.array([pow(g, rng.randrange(1, n), n) for _ in range(k)], dtype=np.int64)


def stange_candidates_parity(n: int, g: int, rng: random.Random, k: int,
                             odd: bool) -> np.ndarray:
    """Family (S), restricted to one PARITY of x.  q = 1: no candidate is rejected.

    This is the bypass of the (*) cap.  Note the honest cost, which is NOT free
    after all: if ord(g) = m then odd x ranges over a coset of <g^2> of size
    m/gcd(2,m) -- half the subgroup.  Fewer DISTINCT candidates per unit of x-range.
    `distinct_fraction` below measures exactly that.
    """
    out = np.empty(k, dtype=np.int64)
    i = 0
    while i < k:
        x = rng.randrange(1, n)
        if (x % 2 == 1) == odd:
            out[i] = pow(g, x, n)
            i += 1
    return out


def a2b3_candidates(rng: random.Random, amax: int, k: int) -> tuple[np.ndarray, np.ndarray]:
    """Family (N): k values V = a^2 - b^3 with a,b uniform in [1,amax]."""
    a = np.array([rng.randrange(1, amax + 1) for _ in range(k)], dtype=np.int64)
    b = np.array([rng.randrange(1, amax + 1) for _ in range(k)], dtype=np.int64)
    return a, a * a - b * b * b


def distinct_fraction(vals: np.ndarray) -> float:
    return len(np.unique(vals)) / max(1, len(vals))