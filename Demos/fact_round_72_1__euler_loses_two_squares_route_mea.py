"""
Euler's two-squares factorisation route, fully priced.
=======================================================

This self-contained script demonstrates, numerically, every result of the
accompanying paper "Euler's Two-Squares Route, Fully Priced".

The mathematical objects involved:

  * A *representation* of N is a pair (a, b) of positive integers with
    a^2 + b^2 = N.  Two representations are *essentially distinct* if they
    differ as unordered pairs.

  * EXTRACTION.  Given N = a^2 + b^2 = c^2 + d^2 essentially distinct,
    gcd(ad - bc, N) is a proper nontrivial divisor of N.  Unconditionally.

  * ELIGIBILITY.  For N = p*q with p != q odd primes, two essentially
    distinct representations exist  <=>  p = q = 1 (mod 4).  In that case
    there are exactly two, so the eligible fraction of random odd-prime
    pairs is exactly 1/4.

  * DETERMINISM.  On the Brahmagupta pair built from p = e^2 + f^2 and
    q = g^2 + h^2 one has AD - BC = 2efq and AD + BC = 2ghp exactly, so
    gcd(AD - BC, N) = q and gcd(AD + BC, N) = p on the nose.

  * THE QUARTIC BARRIER.  If a search bound t has reached the smaller part
    of each of two essentially distinct representations of N, then
    2N < t^4.  Two distinct representations cannot both be shallow.

  * COST.  Fermat's difference-of-squares scan halts on its first trial iff
    (q - p)^2 < 4(p + q).  On exactly those instances the representation
    route is forced past (2N)^{1/4}, twice.

Run:  python3 demo.py
Requires: Python 3.9+, standard library only.
"""

from __future__ import annotations

import math
import random
from math import gcd, isqrt
from typing import Dict, Iterator, List, Optional, Sequence, Tuple

Rep = Tuple[int, int]


# ----------------------------------------------------------------------
# 1.  Representations as sums of two squares
# ----------------------------------------------------------------------

def is_square(n: int) -> bool:
    """Exact integer perfect-square test."""
    if n < 0:
        return False
    r = isqrt(n)
    return r * r == n


def two_square_reps(n: int) -> List[Rep]:
    """All normalised representations n = a^2 + b^2 with 0 < a <= b.

    Cost: one pass over a = 1 .. floor(sqrt(n/2)).
    """
    out: List[Rep] = []
    a = 1
    while 2 * a * a <= n:
        rest = n - a * a
        b = isqrt(rest)
        if b * b == rest:
            out.append((a, b))
        a += 1
    return out


def rep_scan_cost(n: int) -> Optional[int]:
    """Number of trial values of the small part needed to collect BOTH
    essentially distinct representations of n (None if fewer than two exist).

    This is the honest cost of the search half of Euler's method.
    """
    found = 0
    a = 1
    while 2 * a * a <= n:
        rest = n - a * a
        b = isqrt(rest)
        if b * b == rest:
            found += 1
            if found == 2:
                return a
        a += 1
    return None


# ----------------------------------------------------------------------
# 2.  Euler's combination step
# ----------------------------------------------------------------------

def euler_extract(rep1: Rep, rep2: Rep, n: int) -> Tuple[int, int]:
    """Euler's combination step.

    Returns the pair (gcd(ad - bc, n), gcd(ad + bc, n)).  The theory says
    both entries are proper nontrivial divisors of n and that their product
    is n whenever n is a product of two distinct primes.
    """
    (a, b), (c, d) = rep1, rep2
    return gcd(abs(a * d - b * c), n), gcd(abs(a * d + b * c), n)


def brahmagupta_pair(e: int, f: int, g: int, h: int) -> Tuple[Rep, Rep]:
    """The two representations of (e^2+f^2)(g^2+h^2) given by the two
    Brahmagupta-Fibonacci identities:

        A = eg + fh,  B = eh - fg      (subtractive branch)
        C = eg - fh,  D = eh + fg      (additive branch)
    """
    a, b = e * g + f * h, e * h - f * g
    c, d = e * g - f * h, e * h + f * g
    return (abs(a), abs(b)), (abs(c), abs(d))


def prime_rep(p: int) -> Rep:
    """The unique representation p = e^2 + f^2, 0 < e <= f, of a prime
    p = 1 (mod 4).  Uniqueness is a corollary of the extraction theorem."""
    reps = two_square_reps(p)
    if len(reps) != 1:
        raise ValueError(f"{p} is not a prime congruent to 1 mod 4")
    return reps[0]


