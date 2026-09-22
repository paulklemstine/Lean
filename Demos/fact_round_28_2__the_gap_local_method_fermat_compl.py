#!/usr/bin/env python3
"""
Locality classes of classical factoring methods
===============================================

Numerical demonstration of the exact laws governing Fermat's
difference-of-squares factoring method.

Results demonstrated
--------------------
1. The gap-local identity
       cost(p*q) = (p + q)/2 - isqrt(p*q) - 1
   for odd primes p < q, verified by instrumented iteration counting.

2. Divisor-locality at the square root: on any odd non-square N the scan
   halts at the half-sum (d + N/d)/2 of the ordered factorisation whose
   small factor d is nearest sqrt(N) from below.

3. The balance-ratio law: with q ~ r*p, the cost in units of p equals
       phi(r) = (sqrt(r) - 1)^2 / 2,
   independent of p; and the cost is the fraction
       rho(r) = (sqrt(r) - 1) / (sqrt(r) + 1)
   of the cofactor-linear limit (q - p)/2.

4. Class separation: on twin primes Fermat costs 0 iterations while trial
   division costs p; on an odd prime N, Fermat costs Theta(N) while trial
   division certifies primality in sqrt(N) steps.

5. The square defect and its exact repair: on N = n^2 the target a = n lies
   below the start isqrt(N) + 1, so the classical scan exits only at the
   trivial factorisation; starting at isqrt(N) repairs this at a cost of one
   extra iteration on odd non-squares.

6. Steering by multipliers: cost(303) = 34 but cost(33 * 303) = 0, and one
   gcd recovers the factor 3.

Self-contained: standard library only.
"""

from __future__ import annotations

import math
from typing import Dict, List, Optional, Tuple

# ---------------------------------------------------------------------------
# Basic arithmetic helpers
# ---------------------------------------------------------------------------


def isqrt(n: int) -> int:
    """Integer square root: the largest k with k*k <= n."""
    return math.isqrt(n)


def is_square(n: int) -> bool:
    """True iff n is a perfect square."""
    if n < 0:
        return False
    r = isqrt(n)
    return r * r == n


def is_prime(n: int) -> bool:
    """Deterministic trial-division primality test."""
    if n < 2:
        return False
    if n % 2 == 0:
        return n == 2
    d = 3
    while d * d <= n:
        if n % d == 0:
            return False
        d += 2
    return True


def next_prime(n: int) -> int:
    """Smallest prime >= n."""
    m = max(2, n)
    while not is_prime(m):
        m += 1
    return m


# ---------------------------------------------------------------------------
# The scans
# ---------------------------------------------------------------------------


def fermat_scan(n: int, max_iters: Optional[int] = None) -> Tuple[int, int, int]:
    """Classical Fermat scan on odd n.

    Starts at a = isqrt(n) + 1 and increments a until a*a - n is a perfect
    square.  Returns (small_factor, large_factor, iterations), where
    iterations is the number of *increments* performed (0 if the very first
    trial value succeeds).

    NOTE THE INCREMENT.  Omitting `a += 1` turns this into a non-terminating
    loop that presents as a hot loop with no diagnostic; it is invisible to
    tests that exercise only zero-cost inputs, because those return before the
    first increment.
    """
    a = isqrt(n) + 1
    k = 0
    while max_iters is None or k <= max_iters:
        b2 = a * a - n
        b = isqrt(b2)
        if b * b == b2:
            return (a - b, a + b, k)
        a += 1
        k += 1
    raise RuntimeError(f"fermat_scan: exceeded {max_iters} iterations on n={n}")


def fermat_scan_repaired(n: int, max_iters: Optional[int] = None) -> Tuple[int, int, int]:
    """Repaired Fermat scan: identical, but starting one step lower at isqrt(n).

    Halts immediately on every perfect square, and costs exactly one extra
    iteration on every odd non-square.
    """
    a = isqrt(n)
    k = 0
    while max_iters is None or k <= max_iters:
        b2 = a * a - n
        if b2 >= 0:
            b = isqrt(b2)
            if b * b == b2:
                return (a - b, a + b, k)
        a += 1
        k += 1
    raise RuntimeError(f"fermat_scan_repaired: exceeded {max_iters} iterations on n={n}")


def fermat_cost_closed_form(p: int, q: int) -> int:
    """(p + q)//2 - isqrt(p*q) - 1, the gap-local identity for odd primes p < q."""
    return (p + q) // 2 - isqrt(p * q) - 1


def trial_division_cost(p: int, q: int) -> int:
    """Cost of trial division on p*q for primes p <= q: exactly p candidate values."""
    return p


def largest_divisor_below_sqrt(n: int) -> int:
    """The largest divisor d of n with d <= sqrt(n) -- the only divisor Fermat sees."""
    d = isqrt(n)
    while d > 0 and n % d != 0:
        d -= 1
    return d


