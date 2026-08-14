"""
GCD Moments of a Semiprime: a Closed Trace-Witness Family
=========================================================

Self-contained numerical companion to the paper.

For a positive integer ``n`` and an exponent ``k >= 1`` the *k-th gcd moment* is

    M_k(n) = sum_{x = 0}^{n-1} gcd(n, x)^k .

This script demonstrates, purely numerically, every result of the paper:

  1. The divisor form            M_k(n) = sum_{d | n} d^k * phi(n/d).
  2. The semiprime closed form   M_k(pq) = N^k + N*P_{k-1} - P_k + N - s + 1
     in the modulus N = pq and the trace s = p + q alone, with the Newton
     recursion P_0 = 2, P_1 = s, P_{j+2} = s*P_{j+1} - N*P_j.
  3. Trace recovery              2s = 4N + 1 - M_1(N),  and the fact that the
     trace together with N splits N (discriminant s^2 - 4N = (q-p)^2).
  4. Closure of the family       every M_k is an explicit function of (N, M_1).
  5. The Euler product           M_k(n) = prod_{p | n} (p^k + p - 1) for
     squarefree n, and the two-sided bracket n^k + n - 1 <= M_k(n) <= Pi_k(n).
  6. The refinement lattice      E_k(a_1,...,a_r) = prod_i (a_i^k + a_i - 1),
     its unique minimiser (the trivial factorisation) and unique maximiser
     (the prime factorisation), and the collision census.
  7. The cost hierarchy          Var(gcd(N,U)^k) = Theta(N^{2k-1}), so the
     first moment is the cheapest — and only — usable member of the family.

Run with:  python3 demo.py
"""

from __future__ import annotations

import math
import random
from itertools import combinations
from typing import Dict, Iterable, List, Sequence, Tuple

# --------------------------------------------------------------------------
# Elementary arithmetic
# --------------------------------------------------------------------------


def totient(n: int) -> int:
    """Euler's totient phi(n), by trial division. O(sqrt n)."""
    if n <= 0:
        raise ValueError("totient requires n >= 1")
    result, m, d = n, n, 2
    while d * d <= m:
        if m % d == 0:
            while m % d == 0:
                m //= d
            result -= result // d
        d += 1
    if m > 1:
        result -= result // m
    return result