# ----------------------------------------------------------------------
# 3.  Fermat's difference-of-squares scan
# ----------------------------------------------------------------------

def fermat_scan_cost(n: int) -> int:
    """Number of trial values s = ceil(sqrt(n)), ... until s^2 - n is square.

    Terminates at s = (p + q)/2 when n = p*q.
    """
    s = isqrt(n)
    if s * s < n:
        s += 1
    steps = 1
    while not is_square(s * s - n):
        s += 1
        steps += 1
    return steps


def fermat_halts_immediately(p: int, q: int) -> bool:
    """Predicate (q - p)^2 < 4(p + q): the exact balance criterion."""
    return (q - p) ** 2 < 4 * (p + q)


# ----------------------------------------------------------------------
# 4.  Small primality / prime generation helpers
# ----------------------------------------------------------------------

def is_prime(n: int) -> bool:
    """Deterministic Miller-Rabin for n < 3.3 * 10^24."""
    if n < 2:
        return False
    for small in (2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37):
        if n % small == 0:
            return n == small
    d, r = n - 1, 0
    while d % 2 == 0:
        d //= 2
        r += 1
    for a in (2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37):
        x = pow(a, d, n)
        if x == 1 or x == n - 1:
            continue
        for _ in range(r - 1):
            x = x * x % n
            if x == n - 1:
                break
        else:
            return False
    return True


def primes_up_to(limit: int) -> List[int]:
    """Sieve of Eratosthenes."""
    sieve = bytearray([1]) * (limit + 1)
    sieve[0:2] = b"\x00\x00"
    for i in range(2, isqrt(limit) + 1):
        if sieve[i]:
            sieve[i * i:: i] = bytearray(len(sieve[i * i:: i]))
    return [i for i in range(limit + 1) if sieve[i]]


def primes_in_range(lo: int, hi: int, residue: Optional[int] = None) -> List[int]:
    """Primes in [lo, hi], optionally restricted to a residue class mod 4."""
    out = []
    for n in range(lo | 1, hi + 1, 2):
        if is_prime(n) and (residue is None or n % 4 == residue):
            out.append(n)
    return out


# ----------------------------------------------------------------------
# 5.  The classical two-squares counting function
# ----------------------------------------------------------------------

def r2_via_divisors(n: int) -> int:
    """r_2(n) = 4 (d_1(n) - d_3(n)), where d_j counts divisors = j mod 4."""
    d1 = d3 = 0
    for k in range(1, n + 1):
        if n % k == 0:
            if k % 4 == 1:
                d1 += 1
            elif k % 4 == 3:
                d3 += 1
    return 4 * (d1 - d3)


def r2_brute(n: int) -> int:
    """r_2(n) counted directly: ordered pairs (x, y) in Z^2 with x^2+y^2 = n."""
    count = 0
    lim = isqrt(n)
    for x in range(-lim, lim + 1):
        rest = n - x * x
        if rest < 0:
            continue
        y = isqrt(rest)
        if y * y == rest:
            count += 1 if y == 0 else 2
    return count


# ----------------------------------------------------------------------
# Demonstrations
# ----------------------------------------------------------------------

def banner(text: str) -> None:
    print()
    print("=" * 72)
    print(text)
    print("=" * 72)


def demo_extraction() -> None:
    banner("1.  EXTRACTION ALWAYS WORKS  (no primality hypothesis needed)")
    cases: List[int] = [221, 1073, 2501, 5525, 1000009, 25, 6565]
    for n in cases:
        reps = two_square_reps(n)
        if len(reps) < 2:
            print(f"  N = {n:<10} only {len(reps)} representation(s) - ineligible")
            continue
        r1, r2 = reps[0], reps[1]
        g_sub, g_add = euler_extract(r1, r2, n)
        ok = 1 < g_sub < n and 1 < g_add < n
        print(f"  N = {n:<10} {r1[0]}^2+{r1[1]}^2 = {r2[0]}^2+{r2[1]}^2")
        print(f"      gcd(ad-bc, N) = {g_sub:<8} gcd(ad+bc, N) = {g_add:<8}"
              f"  product = {g_sub * g_add:<10} proper: {ok}")

    # The degenerate boundary: a representation with a zero part.
    n = 25
    (a, b), (c, d) = (5, 0), (3, 4)
    print(f"\n  Closed-cone case  N = {n}: {a}^2+{b}^2 = {c}^2+{d}^2, "
          f"gcd(ad-bc, N) = {gcd(abs(a * d - b * c), n)}")