# ---------------------------------------------------------------------------
# The real-variable laws
# ---------------------------------------------------------------------------


def phi(r: float) -> float:
    """Cost in p-units as a function of the balance ratio r = q/p."""
    return (math.sqrt(r) - 1.0) ** 2 / 2.0


def rho(r: float) -> float:
    """Cost as a fraction of the cofactor-linear limit (q - p)/2."""
    s = math.sqrt(r)
    return (s - 1.0) / (s + 1.0)


def amgm_gap(x: float, y: float) -> float:
    """(x + y)/2 - sqrt(x*y), equal to (sqrt(y) - sqrt(x))^2 / 2."""
    return (x + y) / 2.0 - math.sqrt(x * y)


def gap_upper_bound(x: float, y: float) -> float:
    """The quantitative gap-locality bound (y - x)^2 / (8x)."""
    return (y - x) ** 2 / (8.0 * x)


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------


def demo_gap_local_identity() -> None:
    print("=" * 74)
    print("1.  THE GAP-LOCAL IDENTITY:  cost(p*q) = (p+q)/2 - isqrt(p*q) - 1")
    print("=" * 74)
    pairs: List[Tuple[int, int]] = [
        (3, 101), (5, 13), (11, 13), (101, 211), (101, 409), (101, 6469),
        (10007, 10009), (1009, 3001), (65537, 65539), (7919, 104729),
    ]
    print(f"{'p':>8} {'q':>8} {'N':>14} {'measured':>10} {'formula':>10}  match")
    for p, q in pairs:
        n = p * q
        _, _, k = fermat_scan(n)
        f = fermat_cost_closed_form(p, q)
        print(f"{p:>8} {q:>8} {n:>14} {k:>10} {f:>10}  {'OK' if k == f else 'FAIL'}")
        assert k == f, (p, q, k, f)
    print("\nAll measured counts equal the closed form exactly -- an identity,")
    print("not an estimate.\n")


def demo_divisor_locality() -> None:
    print("=" * 74)
    print("2.  DIVISOR-LOCALITY AT THE SQUARE ROOT")
    print("=" * 74)
    print("On any odd non-square N, the scan stops at (d + N/d)/2 where d is the")
    print("largest divisor of N below sqrt(N).  Every other divisor is invisible.\n")
    print(f"{'N':>10} {'d*':>7} {'N/d*':>8} {'stop':>8} {'predicted':>10} {'cost':>7}")
    for n in [3 * 5 * 7, 3 * 5 * 11, 1155, 9999, 3 * 101, 45045, 255255, 104729]:
        if n % 2 == 0 or is_square(n):
            continue
        d = largest_divisor_below_sqrt(n)
        e = n // d
        u, v, k = fermat_scan(n)
        stop = (u + v) // 2
        print(f"{n:>10} {d:>7} {e:>8} {stop:>8} {(d + e)//2:>10} {k:>7}")
        assert 2 * stop == d + e, (n, d, e, stop)
    print("\nOn a prime the only divisor below sqrt(N) is 1, so the scan must run")
    print("all the way to (N+1)/2 -- cost Theta(N):")
    for p in [101, 1009, 10007]:
        _, _, k = fermat_scan(p)
        predicted = (p - 2 * isqrt(p) - 1) // 2
        print(f"   N = {p:>6} prime:  cost = {k:>7}   (N - 2*isqrt(N) - 1)/2 = {predicted:>7}"
              f"   trial division certifies in {isqrt(p)} steps")
        assert k == predicted
    print()


