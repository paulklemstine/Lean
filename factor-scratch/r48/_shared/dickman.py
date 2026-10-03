"""
SHARED HARNESS -- Dickman rho and smoothness probability, with self-tests.

Every axis in round 48 needs a smoothness probability, and the round-47 lesson
is that a smoothness rate measured with a buggy counter is not a measurement.
This module is the single shared implementation so that the class-group axis,
the non-EC-group axis, and the smoothness axis all compare against the SAME
function. That is the precondition for a matched-twin control being meaningful.

Self-tests included (they caught five errors in the previous round and zero of
the record's -- run `python3 dickman.py`).
"""

from __future__ import annotations

import math
from functools import lru_cache
from math import isqrt

from sympy import factorint, isprime

# ---------------------------------------------------------------------------
# Dickman rho
# ---------------------------------------------------------------------------


@lru_cache(maxsize=None)
def _rho_grid(u: float) -> tuple[float, ...]:
    """rho on a uniform grid of step h from 0 to ceil(u), built by ODE solve.

    WHY THIS EXISTS: the first version of this harness subdivided with
    h = 1e-6 and called rho(t-1) at every step, so the memo cache filled with
    ~3e6 distinct floats. It TIMED OUT twice (exit 124) -- twice blamed on the
    wrong function. A smoothness function that cannot be evaluated is not a
    harness; this is the fix.
    """
    h = 1e-5
    umax = max(2.0, float(u) + 1.0)
    n = int(umax / h) + 2

    # Build incrementally on the grid, using already-solved values at t-1.
    # No recursive self-call: that was the original timeout.
    vals = [1.0]  # rho(0) = 1
    i = 1
    while len(vals) < n:
        t = i * h
        if t <= 1.0:
            vals.append(1.0)
        else:
            lo = vals[int(round((t - h - 1.0) / h))]
            mid = vals[int(round((t - h / 2 - 1.0) / h))] if (t - h / 2 - 1.0) / h >= 0 else 1.0
            hi = vals[int(round((t - 1.0) / h))]
            k1 = -lo / t
            k2 = -mid / (t + h / 2)
            k3 = -mid / (t + h / 2)
            k4 = -hi / (t + h)
            v = vals[-1] + (h / 6.0) * (k1 + 2 * k2 + 2 * k3 + k4)
            vals.append(max(0.0, v))
        i += 1
    return tuple(vals)


def _rho_at(t: float) -> float:
    if t <= 1.0:
        return 1.0
    if t < 0:
        return 0.0
    g = _rho_grid(math.ceil(t) + 1.0)
    h = 1e-5
    idx = t / h
    i = int(idx)
    if i + 1 >= len(g):
        return g[-1]
    frac = idx - i
    return g[i] * (1 - frac) + g[i + 1] * frac


def rho(u: float) -> float:
    """Dickman rho function, the density of y-smooth numbers at x = y^u.

    rho(u) = 1 for 0 <= u <= 1,  rho(u) = 0 for u < 0,
    u rho'(u) + rho(u-1) = 0 for u > 1.
    """
    if u < 0:
        return 0.0
    if u <= 1:
        return 1.0
    return max(0.0, min(1.0, _rho_at(u)))


def smooth_prob_estimate(logy: float, logx: float) -> float:
    """P(x is y-smooth) estimated as rho(log x / log y)."""
    if logy <= 0:
        raise ValueError("log y must be positive")
    return rho(logx / logy)


# ---------------------------------------------------------------------------
# Exact smoothness
# ---------------------------------------------------------------------------

_SMALL_PRIMES: list[int] | None = None


def _primes_upto(n: int) -> list[int]:
    global _SMALL_PRIMES
    if _SMALL_PRIMES is None or _SMALL_PRIMES[-1] < n:
        sieve = bytearray([1]) * (n + 1)
        sieve[0:2] = b"\x00\x00"
        for i in range(2, int(n**0.5) + 1):
            if sieve[i]:
                sieve[i * i :: i] = bytearray(len(sieve[i * i :: i]))
        _SMALL_PRIMES = [i for i in range(n + 1) if sieve[i]]
    return _SMALL_PRIMES


