"""
Power-Sum GCD Factoring and Carmichael Periodicity — numerical demonstrations.

This self-contained script demonstrates, by direct computation, every theorem of the
accompanying paper:

    F(N, k) = 1^k + 2^k + ... + N^k          (the power sum)
    g_N(k)  = gcd(F(N, k), N)                (the read-out)

Results demonstrated
--------------------
1.  Divisibility criterion:  for a prime r with r || N and k > 0,
        r | F(N, k)   <=>   (r - 1) does not divide k.
2.  Product formula (squarefree N, k > 0):
        gcd(F(N,k), N) = prod { r prime : r | N, (r-1) does not divide k }.
3.  Factor reveal:  gcd(F(pq, p-1), pq) = q whenever (q-1) does not divide (p-1).
4.  First hit:  g_N(k) = N for 0 < k < min(p-1, q-1), and g_N drops at the minimum.
5.  Carmichael periodicity:  g_N has least period lambda(N) = lcm_{r|N}(r-1),
    and g_N(k) = 1 exactly on the multiples of lambda(N).
6.  Korselt periodicity of the sum itself: F(N, k+lambda) = F(N, k) (mod N).
7.  Giuga closed form:  F(N,k) = -sum_{(r-1)|k} N/r  (mod N).
8.  Lattice law:  g_N(gcd(k,k')) = lcm(g_N(k), g_N(k')).
9.  Robustness:  Pollard's p-1 step has an explicit bad base at every even exponent,
    while the power-sum read-out succeeds at that same exponent.
10. Recovery identity:  p + q + lambda(N) * gcd(p-1, q-1) = N + 1, and the naive
    formula p + q = N - lambda(N) + 1 always strictly overshoots.

Run:  python3 demo.py
"""

from __future__ import annotations

from math import gcd, isqrt
from typing import Dict, Iterable, List, Tuple

# --------------------------------------------------------------------------- #
# Basic arithmetic helpers
# --------------------------------------------------------------------------- #


def lcm(a: int, b: int) -> int:
    """Least common multiple of two non-negative integers."""
    if a == 0 or b == 0:
        return 0
    return a // gcd(a, b) * b


def is_prime(n: int) -> bool:
    """Deterministic trial-division primality test (adequate for the sizes here)."""
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


def prime_factors(n: int) -> List[int]:
    """Sorted list of distinct prime factors of n >= 1."""
    factors: List[int] = []
    m = n
    d = 2
    while d * d <= m:
        if m % d == 0:
            factors.append(d)
            while m % d == 0:
                m //= d
        d += 1 if d == 2 else 2
    if m > 1:
        factors.append(m)
    return factors


def is_squarefree(n: int) -> bool:
    """True iff no prime square divides n."""
    m = n
    d = 2
    while d * d <= m:
        if m % (d * d) == 0:
            return False
        if m % d == 0:
            m //= d
            continue
        d += 1 if d == 2 else 2
    return True