def divisors(n: int) -> List[int]:
    """All positive divisors of n, ascending. O(sqrt n)."""
    small, large = [], []
    d = 1
    while d * d <= n:
        if n % d == 0:
            small.append(d)
            if d != n // d:
                large.append(n // d)
        d += 1
    return small + large[::-1]


def prime_factor_list(n: int) -> List[int]:
    """The primes of n with multiplicity (so len(...) = Omega(n))."""
    out, m, d = [], n, 2
    while d * d <= m:
        while m % d == 0:
            out.append(d)
            m //= d
        d += 1
    if m > 1:
        out.append(m)
    return out


def big_omega(n: int) -> int:
    """Omega(n): the number of prime factors of n counted with multiplicity."""
    return len(prime_factor_list(n))


def is_prime(n: int) -> bool:
    if n < 2:
        return False
    d = 2
    while d * d <= n:
        if n % d == 0:
            return False
        d += 1
    return True


def is_squarefree(n: int) -> bool:
    facs = prime_factor_list(n)
    return len(set(facs)) == len(facs)


# --------------------------------------------------------------------------
# 1. The gcd moment: brute force versus the divisor form
# --------------------------------------------------------------------------


def gcd_moment_bruteforce(k: int, n: int) -> int:
    """M_k(n) = sum_{x < n} gcd(n,x)^k, computed by an O(n log n) scan."""
    return sum(math.gcd(n, x) ** k for x in range(n))


def gcd_moment_divisor_form(k: int, n: int) -> int:
    """M_k(n) = sum_{d | n} d^k phi(n/d).  Requires the factorisation of n."""
    return sum(d**k * totient(n // d) for d in divisors(n))


# --------------------------------------------------------------------------
# 2. The closed form in (N, s) and the Newton power sums
# --------------------------------------------------------------------------


def newton_power_sum(big_n: int, s: int, j: int) -> int:
    """P_j = p^j + q^j from (N, s) alone: P_0 = 2, P_1 = s, P_{j+2} = s P_{j+1} - N P_j."""
    a, b = 2, s  # P_0, P_1
    if j == 0:
        return a
    for _ in range(j - 1):
        a, b = b, s * b - big_n * a
    return b


def moment_closed_form(k: int, big_n: int, s: int) -> int:
    """F_k(N, s) = N^k + N*P_{k-1} - P_k + N - s + 1, the closed form of M_k(pq)."""
    return (
        big_n**k
        + big_n * newton_power_sum(big_n, s, k - 1)
        - newton_power_sum(big_n, s, k)
        + big_n
        - s
        + 1
    )


def trace_from_first_moment(big_n: int, m1: int) -> int:
    """Invert M_1 = 4N - 2s + 1 to recover the trace s = p + q."""
    num = 4 * big_n + 1 - m1
    if num % 2 != 0:
        raise ValueError("first moment is not of semiprime shape")
    return num // 2


def split_from_trace(big_n: int, s: int) -> Tuple[int, int]:
    """Given N = pq and s = p + q, return (p, q) via the discriminant s^2 - 4N = (q-p)^2."""
    disc = s * s - 4 * big_n
    root = math.isqrt(disc)
    if root * root != disc:
        raise ValueError("discriminant is not a perfect square")
    return (s - root) // 2, (s + root) // 2


# --------------------------------------------------------------------------
# 3. Euler products, the envelope, and the refinement lattice
# --------------------------------------------------------------------------


def local_factor(k: int, a: int) -> int:
    """The local factor L_k(a) = a^k + a - 1 of a part a of a factorisation."""
    return a**k + a - 1


def factorisation_euler(k: int, parts: Sequence[int]) -> int:
    """E_k(a_1,...,a_r) = prod_i (a_i^k + a_i - 1), the moment predicted by a factorisation."""
    out = 1
    for a in parts:
        out *= local_factor(k, a)
    return out


def prime_prod(k: int, n: int) -> int:
    """Pi_k(n) = prod over the primes of n with multiplicity of (p^k + p - 1)."""
    return factorisation_euler(k, prime_factor_list(n))


def multiplicative_factorisations(n: int, minimum: int = 2) -> List[List[int]]:
    """All unordered factorisations of n into parts >= 2, each returned ascending."""
    if n == 1:
        return [[]]
    out: List[List[int]] = []
    for d in divisors(n):
        if d < minimum or d == 1:
            continue
        for tail in multiplicative_factorisations(n // d, d):
            out.append([d] + tail)
    return out


# --------------------------------------------------------------------------
# 4. The cost hierarchy: variance of the k-th gcd power
# --------------------------------------------------------------------------


def gcd_variance(k: int, n: int) -> float:
    """Var(gcd(n,U)^k) for U uniform on {0,...,n-1}, from the exact moments."""
    m2k = gcd_moment_divisor_form(2 * k, n)
    mk = gcd_moment_divisor_form(k, n)
    return m2k / n - (mk / n) ** 2


def chebyshev_samples(k: int, n: int, accuracy: float = 1.0, confidence: float = 0.99) -> float:
    """Chebyshev sample count to pin the mean of gcd(n,U)^k to +-accuracy at the given
    confidence: m >= Var / (accuracy^2 * (1 - confidence))."""
    return gcd_variance(k, n) / (accuracy**2 * (1.0 - confidence))


# --------------------------------------------------------------------------
# Demonstrations
# --------------------------------------------------------------------------


def banner(title: str) -> None:
    print()
    print("=" * 78)
    print(title)
    print("=" * 78)


def demo_divisor_form() -> None:
    banner("1.  The divisor form   M_k(n) = sum_{d|n} d^k phi(n/d)")
    print(f"{'n':>5} {'k':>3} {'brute force':>14} {'divisor form':>14}  agree")
    for n in (6, 12, 15, 28, 30, 36, 77):
        for k in (1, 2, 3):
            a = gcd_moment_bruteforce(k, n)
            b = gcd_moment_divisor_form(k, n)
            print(f"{n:>5} {k:>3} {a:>14} {b:>14}  {'yes' if a == b else 'NO'}")
            assert a == b


def demo_closed_form() -> None:
    banner("2.  The closed form   M_k(pq) = F_k(N, s)   depends only on N and s = p+q")
    pairs = [(3, 5), (5, 11), (7, 13), (11, 23), (13, 41)]
    print(f"{'p':>4} {'q':>4} {'N':>6} {'s':>5} {'k':>3} {'true M_k':>18} {'F_k(N,s)':>18}")
    for p, q in pairs:
        big_n, s = p * q, p + q
        for k in (1, 2, 3, 4):
            true = gcd_moment_bruteforce(k, big_n)
            pred = moment_closed_form(k, big_n, s)
            print(f"{p:>4} {q:>4} {big_n:>6} {s:>5} {k:>3} {true:>18} {pred:>18}")
            assert true == pred
    print()
    print("Explicit low-order polynomials (verified symbolically in the paper):")
    print("  M_1 = 4N - 2s + 1")
    print("  M_2 = N^2 + 3N + 1 + (N-1)s - s^2")
    print("  M_3 = N^3 - 2N^2 + N s^2 + 3N s + N - s^3 - s + 1")
    print("  M_4 = N^4 - 3N^2 s - 2N^2 + N s^3 + 4N s^2 + N - s^4 - s + 1")
    p, q = 7, 13
    big_n, s = p * q, p + q
    checks = {
        1: 4 * big_n - 2 * s + 1,
        2: big_n**2 + 3 * big_n + 1 + (big_n - 1) * s - s**2,
        3: big_n**3 - 2 * big_n**2 + big_n * s**2 + 3 * big_n * s + big_n - s**3 - s + 1,
        4: (
            big_n**4
            - 3 * big_n**2 * s
            - 2 * big_n**2
            + big_n * s**3
            + 4 * big_n * s**2
            + big_n
            - s**4
            - s
            + 1
        ),
    }
    for k, val in checks.items():
        assert val == gcd_moment_bruteforce(k, big_n), k
    print(f"  all four verified at N = {big_n}, s = {s}.")


def demo_trace_recovery() -> None:
    banner("3.  Trace recovery and factorisation:  2s = 4N + 1 - M_1,  then split N")
    print(f"{'p':>4} {'q':>4} {'N':>7} {'M_1':>10} {'s recovered':>12} {'(p,q) recovered':>18}")
    for p, q in [(3, 5), (5, 11), (7, 13), (11, 23), (17, 31), (23, 41)]:
        big_n = p * q
        m1 = gcd_moment_bruteforce(1, big_n)
        s = trace_from_first_moment(big_n, m1)
        a, b = split_from_trace(big_n, s)
        print(f"{p:>4} {q:>4} {big_n:>7} {m1:>10} {s:>12} {str((a, b)):>18}")
        assert (a, b) == (p, q)
    print()
    print("The witness is complete but the scan costs Theta(N) gcd evaluations.")


def demo_closure() -> None:
    banner("4.  Closure: every higher moment is a function of N and the first moment")
    p, q = 11, 23
    big_n = p * q
    m1 = gcd_moment_bruteforce(1, big_n)
    s = trace_from_first_moment(big_n, m1)
    print(f"N = {big_n},  M_1 = {m1}  =>  s = {s}")
    print(f"{'k':>3} {'M_k from N and M_1':>26} {'true M_k':>26}")
    for k in range(1, 7):
        pred = moment_closed_form(k, big_n, s)
        true = gcd_moment_bruteforce(k, big_n)
        print(f"{k:>3} {pred:>26} {true:>26}")
        assert pred == true
    print()
    print("No moment carries information beyond the trace: the family is closed.")


def demo_witness_density() -> None:
    banner("5.  Witness density:  #{x < N : gcd(N,x) != 1} = p + q - 1")
    print(f"{'p':>4} {'q':>4} {'N':>7} {'counted':>9} {'p+q-1':>7} {'hit rate':>10}")
    for p, q in [(3, 5), (5, 11), (7, 13), (11, 23), (17, 31)]:
        big_n = p * q
        counted = sum(1 for x in range(big_n) if math.gcd(big_n, x) != 1)
        print(
            f"{p:>4} {q:>4} {big_n:>7} {counted:>9} {p + q - 1:>7} "
            f"{(p + q - 1) / big_n:>10.5f}"
        )
        assert counted == p + q - 1
    print()
    print("A uniform probe finds a nontrivial gcd with probability (p+q-1)/N: the")
    print("Theta(p+q) query threshold. For a 2048-bit modulus this is astronomically small.")


def demo_euler_product() -> None:
    banner("6.  Multiplicativity, the Euler product, and the two-sided bracket")
    print(f"{'n':>5} {'squarefree':>11} {'n^k+n-1':>12} {'M_k(n)':>12} {'Pi_k(n)':>12}  k = 2")
    for n in (2, 4, 6, 8, 9, 12, 15, 28, 30, 36):
        k = 2
        lo = local_factor(k, n)
        mid = gcd_moment_divisor_form(k, n)
        hi = prime_prod(k, n)
        print(f"{n:>5} {str(is_squarefree(n)):>11} {lo:>12} {mid:>12} {hi:>12}")
        assert lo <= mid <= hi
        assert (lo == mid) == is_prime(n)
        assert (mid == hi) == is_squarefree(n)
    print()
    print("Left equality holds exactly at the primes; right equality exactly at the")
    print("squarefree moduli.  Exact square deficiency (p^k+p-1)^2 - M_k(p^2) = (p-1)(p^k-1):")
    for p in (2, 3, 5, 7):
        for k in (1, 2, 3):
            lhs = local_factor(k, p) ** 2 - gcd_moment_divisor_form(k, p * p)
            rhs = (p - 1) * (p**k - 1)
            assert lhs == rhs, (p, k)
    print("  verified for p in {2,3,5,7}, k in {1,2,3}.")


def demo_refinement_lattice() -> None:
    banner("7.  The refinement lattice of a modulus: extremes are attained uniquely")
    for n in (28, 36, 60):
        facs = multiplicative_factorisations(n)
        k = 2
        vals = sorted(((factorisation_euler(k, f), f) for f in facs))
        print(f"\n  n = {n},  Omega(n) = {big_omega(n)},  k = {k}")
        for val, f in vals:
            tag = ""
            if f == [n]:
                tag = "  <- trivial factorisation (unique minimiser)"
            if sorted(f) == sorted(prime_factor_list(n)):
                tag = "  <- prime factorisation (unique maximiser)"
            print(f"    {str(f):>18}  E_2 = {val:>10}{tag}")
        assert vals[0][1] == [n]
        assert sorted(vals[-1][1]) == sorted(prime_factor_list(n))


def two_part_collisions(
    k: int, limit: int
) -> List[Tuple[int, Tuple[int, int], Tuple[int, int]]]:
    """All moduli n <= limit carrying two distinct two-part factorisations of equal moment."""
    out = []
    for n in range(2, limit + 1):
        pairs = [(a, n // a) for a in divisors(n) if 2 <= a <= n // a]
        for (a, b), (c, d) in combinations(pairs, 2):
            if factorisation_euler(k, [a, b]) == factorisation_euler(k, [c, d]):
                out.append((n, (a, b), (c, d)))
    return out


def demo_collision_census() -> None:
    banner("8.  Collision census: for which (k, n) do two factorisations share a moment?")
    limit = 2000
    print(f"  (a) two-part factorisations, n <= {limit}")
    for k in (1, 2, 3, 4, 5):
        cols = two_part_collisions(k, limit)
        listed = ", ".join(f"{n}: {a}*{b} = {c}*{d}" for n, (a, b), (c, d) in cols[:4])
        print(f"      k = {k}:  {len(cols)} collision(s)   {listed}")
        if k == 2:
            assert {c[0] for c in cols} == {28, 36}
        else:
            assert cols == []
    print()
    print("      Proved: at k = 2 the only two-part collisions among all moduli are")
    print("      28 = 2*14 = 4*7 and 36 = 2*18 = 3*12; at every other k >= 1 there are none.")

    limit2 = 400
    print()
    print(f"  (b) arbitrary factorisations into parts >= 2, n <= {limit2}")
    for k in (1, 2, 3, 4):
        collisions: List[Tuple[int, List[int], List[int]]] = []
        for n in range(2, limit2 + 1):
            seen: Dict[int, List[int]] = {}
            for f in multiplicative_factorisations(n):
                v = factorisation_euler(k, f)
                if v in seen and seen[v] != f:
                    collisions.append((n, seen[v], f))
                else:
                    seen[v] = f
        print(f"\n      k = {k}:  {len(collisions)} collision(s) with n <= {limit2}")
        for n, f, g in collisions[:4]:
            print(f"          n = {n:>4}  Omega = {big_omega(n)}   {f}  vs  {g}")
        if k == 1:
            assert min(c[0] for c in collisions) == 234
        for n, f, g in collisions:
            assert big_omega(n) >= 3
            if k != 2:
                assert big_omega(n) >= 4, (k, n, f, g)
    print()
    print("  Summary of the proved separation results:")
    print("    * Omega(n) <= 2 (in particular every semiprime): no collision at any k >= 1.")
    print("    * Omega(n) <= 3: no collision at k = 1 and none at any k >= 3.")
    print("    * Both bounds are sharp: 28 has Omega = 3 and collides at k = 2, and the")
    print("      smallest first-moment collision is 234 = 2*9*13 = 3*3*26, with Omega = 4.")


def demo_semiprime_inversion() -> None:
    banner("9.  Inverting a semiprime moment: the true factorisation is the unique match")
    for p, q in [(3, 5), (5, 11), (7, 13), (13, 17)]:
        big_n = p * q
        for k in (1, 2, 3, 5):
            observed = gcd_moment_bruteforce(k, big_n)
            matches = [
                (a, big_n // a)
                for a in divisors(big_n)
                if 2 <= a <= big_n // a
                and factorisation_euler(k, [a, big_n // a]) == observed
            ]
            assert matches == [(p, q)], (p, q, k, matches)
        print(f"  N = {big_n:>5}:  unique match at k = 1,2,3,5  ->  ({p}, {q})")
    print()
    print("  For a semiprime, every moment k >= 1 identifies the factorisation.")


def demo_cost_hierarchy() -> None:
    banner("10.  The cost hierarchy:  Var(gcd(N,U)^k) = Theta(N^{2k-1})")
    print(f"{'N':>7} {'k':>3} {'variance':>18} {'N^(2k-1)':>18} {'ratio':>8}")
    for p, q in [(11, 23), (17, 31), (23, 41)]:
        big_n = p * q
        for k in (1, 2, 3):
            var = gcd_variance(k, big_n)
            scale = float(big_n ** (2 * k - 1))
            print(f"{big_n:>7} {k:>3} {var:>18.3f} {scale:>18.3f} {var / scale:>8.4f}")
            assert scale - 16 * float(big_n ** (2 * k - 2)) <= var <= 4 * scale
    print()
    print("  Both bounds are proved:  N^{2k-1} - 16 N^{2k-2} <= Var <= 4 N^{2k-1}.")
    print("  Chebyshev then needs Omega(N^{2k-1}) samples at level k, versus O(N) at k = 1.")
    print("  Chebyshev sample counts for unit absolute accuracy at 99% confidence,")
    print("  and the proved separation  (N^2/8) * Var_1 <= Var_2  for N >= 32:")
    print(f"{'N':>7} {'k':>3} {'samples':>22} {'cost vs k = 1':>16}")
    for p, q in [(23, 41), (31, 61)]:
        big_n = p * q
        base = chebyshev_samples(1, big_n)
        for k in (1, 2, 3):
            cost = chebyshev_samples(k, big_n)
            print(f"{big_n:>7} {k:>3} {cost:>22.3e} {cost / base:>16.3e}")
        assert (
            float(big_n) ** 2 / 8.0 * gcd_variance(1, big_n) <= gcd_variance(2, big_n)
        )


def demo_sampling_reality_check() -> None:
    banner("11.  Reality check: random sampling of gcd(N, U) does not shortcut the scan")
    random.seed(20260814)
    p, q = 97, 101
    big_n = p * q
    true_s = p + q
    print(f"  N = {big_n} = {p} * {q},  true trace s = {true_s}")
    print(f"{'samples':>10} {'estimated s':>14} {'error':>10}")
    for m in (100, 1_000, 10_000, 100_000):
        total = sum(math.gcd(big_n, random.randrange(big_n)) for _ in range(m))
        est_m1 = total / m * big_n
        est_s = (4 * big_n + 1 - est_m1) / 2
        print(f"{m:>10} {est_s:>14.1f} {abs(est_s - true_s):>10.1f}")
    print()
    print("  The estimator is unbiased but its variance is dominated by the single")
    print("  residue x = 0 contributing N: only an exhaustive scan is reliable.")


def main() -> None:
    demo_divisor_form()
    demo_closed_form()
    demo_trace_recovery()
    demo_closure()
    demo_witness_density()
    demo_euler_product()
    demo_refinement_lattice()
    demo_collision_census()
    demo_semiprime_inversion()
    demo_cost_hierarchy()
    demo_sampling_reality_check()
    banner("All assertions passed.")


if __name__ == "__main__":
    main()
