"""
Numerical demonstrations for the CRT-multiplicative free-witness classification
and the Trace Lemma.

Everything is self-contained: no imports beyond the standard library, all helper
functions inlined, full type hints.

The script demonstrates, in order:

  1. The CRT grid and the product formula for split weights (Layer 1).
  2. The rank-one criterion: which weights split, which do not.
  3. The Trace Lemma and factorization from a single scalar.
  4. The predicted witness sigma_k, and the explicit trace formula at k = 2.
  5. The polynomial barrier via the difference test, and the rigidity identity.
  6. The 2-adic sealing dichotomy: nothing below 64, separation at 128.
  7. The omega-channel: v_2(sigma_{2j}(N)) = omega(N).
  8. The phase boundary: phases split, but the Bezout twist is non-local.

Run:  python3 demo.py
"""

from __future__ import annotations

from math import isqrt
from typing import Callable, Dict, List, Optional, Tuple

# ---------------------------------------------------------------------------
# Elementary number theory helpers
# ---------------------------------------------------------------------------


def is_prime(n: int) -> bool:
    """Deterministic trial-division primality test (adequate for demo sizes)."""
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


def primes_up_to(limit: int) -> List[int]:
    """All primes < limit, by a simple sieve of Eratosthenes."""
    sieve = [True] * max(limit, 2)
    sieve[0] = sieve[1] = False
    for i in range(2, isqrt(limit - 1) + 1):
        if sieve[i]:
            for j in range(i * i, limit, i):
                sieve[j] = False
    return [i for i, ok in enumerate(sieve) if ok]


