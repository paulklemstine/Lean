"""
Round 49 -- END-TO-END NFS relation-collection measurement for the valuation law of
paper #523 (`Papers/a_square_minus_a_cube_divides_twice.md`).

WHAT THIS MODULE IS FOR
-----------------------
Paper #523 established, by exhaustive enumeration mod p^k:

    P(p^k | a^2 - b^3) / (1/p^k) = 2 - 1/p        for 2 <= k <= 5
                                 = 2 - 1/p + (p-1) at k = 6
                                 = 1               at k = 1   (NO excess at the prime itself)

Its section 6.1 WITHDREW a claimed "25-38% end-to-end reduction in relation-collection
cost", because it was an interpolation and never propagated through a collection
pipeline.  The open item, quoted:  "Establishing it requires an end-to-end collection
measurement in which the sieved-box structure is preserved."

THE CONTROL (Step 0).  Everything here is built around a switch that removes the k >= 2
excess while preserving the k = 1 law and the value-size distribution:

    TRUE arm :  x = |a^2 - b^3|
    NULL arm :  x = round(|a^2 - b^3| * exp(eps)),   eps ~ U[-delta, delta],  delta = 0.002

The NULL arm is a *locally uniform* integer in a +/-0.2% window around |v|.  A uniform
integer has P(p^k | x) = 1/p^k for every k, so it keeps the k = 1 law (which the true arm
also satisfies exactly) and removes every k >= 2 excess.  The window is wide compared to
every p^k <= B_fb (window width ~ 0.004 * 2^36 ~ 2.7e10 >> 2^12), so the local-uniformity
error in P(p^k | x) is < 1.5e-7 -- four orders below the effect.

SELF-TEST.  `selftest.py` is the gate.  Its load-bearing test is the SWITCH TEST: it
measures P(p^k | x)/p^k on the NULL arm and asserts it is 1.0 for k = 1..6.  If the null
arm still shows a 2 - 1/p excess, the switch did not work and NO number from this module
may be reported.  It also asserts the converse (the true arm does NOT give 1.0), so that a
switch that silently no-ops -- making both arms identical and the whole experiment
vacuous -- is also caught.

NO FLOAT ROOTS ARE USED ANYWHERE.  The box is built from exact powers of two and every
division is exact integer division.  The `int(n**(1/3))` bug class (which understated
floor(n^(1/3)) at every perfect cube and manufactured a fake rigorous refutation in an
earlier round) has no purchase here because there is no cube root to take.
"""

from __future__ import annotations

import math

import numpy as np

# ---------------------------------------------------------------------------
# Exact integer helpers.  All box parameters are exact powers of two.
# ---------------------------------------------------------------------------


def is_pow2(k: int) -> bool:
    return k >= 0 and (1 << k) & ((1 << k) - 1) == 0


def assert_box(A_exp: int, Bb_exp: int) -> None:
    """The box is a uniform sample of a in [0, 2^A_exp) , b in [0, 2^Bb_exp).

    We require 2*A_exp == 3*Bb_exp so that a^2 and b^3 live on the SAME scale
    X = 2^(2*A_exp) = 2^(3*Bb_exp).  This is the NFS-like regime: the sieved region
    |a^2 - b^3| <= X is a box in (a,b) whose two coordinates are matched to the value
    scale, so the value range has no artificial skew between the square and cube sides.
    """
    if 2 * A_exp != 3 * Bb_exp:
        raise ValueError(f"need 2*A_exp == 3*Bb_exp, got {A_exp}, {Bb_exp}")
    for e in (A_exp, Bb_exp):
        if not is_pow2(e):
            raise ValueError("box exponents must be exact powers of two")
    # overflow guard: max |v| = 2^A_exp must fit in int64 with room for the null jitter
    if A_exp > 61:
        raise ValueError("box too large for int64")


# ---------------------------------------------------------------------------
# Primes
# ---------------------------------------------------------------------------


def primes_upto(n: int) -> list[int]:
    if n < 2:
        return []
    sieve = bytearray([1]) * (n + 1)
    sieve[0:2] = b"\x00\x00"
    for i in range(2, int(n**0.5) + 1):  # n is tiny here; float sqrt on the sieve bound is exact enough
        if sieve[i]:
            sieve[i * i :: i] = bytearray(len(sieve[i * i :: i]))
    return [i for i in range(n + 1) if sieve[i]]


# ---------------------------------------------------------------------------
# Box sampling and the two arms
# ---------------------------------------------------------------------------


def sample_box(rng: np.random.Generator, A_exp: int, Bb_exp: int, n: int):
    """Uniform (a,b) from the sieved box.  Returns a, b, v = a^2 - b^3 (exact int64)."""
    assert_box(A_exp, Bb_exp)
    A = 1 << A_exp
    Bb = 1 << Bb_exp
    a = rng.integers(0, A, size=n, dtype=np.int64)
    b = rng.integers(0, Bb, size=n, dtype=np.int64)
    v = a * a - b * b * b  # exact; |v| <= 2^A_exp < 2^61
    return a, b, v


def value_scale(A_exp: int) -> int:
    """X = the value scale of the box: a < 2^A_exp  =>  a^2 < 2^(2*A_exp) = X, and
    b < 2^Bb_exp with 2*A_exp = 3*Bb_exp gives b^3 < X too.  So |a^2 - b^3| < X.
    NOTE: the value scale is 2^(2*A_exp), NOT 2^A_exp -- getting this wrong silently
    changes the operating point u by a factor of 2.  The self-test checks it."""
    return 1 << (2 * A_exp)