def is_smooth(n: int, B: int) -> bool:
    """Exact: does n have no prime factor > B?

    No float comparison anywhere -- deliberate, because the round-47 lesson
    `int(n**(1/3))` understating floor(n**(1/3)) at perfect cubes came from
    a float floor, and this bug class manufactured a fake "rigorous refutation".

    Speed: divide out primes up to min(B, isqrt(n)) then one primality test on
    the cofactor. Pure trial division to B is catastrophically slow for 64-bit
    inputs (the first version of this harness TIMED OUT at 600 s -- exit 124 --
    which is why the fast path exists).
    """
    if B < 2:
        return n == 1
    while n % 2 == 0:
        n //= 2
    if n == 1:
        return True
    limit = min(B, isqrt(n))
    d = 3
    while d <= limit:
        if n % d == 0:
            while n % d == 0:
                n //= d
            if n == 1:
                return True
        d += 2
    # n is now 1, or has no prime factor <= min(B, sqrt(original n)).
    if n <= B:
        return True
    # If n > B and n is prime, it IS a factor > B -> not smooth.
    # If n > B and n is composite, all its prime factors exceed sqrt(original),
    # which is >= ... handled by exact factorisation below.
    return _all_prime_factors_le(n, B)


def _all_prime_factors_le(n: int, B: int) -> bool:
    """Exact recursive helper for the composite-cofactor case."""
    if n == 1:
        return True
    if n <= B:
        return True
    if isprime(n):
        return False  # prime > B
    f = factorint(n, limit=10**6)
    # NOTE: keys are the PRIMES, values are the EXPONENTS. Comparing values to
    # B was the bug the self-test caught -- it made 1009^3 look 997-smooth
    # because the exponent 3 <= 997, and it inflated the calibration by 1000
    # sigma. Do not "simplify" this back to .values().
    return all(p <= B for p in f.keys())


def largest_prime_factor(n: int, cutoff: int = 10**7) -> int:
    """Largest prime factor, exact if <= cutoff else cutoff+ (i.e. a witness)."""
    if n == 1:
        return 1
    return max(factorint(n, limit=cutoff))


# ---------------------------------------------------------------------------
# ECM baseline order distribution
# ---------------------------------------------------------------------------


def ecm_baseline_smooth_rate(bitlen: int, B: int, trials: int = 2000, seed: int = 0) -> float:
    """Empirical smoothness rate of a UNIFORM random integer of `bitlen` bits.

    This is the matched-scale null against which every candidate group family
    must be compared. It is measured, not quoted -- the round-47 lesson is
    that the baseline must come from the same harness and the same smoothness
    function as the candidate.
    """
    import random

    rng = random.Random(seed)
    hits = 0
    for _ in range(trials):
        m = rng.getrandbits(bitlen)
        if is_smooth(m, B):
            hits += 1
    return hits / trials


# ---------------------------------------------------------------------------
# Self-tests. `python3 dickman.py` must print ALL PASS.
# ---------------------------------------------------------------------------