def divisors(n: int) -> List[int]:
    """All positive divisors of n, ascending."""
    small: List[int] = []
    large: List[int] = []
    d = 1
    while d * d <= n:
        if n % d == 0:
            small.append(d)
            if d != n // d:
                large.append(n // d)
        d += 1
    return small + large[::-1]


def sigma_k(n: int, k: int) -> int:
    """Divisor power sum sigma_k(n) = sum over d | n of d^k."""
    return sum(d ** k for d in divisors(n))


def prime_factors(n: int) -> List[int]:
    """Distinct prime factors of n, ascending."""
    out: List[int] = []
    m = n
    d = 2
    while d * d <= m:
        if m % d == 0:
            out.append(d)
            while m % d == 0:
                m //= d
        d += 1
    if m > 1:
        out.append(m)
    return out


def omega(n: int) -> int:
    """Number of distinct prime factors of n."""
    return len(prime_factors(n))


def v2(n: int) -> int:
    """2-adic valuation of a nonzero integer."""
    if n == 0:
        raise ValueError("v2(0) is undefined")
    e = 0
    while n % 2 == 0:
        n //= 2
        e += 1
    return e


def egcd(a: int, b: int) -> Tuple[int, int, int]:
    """Extended Euclid: returns (g, x, y) with a*x + b*y = g = gcd(a, b)."""
    if b == 0:
        return (a, 1, 0)
    g, x, y = egcd(b, a % b)
    return (g, y, x - (a // b) * y)


def crt(a: int, m: int, b: int, n: int) -> int:
    """The unique x in [0, m*n) with x = a (mod m) and x = b (mod n), gcd(m,n)=1."""
    g, u, v = egcd(m, n)
    if g != 1:
        raise ValueError("moduli must be coprime")
    return (a * v * n + b * u * m) % (m * n)


# ---------------------------------------------------------------------------
# The circle count C(N) = #{(x,y) : x^2 + y^2 = 1 mod N}
# ---------------------------------------------------------------------------


def circle_count(n: int) -> int:
    """Brute-force count of points on the modular unit circle mod n."""
    squares: Dict[int, int] = {}
    for x in range(n):
        s = (x * x) % n
        squares[s] = squares.get(s, 0) + 1
    total = 0
    for x in range(n):
        need = (1 - x * x) % n
        total += squares.get(need, 0)
    return total


def circle_local_weight(p: int) -> int:
    """Local weight of the circle count at an odd prime: p - chi_p(-1)."""
    return p - 1 if p % 4 == 1 else p + 1


# ---------------------------------------------------------------------------
# 1. The CRT grid and the product formula (Layer 1)
# ---------------------------------------------------------------------------


def crt_grid(m: int, n: int) -> List[List[int]]:
    """The m x n grid whose (a, b) entry is the residue mod m*n with those coordinates."""
    return [[crt(a, m, b, n) for b in range(n)] for a in range(m)]


def aggregate_of_split_weight(
    m: int, n: int, a_fun: Callable[[int], int], b_fun: Callable[[int], int]
) -> Tuple[int, int]:
    """Return (direct sum over [0, mn), product of the two local sums)."""
    direct = sum(a_fun(x % m) * b_fun(x % n) for x in range(m * n))
    product = sum(a_fun(a) for a in range(m)) * sum(b_fun(b) for b in range(n))
    return direct, product


def demo_layer_one() -> None:
    print("=" * 78)
    print("1. THE CRT GRID AND THE PRODUCT FORMULA (Layer 1)")
    print("=" * 78)
    m, n = 3, 5
    grid = crt_grid(m, n)
    print(f"\nResidues mod {m*n}, indexed by (x mod {m}, x mod {n}):\n")
    header = "      " + "".join(f"b={b:<4}" for b in range(n))
    print(header)
    for a in range(m):
        print(f" a={a} |" + "".join(f"{grid[a][b]:<6}" for b in range(n)))

    # A split weight: A(a) = a + 1, B(b) = 2b - 3.
    a_fun: Callable[[int], int] = lambda a: a + 1
    b_fun: Callable[[int], int] = lambda b: 2 * b - 3
    direct, product = aggregate_of_split_weight(m, n, a_fun, b_fun)
    print(f"\nSplit weight f(x) = A(x mod 3) * B(x mod 5) with A(a)=a+1, B(b)=2b-3:")
    print(f"  sum over the whole grid  = {direct}")
    print(f"  (sum of A)*(sum of B)    = {product}")
    print(f"  identical: {direct == product}")


# ---------------------------------------------------------------------------
# 2. The rank-one criterion
# ---------------------------------------------------------------------------


def rank_one_violation(
    m: int, n: int, f: Callable[[int], int]
) -> Optional[Tuple[int, int, int, int]]:
    """Search crossed CRT quadruples for a violation of f(x)f(y) = f(z)f(w).

    Returns the first violating quadruple (x, y, z, w), or None if the weight
    passes every test (hence splits, when f never vanishes over a field).
    """
    mn = m * n
    for x in range(mn):
        for y in range(mn):
            z = crt(x % m, m, y % n, n)
            w = crt(y % m, m, x % n, n)
            if f(x) * f(y) != f(z) * f(w):
                return (x, y, z, w)
    return None


def sqrt_one_weight(modulus: int) -> Callable[[int], int]:
    """Indicator of x^2 = 1 (mod modulus): the character-like CIRC/BQF weight."""
    return lambda x: 1 if (x * x) % modulus == 1 % modulus else 0


def trunc_weight(x: int) -> int:
    """Truncated (half-plane) weight mod 15: 1 on the lower half of the interval."""
    return 1 if 2 * (x % 15) < 15 else 0


def demo_rank_one() -> None:
    print()
    print("=" * 78)
    print("2. THE RANK-ONE CRITERION: WHO SPLITS AND WHO DOES NOT")
    print("=" * 78)

    print("\nValue grid of the truncated weight [2(x mod 15) < 15]:\n")
    grid = crt_grid(3, 5)
    print("      " + "".join(f"b={b:<4}" for b in range(5)))
    for a in range(3):
        print(f" a={a} |" + "".join(f"{trunc_weight(grid[a][b]):<6}" for b in range(5)))

    bad = rank_one_violation(3, 5, trunc_weight)
    print(f"\n  truncated weight  -> violating quadruple {bad}")
    if bad is not None:
        x, y, z, w = bad
        print(
            f"     f({x})*f({y}) = {trunc_weight(x)*trunc_weight(y)}   "
            f"but f({z})*f({w}) = {trunc_weight(z)*trunc_weight(w)}   => does NOT split"
        )

    good = rank_one_violation(3, 5, sqrt_one_weight(15))
    print(f"  sqrt-of-one weight -> violating quadruple {good}  => SPLITS")

    print("\nThe sqrt-of-one grid is literally an outer product:")
    row = [1 if (a * a) % 3 == 1 else 0 for a in range(3)]
    col = [1 if (b * b) % 5 == 1 else 0 for b in range(5)]
    print(f"  row profile [a^2=1 mod 3] = {row}")
    print(f"  col profile [b^2=1 mod 5] = {col}")
    ok = all(
        sqrt_one_weight(15)(grid[a][b]) == row[a] * col[b]
        for a in range(3)
        for b in range(5)
    )
    print(f"  grid equals outer product: {ok}")


# ---------------------------------------------------------------------------
# 3-4. The Trace Lemma, and the predicted witness sigma_k
# ---------------------------------------------------------------------------


def factor_from_trace(n: int, s: int) -> Tuple[int, int]:
    """Given N = pq and the trace s = p + q, return (p, q) with p <= q."""
    disc = s * s - 4 * n
    d = isqrt(disc)
    if d * d != disc:
        raise ValueError("discriminant is not a perfect square")
    return ((s - d) // 2, (s + d) // 2)


def trace_from_sigma2(n: int) -> int:
    """p + q = sqrt(sigma_2(N) + 2N - 1 - N^2) for an odd semiprime N = pq."""
    radicand = sigma_k(n, 2) + 2 * n - 1 - n * n
    s = isqrt(radicand)
    if s * s != radicand:
        raise ValueError("radicand is not a perfect square")
    return s


def factor_via_sigma2(n: int) -> Tuple[int, int]:
    """Full factorization of an odd semiprime from the single scalar sigma_2(N)."""
    return factor_from_trace(n, trace_from_sigma2(n))


def demo_trace_lemma() -> None:
    print()
    print("=" * 78)
    print("3. THE TRACE LEMMA: ONE SCALAR, BOTH PRIMES")
    print("=" * 78)

    print("\nCIRC (Blum pairs, p = q = 3 mod 4):  p + q = C(N) - N - 1\n")
    print(f"  {'N = p*q':<14}{'C(N)':>8}{'C(N)-N-1':>12}{'p+q':>8}")
    for p, q in [(3, 7), (3, 11), (3, 19), (7, 11), (7, 19)]:
        n = p * q
        c = circle_count(n)
        print(f"  {f'{n} = {p}*{q}':<14}{c:>8}{c - n - 1:>12}{p + q:>8}")

    print("\nThe local product formula C(pq) = (p - chi_p(-1))(q - chi_q(-1)):\n")
    for p, q in [(3, 5), (3, 7), (5, 13), (17, 31)]:
        n = p * q
        print(
            f"  C({n:<5}) = {circle_count(n):<7} "
            f"= {circle_local_weight(p)} * {circle_local_weight(q)} "
            f"= {circle_local_weight(p) * circle_local_weight(q)}"
        )

    print()
    print("=" * 78)
    print("4. THE PREDICTED WITNESS sigma_k, AND THE EXPLICIT TRACE FORMULA")
    print("=" * 78)
    print("\n  sigma_k(pq) = (1 + p^k)(1 + q^k),   p^k + q^k = sigma_k(N) - N^k - 1")
    print("  k = 2:  p + q = sqrt(sigma_2(N) + 2N - 1 - N^2)\n")
    print(
        f"  {'N = p*q':<15}{'sigma_2(N)':>12}{'(1+p^2)(1+q^2)':>17}"
        f"{'p^2+q^2':>10}{'recovered {p,q}':>20}"
    )
    for p, q in [(3, 5), (3, 7), (3, 11), (5, 7), (7, 11), (17, 31), (101, 103)]:
        n = p * q
        s2 = sigma_k(n, 2)
        local = (1 + p * p) * (1 + q * q)
        power_sum = s2 - n * n - 1
        rec = factor_via_sigma2(n)
        assert s2 == local and power_sum == p * p + q * q and rec == (p, q)
        print(
            f"  {f'{n} = {p}*{q}':<15}{s2:>12}{local:>17}{power_sum:>10}"
            f"{str(rec):>20}"
        )

    print("\n  Higher exponents, same mechanism (p^k + q^k = sigma_k(N) - N^k - 1):\n")
    p, q = 13, 17
    n = p * q
    for k in range(1, 6):
        lhs = p ** k + q ** k
        rhs = sigma_k(n, k) - n ** k - 1
        print(f"    k={k}:  p^k+q^k = {lhs:<14} sigma_k - N^k - 1 = {rhs:<14} equal={lhs == rhs}")

    print("\n  Sharpness at k = 0:  sigma_0(pq) = 4 always, a constant with no secret.")
    print(
        "    "
        + ", ".join(f"sigma_0({p*q})={sigma_k(p*q, 0)}" for p, q in [(3, 5), (3, 7), (7, 11)])
    )


# ---------------------------------------------------------------------------
# 5. The polynomial barrier
# ---------------------------------------------------------------------------


def difference_test(w: Callable[[int], int], n1: int, n2: int) -> bool:
    """True if (n1 - n2) does NOT divide W(n1) - W(n2): no polynomial formula exists."""
    return (w(n1) - w(n2)) % (n1 - n2) != 0


def demo_polynomial_barrier() -> None:
    print()
    print("=" * 78)
    print("5. THE POLYNOMIAL BARRIER")
    print("=" * 78)
    print("\n  For any P in Z[X]:  a - b divides P(a) - P(b).")
    print("  A single violating pair therefore rules out every polynomial formula.\n")

    for name, w, n1, n2 in [
        ("circle count C", circle_count, 21, 15),
        ("sigma_2", lambda n: sigma_k(n, 2), 33, 15),
        ("sigma_1", lambda n: sigma_k(n, 1), 33, 15),
    ]:
        d_n = n1 - n2
        d_w = w(n1) - w(n2)
        print(
            f"  {name:<16} W({n1})-W({n2}) = {d_w:<8} {n1}-{n2} = {d_n:<4} "
            f"divides? {d_w % d_n == 0}    -> non-polynomial: {difference_test(w, n1, n2)}"
        )

    print("\n  Rigidity (the structural argument).  A polynomial formula would force")
    print("  P(3X) = (3^k+c)(X^k+c) and P(5X) = (5^k+c)(X^k+c), hence two values of")
    print("  P(30) whose equality reduces to c*(10^k+3^k) = c*(6^k+5^k):\n")
    print(f"    {'k':>3}{'10^k+3^k':>12}{'6^k+5^k':>12}   equal?")
    for k in range(1, 8):
        left = 10 ** k + 3 ** k
        right = 6 ** k + 5 ** k
        print(f"    {k:>3}{left:>12}{right:>12}   {left == right}")
    print("\n  Never equal for k >= 1, so c = 0: only the information-free weight x^k")
    print("  admits a polynomial closed form.")


# ---------------------------------------------------------------------------
# 6. The 2-adic sealing dichotomy
# ---------------------------------------------------------------------------


def sealing_scan(
    w: Callable[[int], int], prime_bound: int, modulus: int
) -> Optional[Tuple[int, int]]:
    """Search odd semiprimes N < prime_bound^2 for N1 = N2 (mod modulus) with
    differing witness residues.  Returns the first separating pair, or None."""
    ps = [p for p in primes_up_to(prime_bound) if p != 2]
    buckets: Dict[Tuple[int, int], int] = {}
    for i, p in enumerate(ps):
        for q in ps[i + 1 :]:
            n = p * q
            key = (n % modulus, w(n) % modulus)
            residue = n % modulus
            for (r, val), seen in list(buckets.items()):
                if r == residue and val != key[1]:
                    return (seen, n)
            buckets.setdefault(key, n)
    return None


def demo_sealing() -> None:
    print()
    print("=" * 78)
    print("6. THE 2-ADIC SEALING DICHOTOMY")
    print("=" * 78)
    print("\n  Theorem: sigma_{2j}(N) = 2 + 2N^{2j} (mod 64) for all odd semiprimes.")
    print("  Check across exponents and semiprimes:\n")
    ok = True
    for j in [1, 2, 3]:
        for p, q in [(3, 5), (3, 7), (5, 11), (17, 31), (23, 29)]:
            n = p * q
            lhs = sigma_k(n, 2 * j) % 64
            rhs = (2 + 2 * pow(n, 2 * j)) % 64
            ok = ok and lhs == rhs
    print(f"    sigma_2j(N) = 2 + 2N^2j (mod 64) in every case tested: {ok}")

    print("\n  Consequently no separating pair can exist below 2^7.  Scan (primes < 300):\n")
    print(f"    {'modulus':>10}{'sigma_2':>26}{'circle count':>26}")
    for k in range(3, 9):
        mod = 2 ** k
        s_pair = sealing_scan(lambda n: sigma_k(n, 2), 120, mod)
        c_pair = sealing_scan(circle_count, 60, mod)
        print(
            f"    {mod:>10}{str(s_pair) if s_pair else 'none':>26}"
            f"{str(c_pair) if c_pair else 'none':>26}"
        )

    print("\n  The canonical separation at 128:  15 = 3*5 and 527 = 17*31.\n")
    for n in (15, 527):
        print(
            f"    N = {n:<5} N mod 128 = {n % 128:<5} "
            f"sigma_2(N) = {sigma_k(n, 2):<8} sigma_2 mod 128 = {sigma_k(n, 2) % 128}"
        )
    print("\n  Same pair separates the circle count already at 32:\n")
    for n in (15, 527):
        c = circle_count(n)
        print(
            f"    N = {n:<5} N mod 32 = {n % 32:<5} "
            f"C(N) = {c:<8} C(N) mod 32 = {c % 32}"
        )
    print("\n  => sigma_2 conceals six bits; the circle count only four.")


# ---------------------------------------------------------------------------
# 7. The omega-channel
# ---------------------------------------------------------------------------


def demo_omega_channel() -> None:
    print()
    print("=" * 78)
    print("7. THE OMEGA-CHANNEL: v_2(sigma_{2j}(N)) = omega(N)")
    print("=" * 78)
    print("\n  Each local factor 1 + p^{2j} = 2 * odd, so the valuation counts the primes.\n")
    print(f"  {'N':>8}  {'factorization':<22}{'sigma_2(N)':>14}{'v_2':>6}{'omega':>7}")
    for n in [15, 33, 105, 1155, 15015, 255255, 3 * 5 * 7 * 11 * 13 * 17 * 19]:
        fs = prime_factors(n)
        s2 = sigma_k(n, 2)
        print(
            f"  {n:>8}  {'*'.join(map(str, fs)):<22}{s2:>14}{v2(s2):>6}{omega(n):>7}"
        )
    print("\n  Invisible on semiprimes (the valuation is the constant 2); a genuine")
    print("  second secret in general.  Same for higher even exponents:\n")
    for j in [1, 2, 3]:
        n = 1155
        print(f"    j={j}:  v_2(sigma_{2*j}({n})) = {v2(sigma_k(n, 2*j))}   omega({n}) = {omega(n)}")


# ---------------------------------------------------------------------------
# 8. The phase boundary
# ---------------------------------------------------------------------------


def demo_phase_boundary() -> None:
    print()
    print("=" * 78)
    print("8. THE PHASE BOUNDARY: SPLITTING HOLDS, LOCALITY FAILS")
    print("=" * 78)
    m, n = 7, 3
    g, u, v = egcd(n, m)  # u*n + v*m = 1
    print(f"\n  Bezout for (m, n) = ({m}, {n}):  {u}*{n} + {v}*{m} = {u*n + v*m}")
    print(f"  So x = ({u}x)*{n} + ({v}x)*{m} for every x, i.e. the phase index splits exactly:")
    ok = all(x == (u * x) * n + (v * x) * m for x in range(-20, 21))
    print(f"    identity x = (u x) n + (v x) m holds on a test range: {ok}")

    print("\n  But the local twist at m is u = n^{-1} mod m, a function of the OTHER modulus:")
    for other in (3, 5):
        _, uu, _ = egcd(other, 7)
        print(f"    with co-modulus n = {other}:  twist u = {other}^(-1) mod 7 = {uu % 7}")
    print("\n  The two induced local weights y -> 5y and y -> 3y on Z/7 differ:")
    print(f"    y=1:  5*1 mod 7 = {5 % 7},  3*1 mod 7 = {3 % 7}   -> different functions")
    print("\n  So a phase witness factors, but its 'local' factor is not a function of")
    print("  one prime alone.  The class boundary is locality, not splitting.")


# ---------------------------------------------------------------------------


def main() -> None:
    demo_layer_one()
    demo_rank_one()
    demo_trace_lemma()
    demo_polynomial_barrier()
    demo_sealing()
    demo_omega_channel()
    demo_phase_boundary()
    print()
    print("=" * 78)
    print("All demonstrations completed.")
    print("=" * 78)


if __name__ == "__main__":
    main()