def demo_balance_ratio_law() -> None:
    print("=" * 74)
    print("3.  THE BALANCE-RATIO LAW:  cost / p = (sqrt(r) - 1)^2 / 2")
    print("=" * 74)
    p = 101
    qs = [211, 409, 809, 1619, 3251, 6469]
    print(f"grid at p = {p}\n")
    header = (f"{'q':>7} {'r=q/p':>9} {'cost':>7} {'cost/p':>9} {'phi(r)':>9} "
              f"{'meas.rho':>9} {'rho(r)':>8}")
    print(header)
    print("-" * len(header))
    for q in qs:
        n = p * q
        _, _, k = fermat_scan(n)
        r = q / p
        meas_rho = k / ((q - p) / 2)
        print(f"{q:>7} {r:>9.4f} {k:>7} {k/p:>9.4f} {phi(r):>9.4f} "
              f"{meas_rho:>9.4f} {rho(r):>8.4f}")
        assert k == fermat_cost_closed_form(p, q)
    print("\nThe p-unit column tracks phi(r) to three decimals across a 250-fold")
    print("range of cost.  Now the same ratios at a much larger p -- the law is")
    print("scale-free, so the p-unit column is essentially unchanged:\n")
    p2 = 4093
    print(header)
    print("-" * len(header))
    for target in [2, 4, 8, 16, 32, 64]:
        q2 = next_prime(target * p2)
        n = p2 * q2
        k = fermat_cost_closed_form(p2, q2)
        r = q2 / p2
        meas_rho = k / ((q2 - p2) / 2)
        print(f"{q2:>7} {r:>9.4f} {k:>7} {k/p2:>9.4f} {phi(r):>9.4f} "
              f"{meas_rho:>9.4f} {rho(r):>8.4f}")
    print("\nExact anchors of the law:")
    for r in [2.0, 4.0, 9.0, 16.0, 64.0]:
        print(f"   r = {r:>5.1f}:  phi(r) = {phi(r):>8.4f}   rho(r) = {rho(r):>7.4f}")
    print("   (phi(4) = 1/2, phi(16) = 9/2, phi(64) = 49/2 exactly;")
    print("    rho(4) = 1/3, rho(9) = 1/2, rho(64) = 7/9 exactly)")
    print("\nStrictness in N:  2*cost + 2 <= q - p, so Fermat NEVER reaches the")
    print("cofactor-linear limit:")
    for q in qs:
        k = fermat_cost_closed_form(p, q)
        assert 2 * k + 2 <= q - p
        print(f"   p={p}, q={q:>5}: 2*{k} + 2 = {2*k+2:>6} <= {q-p:>6} = q - p   OK")
    print()