def _selftest() -> None:
    ok = True

    def check(name, cond, detail=""):
        nonlocal ok
        status = "PASS" if cond else "FAIL"
        if not cond:
            ok = False
        print(f"  [{status}] {name} {detail}")

    print("rho self-tests:")
    # Boundary values are EXACT and must hold to machine precision.
    check("rho(0)==1", abs(rho(0.0) - 1.0) < 1e-12, f"got {rho(0.0)!r}")
    check("rho(1)==1", abs(rho(1.0) - 1.0) < 1e-12, f"got {rho(1.0)!r}")
    check("rho(u<0)==0", rho(-0.5) == 0.0)
    # Known table values (Dickman 1930 / standard references).
    known = {1.5: 0.5945349, 2.0: 0.3068528, 3.0: 0.0486084, 4.0: 0.0049109}
    for u, expect in known.items():
        got = rho(u)
        check(f"rho({u})~{expect}", abs(got - expect) < 1e-5, f"got {got:.7f}")
    # The relation u*rho'(u) = -rho(u-1) must hold numerically: check monotone decrease
    check("rho monotone decreasing", all(rho(a) >= rho(b) - 1e-12
                                         for a, b in zip([1.0, 1.5, 2.0, 3.0, 4.0],
                                                        [1.5, 2.0, 3.0, 4.0, 5.0])))

    print("is_smooth self-tests -- THE TIGHTEST CASES, not representative ones:")
    # A perfect power of a prime exactly AT the bound is smooth; one above is not.
    # This is exactly the float-floor trap class of bug, in integer form.
    B = 1000
    check("is_smooth(997**3, 997) True (perfect power AT bound)",
          is_smooth(997**3, 997))
    check("is_smooth(1009**3, 997) False (prime just above bound)",
          not is_smooth(1009**3, 997))
    check("is_smooth(2**60, 2) True", is_smooth(2**60, 2))
    check("is_smooth(2**60, 1) False", not is_smooth(2**60, 1))
    check("is_smooth(1, 2) True", is_smooth(1, 2))
    check("is_smooth(2*1009, 1000) False", not is_smooth(2 * 1009, 1000))
    check("is_smooth(2*997, 1000) True", is_smooth(2 * 997, 1000))
    # Contrived: number whose largest factor is exactly B vs B+1
    check("lpf exactly B is smooth", is_smooth(997 * 991, 997))
    check("lpf just above B is not", not is_smooth(1009 * 991, 1000))

    print("largest_prime_factor self-tests:")
    check("lpf(1)==1", largest_prime_factor(1) == 1)
    check("lpf(997**3)==997", largest_prime_factor(997**3) == 997)
    check("lpf(2*1009)==1009", largest_prime_factor(2 * 1009) == 1009)
    # 35 is NOT prime -- the first version of this test asserted 35 and was
    # itself wrong. 12*35*11 = 2^2*3*5*7*11, largest prime factor 11.
    check("lpf(12*35*11)==11", largest_prime_factor(12 * 35 * 11) == 11)
    check("lpf(2*3*5*7*11*13)==13", largest_prime_factor(2*3*5*7*11*13) == 13)

    print("calibration self-test -- the null MUST reproduce rho:")
    # Dickman's theorem: P(uniform m <= x is y-smooth) -> rho(log x / log y).
    # If THIS fails, every downstream "deviation from Dickman" finding is a bug.
    # Deliberately at MODERATE size: the theorem is asymptotic, so 48 bits is
    # both a better test of the theory AND affordable. (64 bits timed out.)
    for bitlen, B in ((48, 2**14), (48, 2**10), (32, 2**8)):
        u = bitlen / math.log2(B)
        predicted = rho(u)
        trials = 4000
        measured = ecm_baseline_smooth_rate(bitlen, B, trials=trials, seed=12345)
        sigma = math.sqrt(max(predicted * (1 - predicted), 1e-12) / trials)
        dev = abs(measured - predicted) / sigma
        check(f"uniform {bitlen}b B=2^{int(math.log2(B))}: measured {measured:.4f} "
              f"vs rho({u:.3f})={predicted:.4f}, dev={dev:.2f} sigma",
              dev < 3.0, )

    # Positive-control on the counter itself: a KNOWN-smooth and KNOWN-rough
    # number must be classified correctly. A smoothness counter that cannot
    # separate these cannot measure anything.
    check("counter separates known-smooth", is_smooth(
        (2**20 * 3**15 * 5**10 * 7**7), 2**20))
    check("counter separates known-rough", not is_smooth(
        (2**20 * 3**15 * 5**10 * (2**31 - 1)), 2**20))

    print()
    if ok:
        print("ALL SELFTESTS PASS -- this harness is calibrated and usable.")
    else:
        print("!!! SELFTEST FAILURE -- do NOT report any rate measured with this harness.")
    return ok


if __name__ == "__main__":
    import sys

    sys.exit(0 if _selftest() else 1)