def divisors(n: int) -> List[int]:
    """All positive divisors of n, ascending."""
    small: List[int] = []
    large: List[int] = []
    for d in range(1, isqrt(n) + 1):
        if n % d == 0:
            small.append(d)
            if d != n // d:
                large.append(n // d)
    return small + large[::-1]


# --------------------------------------------------------------------------- #
# The power sum and the read-out
# --------------------------------------------------------------------------- #


def power_sum_mod(N: int, k: int) -> int:
    """F(N, k) = sum_{a=1}^{N} a^k, reduced modulo N.  Cost: O(N log k)."""
    total = 0
    for a in range(1, N + 1):
        total = (total + pow(a, k, N)) % N
    return total


def power_sum_exact(N: int, k: int) -> int:
    """F(N, k) as an exact integer (only for small N, k)."""
    return sum(a ** k for a in range(1, N + 1))


def readout(N: int, k: int) -> int:
    """g_N(k) = gcd(F(N,k), N), computed with O(log N) memory."""
    return gcd(power_sum_mod(N, k), N)


def carmichael_lambda_squarefree(N: int) -> int:
    """lambda(N) = lcm over primes r | N of (r - 1)."""
    value = 1
    for r in prime_factors(N):
        value = lcm(value, r - 1)
    return value


def product_formula(N: int, k: int) -> int:
    """prod { r prime : r | N, (r-1) does not divide k } — predicted read-out."""
    prod = 1
    for r in prime_factors(N):
        if k % (r - 1) != 0:
            prod *= r
    return prod


def giuga_residue(N: int, k: int) -> int:
    """The predicted residue of F(N,k) mod N: -sum_{(r-1)|k} N/r."""
    s = 0
    for r in prime_factors(N):
        if k % (r - 1) == 0:
            s += N // r
    return (-s) % N


# --------------------------------------------------------------------------- #
# Pollard p-1 comparison
# --------------------------------------------------------------------------- #


def pollard_step(a: int, M: int, N: int) -> int:
    """One Pollard p-1 step: gcd(a^M - 1, N)."""
    return gcd((pow(a, M, N) - 1) % N, N)


def crt_bad_base(p: int, q: int) -> int:
    """The CRT element a = 1 (mod p), a = -1 (mod q): a bad base for every even M."""
    for a in range(2, p * q):
        if a % p == 1 and a % q == q - 1:
            return a
    raise ValueError("no bad base found (should not happen for distinct odd primes)")


# --------------------------------------------------------------------------- #
# Recovery from (N, lambda)
# --------------------------------------------------------------------------- #


def recover_factors_from_lambda(N: int, lam: int) -> Tuple[int, int] | None:
    """Recover p, q from N = pq and lambda(N) by searching the ambiguity g | lambda.

    Uses p + q = N + 1 - lambda * g with g = gcd(p-1, q-1), then solves the quadratic
    x^2 - (p+q) x + N = 0.  Cost: O(tau(lambda)) integer square roots.
    """
    for g in divisors(lam):
        s = N + 1 - lam * g
        if s <= 0:
            continue
        disc = s * s - 4 * N
        if disc < 0:
            continue
        root = isqrt(disc)
        if root * root != disc or (s + root) % 2 != 0:
            continue
        p = (s + root) // 2
        q = (s - root) // 2
        if p * q == N and is_prime(p) and is_prime(q):
            return (min(p, q), max(p, q))
    return None


# --------------------------------------------------------------------------- #
# Demonstrations
# --------------------------------------------------------------------------- #


def banner(title: str) -> None:
    print("\n" + "=" * 74)
    print(title)
    print("=" * 74)


def demo_readout_sequences() -> None:
    banner("1.  The read-out sequence g_N(k) = gcd(F(N,k), N)")
    for N in (15, 35, 33, 105):
        lam = carmichael_lambda_squarefree(N)
        seq = [readout(N, k) for k in range(1, 2 * lam + 2)]
        print(f"  N = {N:4d} = {' * '.join(map(str, prime_factors(N))):11s} "
              f"lambda(N) = {lam:3d}")
        print(f"        g_N(1..{2*lam+1}) = {seq}")
        first_one = next(k for k in range(1, 4 * lam) if readout(N, k) == 1)
        assert first_one == lam, "trivial locus must start at lambda(N)"
        assert all(readout(N, k + lam) == readout(N, k) for k in range(1, lam + 2))
        print(f"        least k with g_N(k) = 1 : {first_one}  (= lambda(N))  ✓")
        print(f"        g_N(k + lambda) = g_N(k) for all tested k          ✓")


def demo_product_formula() -> None:
    banner("2.  Product formula:  gcd(F(N,k),N) = prod { r | N : (r-1) does not divide k }")
    checked = 0
    for N in range(2, 200):
        if not is_squarefree(N):
            continue
        for k in range(1, 25):
            assert readout(N, k) == product_formula(N, k), (N, k)
            checked += 1
    print(f"  verified for every squarefree N < 200 and 1 <= k <= 24 "
          f"({checked} instances)  ✓")
    print("  sample:  N = 105 = 3*5*7")
    for k in (1, 2, 4, 6, 12):
        surviving = [r for r in prime_factors(105) if k % (r - 1) != 0]
        print(f"     k = {k:2d} : survivors {surviving!s:12s} "
              f"product {product_formula(105,k):3d}  read-out {readout(105,k):3d}")


def demo_factor_reveal() -> None:
    banner("3.  Factor reveal:  gcd(F(pq, p-1), pq) = q   when (q-1) does not divide (p-1)")
    pairs: Iterable[Tuple[int, int]] = [
        (3, 5), (3, 7), (5, 7), (5, 11), (7, 13), (11, 13), (13, 17), (97, 101)
    ]
    print(f"  {'p':>4} {'q':>4} {'N = pq':>8} {'k = p-1':>8} {'gcd':>6}   expected")
    for p, q in pairs:
        N = p * q
        assert (p - 1) % (q - 1) != 0, "hypothesis (q-1) ∤ (p-1) must hold"
        d = readout(N, p - 1)
        assert d == q
        print(f"  {p:4d} {q:4d} {N:8d} {p-1:8d} {d:6d}   {q}  ✓")


def demo_first_hit() -> None:
    banner("4.  First hit:  the read-out is uninformative below k* = min(p-1, q-1)")
    for p, q in [(5, 7), (7, 13), (11, 13), (13, 17)]:
        N, kstar = p * q, min(p - 1, q - 1)
        before = [readout(N, k) for k in range(1, kstar)]
        assert all(v == N for v in before)
        at = readout(N, kstar)
        assert at != N
        print(f"  N = {N:5d} = {p}*{q}:  g_N(k) = N for k < {kstar}; "
              f"g_N({kstar}) = {at} < N  ✓")


def demo_korselt_and_giuga() -> None:
    banner("5.  Korselt periodicity of F itself, and the Giuga closed form")
    for N in (15, 35, 105, 143):
        lam = carmichael_lambda_squarefree(N)
        for k in range(1, 8):
            assert power_sum_mod(N, k + lam) == power_sum_mod(N, k)
        print(f"  N = {N:4d}: F(N, k+{lam}) = F(N, k) (mod N) for k = 1..7  ✓")
        for k in range(1, 3 * lam + 1):
            assert power_sum_mod(N, k) == giuga_residue(N, k), (N, k)
        print(f"          F(N,k) = -sum_{{(r-1)|k}} N/r (mod N) for k = 1..{3*lam}  ✓")
    print("  worked example:  N = 35, k = 12 = lambda(35)")
    print(f"     F(35,12) mod 35 = {power_sum_mod(35,12)}  "
          f"= -(35/5 + 35/7) = -(7+5) = {(-12) % 35} (mod 35)  ✓")


def demo_lattice_law() -> None:
    banner("6.  Lattice law:  g_N(gcd(k,k')) = lcm(g_N(k), g_N(k'))")
    for N in (15, 35, 105, 165):
        for k in range(1, 20):
            for kp in range(1, 20):
                left = readout(N, gcd(k, kp))
                right = lcm(readout(N, k), readout(N, kp))
                assert left == right, (N, k, kp, left, right)
        print(f"  N = {N:4d}: verified for all 1 <= k, k' <= 19  ✓")
    print("  sample:  N = 105, k = 4, k' = 6, gcd = 2")
    print(f"     g(4) = {readout(105,4)}, g(6) = {readout(105,6)}, "
          f"lcm = {lcm(readout(105,4), readout(105,6))}, g(2) = {readout(105,2)}")


def demo_robustness() -> None:
    banner("7.  Robustness:  Pollard's p-1 has a bad base where the power sum succeeds")
    print(f"  {'p':>4} {'q':>4} {'N':>7} {'M = p-1':>8} {'bad base a':>11} "
          f"{'gcd(a^M-1,N)':>14} {'power-sum gcd':>14}")
    for p, q in [(3, 5), (5, 7), (5, 11), (7, 13), (11, 13)]:
        N, M = p * q, p - 1
        a = crt_bad_base(p, q)
        pollard = pollard_step(a, M, N)
        ours = readout(N, M)
        assert pollard == N, "the CRT element must be a Pollard bad base"
        print(f"  {p:4d} {q:4d} {N:7d} {M:8d} {a:11d} {pollard:14d} {ours:14d}")
    print("  Pollard returns the whole modulus (no information) at every row;")
    print("  the power sum returns a proper factor at every row.  ✓")


def demo_recovery_identity() -> None:
    banner("8.  Recovery:  p + q + lambda(N) * gcd(p-1, q-1) = N + 1")
    print(f"  {'p':>4} {'q':>4} {'N':>7} {'lambda':>7} {'g':>4} "
          f"{'p+q (true)':>11} {'naive N-λ+1':>12}")
    for p, q in [(3, 5), (5, 7), (5, 11), (7, 13), (11, 13), (13, 17), (97, 101)]:
        N = p * q
        lam = lcm(p - 1, q - 1)
        g = gcd(p - 1, q - 1)
        assert p + q + lam * g == N + 1
        naive = N - lam + 1
        assert naive > p + q, "the naive formula must strictly overshoot"
        print(f"  {p:4d} {q:4d} {N:7d} {lam:7d} {g:4d} {p+q:11d} {naive:12d}")
    print("  identity holds in every row; the naive formula overshoots in every row  ✓")
    print("\n  Recovering the factors from (N, lambda) by searching the ambiguity g:")
    for p, q in [(3, 5), (11, 13), (97, 101), (211, 223)]:
        N, lam = p * q, lcm(p - 1, q - 1)
        found = recover_factors_from_lambda(N, lam)
        print(f"     N = {N:7d}, lambda = {lam:6d}  ->  {found}   "
              f"{'✓' if found == (min(p,q), max(p,q)) else '✗'}")


def demo_complexity_profile() -> None:
    banner("9.  Complexity profile:  first informative exponent vs sqrt(N)")
    print(f"  {'N':>8} {'p':>5} {'q':>5} {'k* = min(p-1,q-1)':>19} {'sqrt(N)':>9} "
          f"{'evaluations x N':>16}")
    for p, q in [(11, 13), (31, 37), (97, 101), (211, 223)]:
        N, kstar = p * q, min(p - 1, q - 1)
        print(f"  {N:8d} {p:5d} {q:5d} {kstar:19d} {isqrt(N):9d} {kstar * N:16d}")
    print("  total work ~ k* * N ~ N^{3/2}: asymptotically worse than trial division,")
    print("  which is exactly the classical period-finding barrier.")


def main() -> None:
    print(__doc__.split("Run:")[0].strip())
    demo_readout_sequences()
    demo_product_formula()
    demo_factor_reveal()
    demo_first_hit()
    demo_korselt_and_giuga()
    demo_lattice_law()
    demo_robustness()
    demo_recovery_identity()
    demo_complexity_profile()
    banner("All demonstrations completed successfully.")


if __name__ == "__main__":
    main()