def demo_eligibility() -> None:
    banner("2.  ELIGIBILITY IS EXACTLY THE (1 mod 4, 1 mod 4) CELL")
    ps = [p for p in primes_up_to(400) if p > 2]
    cells: Dict[Tuple[int, int], List[int]] = {}
    for i, p in enumerate(ps):
        for q in ps[i + 1:]:
            if p * q > 60000:
                continue
            cell = (p % 4, q % 4)
            cell = (min(cell), max(cell))
            cells.setdefault(cell, []).append(len(two_square_reps(p * q)))
    print("   cell (p mod 4, q mod 4)   instances   representation counts seen")
    for cell in sorted(cells):
        counts = sorted(set(cells[cell]))
        print(f"        {cell}              {len(cells[cell]):>6}"
              f"        {counts}")
    print("\n  => exactly two representations in the (1,1) cell, zero elsewhere.")

    # Eligible fraction of draws from the odd primes.
    sample = [p for p in primes_up_to(200000) if p > 2]
    frac1 = sum(1 for p in sample if p % 4 == 1) / len(sample)
    print(f"\n  Density of primes = 1 mod 4 among odd primes below 2*10^5: "
          f"{frac1:.4f}")
    print(f"  Predicted eligible fraction of independent pairs: "
          f"{frac1 ** 2:.4f}   (limit 1/4 = 0.2500)")


def demo_counting_function() -> None:
    banner("3.  r_2(n) = 4 (d_1(n) - d_3(n)) AGAINST BRUTE FORCE")
    bad = 0
    for n in range(1, 2001):
        if r2_via_divisors(n) != r2_brute(n):
            bad += 1
    print(f"  checked n = 1 .. 2000:  mismatches = {bad}")
    for n in (221, 325, 1105, 5525):
        print(f"    r_2({n}) = {r2_brute(n):<4} = 4(d1 - d3) = "
              f"{r2_via_divisors(n)}  -> {len(two_square_reps(n))} "
              f"normalised representation(s)")


def demo_determinism() -> None:
    banner("4.  DETERMINISM: WHICH PRIME COMES OUT OF WHICH CROSS TERM")
    pairs = [(13, 17), (5, 29), (13, 41), (17, 97), (29, 101), (101, 8221)]
    for p, q in pairs:
        e, f = prime_rep(p)
        g, h = prime_rep(q)
        n = p * q
        A, B = e * g + f * h, e * h - f * g
        C, D = e * g - f * h, e * h + f * g
        cross_sub = A * D - B * C
        cross_add = A * D + B * C
        print(f"  p = {p:<5} = {e}^2+{f}^2 ,  q = {q:<5} = {g}^2+{h}^2 ,  N = {n}")
        print(f"      AD - BC = {cross_sub:<12} = 2efq = {2 * e * f * q:<12} "
              f"gcd with N = {gcd(abs(cross_sub), n)}   (= q = {q})")
        print(f"      AD + BC = {cross_add:<12} = 2ghp = {2 * g * h * p:<12} "
              f"gcd with N = {gcd(abs(cross_add), n)}   (= p = {p})")
        assert cross_sub == 2 * e * f * q and cross_add == 2 * g * h * p
    print("\n  Both identities hold exactly, for every pair tested.")


def demo_quartic_barrier() -> None:
    banner("5.  THE QUARTIC BARRIER:  2N < t^4")
    print("   N          reps (sorted)            larger small part t   "
          "(2N)^(1/4)   2N < t^4")
    ps = primes_in_range(5, 400, residue=1)
    tested = 0
    for i, p in enumerate(ps):
        for q in ps[i + 1:]:
            n = p * q
            if n > 40000 or tested >= 8:
                continue
            reps = two_square_reps(n)
            if len(reps) != 2:
                continue
            t = max(reps[0][0], reps[1][0])
            quartic = (2 * n) ** 0.25
            print(f"  {n:<10} {reps}      {t:<20} {quartic:<12.3f} "
                  f"{2 * n < t ** 4}")
            tested += 1
    # gap-refined version and the three-representation version
    print("\n  Gap-refined form  2 k^2 N < c^4  when the large parts are k apart:")
    n = 5 * 13 * 17            # 1105: four representations
    reps = two_square_reps(n)
    print(f"    N = {n} has representations {reps}")
    srt = sorted(reps, key=lambda r: -r[1])
    for j in range(1, len(srt)):
        k = srt[0][1] - srt[j][1]
        c = srt[j][0]
        print(f"      gap k = {k:<3}  small part c = {c:<3}  "
              f"2k^2 N = {2 * k * k * n:<10} < c^4 = {c ** 4:<10} "
              f"{2 * k * k * n < c ** 4}")