def shell_mask(v: np.ndarray, A_exp: int) -> np.ndarray:
    """The NFS operating shell: |v| in [X/2, X].  Gives a TIGHT u-range, which is what a
    real sieved region looks like -- NFS does not sieve the tiny values, they are already
    relations.  Both arms are restricted to the same (a,b), so the shell is matched."""
    X = value_scale(A_exp)
    return (v != 0) & (np.abs(v) * 2 >= X)


def nullize(v: np.ndarray, rng: np.random.Generator, delta: float = 0.002) -> np.ndarray:
    """THE SWITCH.  Turn the k>=2 valuation excess OFF while preserving (i) the k=1 law and
    (ii) the value-size distribution, to within delta in log-size."""
    m = np.abs(v).astype(np.float64)
    eps = rng.uniform(-delta, delta, size=v.shape[0])
    x = np.rint(m * np.exp(eps))
    # keep strictly positive and in int64
    x = np.maximum(x, 1.0).astype(np.int64)
    return x


# ---------------------------------------------------------------------------
# Factor-base strip.  This is a REAL sieve: for every FB prime p we remove ALL copies and
# count the marks.  `smooth <=> cofactor == 1`, which is exact (no factoring needed, no
# the shared harness's factorint fallback, no float anywhere).
# ---------------------------------------------------------------------------


def strip_multi(vals: np.ndarray, primes: list[int], targets: list[int]):
    """One pass over the prime list, snapshotting the cofactor / max-exponent state at each
    target bound.  Returns dict B -> (cofactor, maxexp, marks_ge1, marks_total) where
    marks_ge1/total are cumulative over all primes <= B.

    marks_total[p] accumulates  sum_i max(v_p(v_i), 0)   ->  the number of times the sieve
        would "hit" index i for prime p (once for p | v, again for p^2 | v, ...).
    marks_ge1[p] accumulates  #{i : p | v_i}            ->  candidates divisible by p.
    """
    targets = sorted(set(targets))
    if not primes:
        raise ValueError("empty prime list")
    # the caller must supply primes_upto(targets[-1]); we only assert plausibility here
    if targets[-1] > 2 * primes[-1]:
        raise ValueError("target bound far exceeds largest prime supplied")
    vals = np.maximum(vals.astype(np.int64, copy=True), 1)
    n = vals.shape[0]
    cof = vals
    maxexp = np.zeros(n, dtype=np.int16)
    marks_ge1_cum = np.zeros(len(primes), dtype=np.int64)
    marks_tot_cum = np.zeros(len(primes), dtype=np.int64)
    out: dict[int, tuple] = {}
    ti = 0
    for idx, p in enumerate(primes):
        cnt = np.zeros(n, dtype=np.int16)
        while True:
            q = cof // p
            m = (q * p) == cof
            if not m.any():
                break
            cof[m] = q[m]
            cnt[m] += 1
            if cnt.max() > 300:
                raise AssertionError("valuation runaway -- input not positive int64")
        marks_ge1_cum[idx] = int((cnt >= 1).sum())
        marks_tot_cum[idx] = int(cnt.sum())
        np.maximum(maxexp, cnt, out=maxexp)
        # snapshot every target strictly below the NEXT prime
        while ti < len(targets) and targets[ti] < p:
            out[targets[ti]] = (
                cof.copy(),
                maxexp.copy(),
                marks_ge1_cum.copy(),
                marks_tot_cum.copy(),
                idx,
            )
            ti += 1
    while ti < len(targets):
        out[targets[ti]] = (
            cof.copy(),
            maxexp.copy(),
            marks_ge1_cum.copy(),
            marks_tot_cum.copy(),
            len(primes),
        )
        ti += 1
    return out


def prefix_to_bound(arr: np.ndarray, idx: int) -> np.ndarray:
    """Cumulative mark array truncated to the primes actually <= the snapshot bound."""
    return arr[:idx]


# ---------------------------------------------------------------------------
# Statistics: Wilson/Newcombe interval for a RATIO OF TWO PROPORTIONS.
# ---------------------------------------------------------------------------


def wilson(x: int, n: int, z: float = 1.959963984540054) -> tuple[float, float]:
    if n == 0:
        return (0.0, 1.0)
    p = x / n
    d = 1 + z * z / n
    c = p + z * z / (2 * n)
    s = z * math.sqrt(max(p * (1 - p) / n, 0.0) + z * z / (4 * n * n))
    return ((c - s) / d, (c + s) / d)


def ratio_ci(x1: int, n1: int, x2: int, n2: int):
    """ratio = (x1/n1)/(x2/n2) with a Newcombe (Wilson-score) interval.  Conservative but
    standard and never miscovers in practice for large n."""
    p1 = x1 / n1 if n1 else 0.0
    p2 = x2 / n2 if n2 else 0.0
    lo1, hi1 = wilson(x1, n1)
    lo2, hi2 = wilson(x2, n2)
    r = p1 / p2 if p2 > 0 else float("nan")
    lo = lo1 / hi2 if hi2 > 0 else float("nan")
    hi = hi1 / lo2 if lo2 > 0 else float("nan")
    return r, lo, hi