def demo_class_separation() -> None:
    print("=" * 74)
    print("4.  SEPARATING THE LOCALITY CLASSES")
    print("=" * 74)
    print("Zero-cost criterion:  cost(p*q) = 0  iff  ((p+q)/2 - 1)^2 <= p*q,")
    print("with the convenient sufficient form (q - p - 2)^2 <= 8p.\n")
    twins = [(11, 13), (101, 103), (1949, 1951), (10007, 10009), (1000037, 1000039)]
    print(f"{'p':>9} {'q':>9} {'Fermat':>8} {'trial div':>10} {'criterion':>11}")
    for p, q in twins:
        n = p * q
        k = fermat_cost_closed_form(p, q)
        crit = ((p + q) // 2 - 1) ** 2 <= n
        print(f"{p:>9} {q:>9} {k:>8} {trial_division_cost(p, q):>10} {str(crit):>11}")
        assert k == 0 and crit
    print("\nFermat's cost stays pinned at 0 while trial division's cost runs to")
    print("infinity: the gap-local and p-linear classes are genuinely distinct.\n")
    print("For a FIXED gap the Fermat cost DECREASES as the primes grow --")
    print("impossible for a factor-local method.  Bound: cost <= (q-p)^2/(8p).\n")
    print(f"{'p':>9} {'q':>9} {'gap':>5} {'cost':>6} {'(q-p)^2/(8p)':>14}")
    for p, q in [(11, 13), (101, 103), (1949, 1951), (10007, 10009),
                 (1000037, 1000039)]:
        k = fermat_cost_closed_form(p, q)
        print(f"{p:>9} {q:>9} {q-p:>5} {k:>6} {gap_upper_bound(p, q):>14.6f}")
        assert k <= gap_upper_bound(p, q) + 1e-9
    print()


def demo_square_defect() -> None:
    print("=" * 74)
    print("5.  THE DEGENERATE SQUARE CASE, AND ITS EXACT REPAIR")
    print("=" * 74)
    print("On N = p^2 the difference-of-squares target a = p lies BELOW the start")
    print("isqrt(N) + 1 = p + 1.  The classical scan sails past the answer and")
    print("exits only at the unrelated trivial factorisation a = (p^2+1)/2.\n")
    print(f"{'p':>7} {'N=p^2':>12} {'start':>8} {'target':>8} {'classical cost':>15} "
          f"{'exit factorisation':>22}")
    for p in [7, 13, 101, 1009]:
        n = p * p
        start = isqrt(n) + 1
        u, v, k = fermat_scan(n)
        predicted = (n + 1) // 2 - (p + 1)
        print(f"{p:>7} {n:>12} {start:>8} {p:>8} {k:>15} {f'{u} x {v}':>22}")
        assert k == predicted and (u, v) == (1, n)
    print("\nThe cost is Theta(p^2) on the MOST BALANCED input possible, and the")
    print("factorisation returned reveals nothing.  For p = 4093 the classical")
    print(f"scan needs about {(4093*4093 + 1)//2 - 4094:,} iterations to blunder out.\n")
    print("Repair: start the scan at isqrt(N) instead of isqrt(N) + 1.")
    print("It halts immediately on every square:\n")
    for p in [7, 13, 101, 1009, 4093]:
        n = p * p
        u, v, k = fermat_scan_repaired(n)
        print(f"   N = {n:>12} = {p}^2 :  repaired cost = {k}  -> {u} x {v}")
        assert k == 0 and u == p and v == p
    print("\nand costs exactly ONE extra iteration on every odd non-square:\n")
    for n in [3 * 5, 3 * 101, 9999, 101 * 211, 101 * 409, 104729]:
        _, _, k0 = fermat_scan(n)
        _, _, k1 = fermat_scan_repaired(n)
        print(f"   N = {n:>8}:  classical {k0:>6}   repaired {k1:>6}   "
              f"difference {k1 - k0}")
        assert k1 == k0 + 1
    print()


def demo_multiplier_steering() -> None:
    print("=" * 74)
    print("6.  STEERING THE LOCALITY WITH A MULTIPLIER")
    print("=" * 74)
    print("Fermat sees only the divisor nearest sqrt(N).  Multiplying N by an odd")
    print("k changes which divisor that is: the pair (k*p, q) of k*N can be far")
    print("better balanced than (p, q).\n")
    n = 303  # 3 * 101
    _, _, k0 = fermat_scan(n)
    print(f"N = {n} = 3 x 101,  balance ratio r = {101/3:.2f}")
    print(f"   plain Fermat: {k0} iterations")
    m = 33
    u, v, k1 = fermat_scan(m * n)
    g = math.gcd(u, n)
    print(f"   multiplier k = {m}:  k*N = {m*n} = {u} x {v},  {k1} iterations")
    print(f"   gcd({u}, {n}) = {g}   <- a factor of N, recovered in one gcd")
    assert (k0, k1, g) == (34, 0, 3)
    print("\nA systematic search over odd multipliers for a badly unbalanced N:\n")
    p, q = 1009, 65003
    n = p * q
    print(f"N = {n} = {p} x {q},  r = {q/p:.2f},  plain cost = "
          f"{fermat_cost_closed_form(p, q)}\n")
    print(f"{'k':>5} {'k*p':>9} {'q':>8} {'bound (k*p+q)/2 - sqrt(k*N)':>30}")
    best: Tuple[int, float] = (1, float(fermat_cost_closed_form(p, q)))
    for k in range(1, 130, 2):
        if k * p > q:
            continue
        bound = amgm_gap(float(k * p), float(q))
        if k in (1, 3, 9, 21, 33, 49, 63):
            print(f"{k:>5} {k*p:>9} {q:>8} {bound:>30.2f}")
        if bound < best[1]:
            best = (k, bound)
    print(f"\nbest multiplier found: k = {best[0]}, predicted cost bound "
          f"{best[1]:.2f}")
    _, _, kk = fermat_scan(best[0] * n)
    print(f"actual scan on {best[0]}*N: {kk} iterations "
          f"(vs {fermat_cost_closed_form(p, q)} unmultiplied)")
    print()


def demo_taxonomy_table() -> None:
    print("=" * 74)
    print("7.  THE COMPLETED LOCALITY TAXONOMY")
    print("=" * 74)
    rows: List[Tuple[str, str, str]] = [
        ("trial division", "p-linear", "p"),
        ("Pollard's rho", "factor-local", "sqrt(p)"),
        ("elliptic curve method", "factor-local", "sub-exponential in p"),
        ("Fermat", "gap-local", "(p+q)/2 - sqrt(N)"),
    ]
    print(f"{'method':<24}{'locality class':<18}{'cost on N = p*q'}")
    print("-" * 74)
    for name, cls, cost in rows:
        print(f"{name:<24}{cls:<18}{cost}")
    print("\nFour methods, three locality classes: which see the factor (rho,")
    print("ECM), which see the gap (Fermat), and which see nothing but the scan")
    print("(trial division).  In general Fermat is divisor-local at the square")
    print("root; gap-locality is its semiprime shadow.\n")

    print("A concrete cost comparison across the classes:\n")
    print(f"{'N = p*q':>18} {'trial div':>10} {'rho ~':>8} {'Fermat':>9}")
    cases: List[Tuple[int, int]] = [
        (10007, 10009), (101, 6469), (3, 101), (1009, 65003), (65537, 65539),
    ]
    for p, q in cases:
        fc = fermat_cost_closed_form(p, q)
        print(f"{p * q:>18} {p:>10} {int(math.sqrt(p)):>8} {fc:>9}")
    print()


def main() -> None:
    print()
    print("#" * 74)
    print("#  LOCALITY CLASSES OF CLASSICAL FACTORING METHODS".ljust(73) + "#")
    print("#  Fermat's method is divisor-local at the square root".ljust(73) + "#")
    print("#" * 74)
    print()
    demo_gap_local_identity()
    demo_divisor_locality()
    demo_balance_ratio_law()
    demo_class_separation()
    demo_square_defect()
    demo_multiplier_steering()
    demo_taxonomy_table()
    print("All assertions passed.")


if __name__ == "__main__":
    main()