def demo_cost_comparison(trials: int = 400, seed: int = 20260826) -> None:
    banner("6.  COST: THE REPRESENTATION ROUTE LOSES TO FERMAT")
    rng = random.Random(seed)
    pool = primes_in_range(10_000, 60_000, residue=1)
    ratios: List[float] = []
    single: List[float] = []
    immediate = 0
    for _ in range(trials):
        p, q = rng.sample(pool, 2)
        n = p * q
        f_cost = fermat_scan_cost(n)
        r_cost = rep_scan_cost(n)
        if r_cost is None:
            continue
        if fermat_halts_immediately(p, q):
            immediate += 1
        single.append(r_cost / f_cost)
        ratios.append(2 * r_cost / f_cost)     # Euler needs the search twice

    def quantile(xs: Sequence[float], t: float) -> float:
        ys = sorted(xs)
        return ys[min(len(ys) - 1, int(t * len(ys)))]

    print(f"  {len(ratios)} eligible instances, N ~ 10^8 .. 4*10^9")
    print(f"  median  (single representation search) / (one Fermat scan) : "
          f"{quantile(single, 0.5):8.2f}x")
    print(f"  median  end-to-end Euler / Fermat                          : "
          f"{quantile(ratios, 0.5):8.2f}x")
    print(f"  75th percentile end-to-end Euler / Fermat                  : "
          f"{quantile(ratios, 0.75):8.2f}x")
    print(f"  Fermat halted on its first trial in {immediate} instances")
    print("  (The exact multiplier depends on the instance family and on how the\n   representation search is implemented; what is instance-independent is the\n   quartic barrier below, which no implementation can evade.)")

    print("\n  The catastrophic corner: balanced pairs, where Fermat is instant.")
    print("   p        q        N            Fermat steps   rep-search depth"
          "   (2N)^(1/4)")
    balanced = [(p, q) for p in pool for q in pool
                if p < q and fermat_halts_immediately(p, q)]
    for p, q in balanced[:6]:
        n = p * q
        print(f"  {p:<8} {q:<8} {n:<12} {fermat_scan_cost(n):<14} "
              f"{rep_scan_cost(n):<17} {(2 * n) ** 0.25:.1f}")


def demo_gaussian_bridge() -> None:
    banner("7.  THE CLASS BIT IS A GAUSSIAN DIVISIBILITY")
    p, q = 13, 17
    e, f = prime_rep(p)          # 13 = 2^2 + 3^2
    n = p * q
    print(f"  p = {p} = {e}^2 + {f}^2,  N = {n}")
    print("  For each representation a + b i of norm N, we test whether "
          f"{e} + {f} i divides it")
    print("  in the Gaussian integers, and compare with the congruence "
          f"p | a f - b e.\n")
    print("    (a, b)      p | af - be    (e+fi) | (a+bi)    (e-fi) | (a+bi)")
    for (a, b) in two_square_reps(n):
        for (x, y) in ((a, b), (b, a)):
            cong = (x * f - y * e) % p == 0
            # (e + f i) divides (x + y i)  iff  (x + y i)(e - f i)/p is integral
            num_re, num_im = x * e + y * f, y * e - x * f
            div1 = num_re % p == 0 and num_im % p == 0
            num_re2, num_im2 = x * e - y * f, y * e + x * f
            div2 = num_re2 % p == 0 and num_im2 % p == 0
            print(f"    ({x:>3},{y:>3})      {str(cong):<13} {str(div1):<17} "
                  f"{str(div2)}")
            assert cong == div1
    print("\n  The congruence and the Gaussian divisibility agree in every row,")
    print("  and exactly one of the two conjugate Gaussian primes divides each.")


def main() -> None:
    print(__doc__)
    demo_extraction()
    demo_eligibility()
    demo_counting_function()
    demo_determinism()
    demo_quartic_barrier()
    demo_cost_comparison()
    demo_gaussian_bridge()
    banner("Done.")


if __name__ == "__main__":
    main()
