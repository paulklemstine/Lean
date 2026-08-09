"""
Occurrences of numbers in Pascal's triangle: numerical demonstrations
=====================================================================

Self-contained numerical companion to the article and paper on Singmaster's
problem.  Every function is inlined; the only dependency is the Python
standard library.

For an integer t >= 2 let

    N(t) = # { (n, k) : 0 <= k <= n and C(n,k) = t }

be the *multiplicity* of t in Pascal's triangle.  Because C(t,1) = C(t,t-1) = t
and t >= 2, we always have N(t) >= 2.  The script demonstrates:

  1. Direct computation of N(t) and of the classical specimens
     N(2)=1, N(3)=N(5)=N(p)=2, N(6)=3, N(10)=4, N(120)=6, N(3003)=8.
  2. The sharp thresholds: 6, 10, 120, 3003 are the SMALLEST numbers of
     multiplicity >= 3, >= 4, >= 6, >= 8 respectively.
  3. The smoothness theorem  N(t) >= 3  ==>  p(p-1) <= 2t  for every prime p | t,
     and the hierarchy  N(t) >= 2m+2  ==>  C(p, m+1) <= t.
  4. The counting bound  #{t <= X : N(t) >= 3} <= (sqrt(2X)+2)(log2 X + 1),
     hence density one for multiplicity exactly two.
  5. The sharpened logarithmic bound
     N(t) <= log2 t + log2(2 log2 t + 1) + 1.
  6. The complete classification of adjacent repetitions
     C(n,k) = C(n-1,k+1): Lucas form (5n+1, 5(n-k)-3) = (L_{4j+9}, L_{4j+8}),
     Fibonacci form (n,k) = (F_{2i+4}F_{2i+5}, F_{2i+2}F_{2i+5}).
"""

from __future__ import annotations

from math import comb, isqrt
from typing import Dict, Iterator, List, Tuple

# ----------------------------------------------------------------------------
# 1. Multiplicity of a number in Pascal's triangle
# ----------------------------------------------------------------------------


def multiplicity(t: int) -> int:
    """Return N(t), the number of pairs (n,k) with 0 <= k <= n and C(n,k) = t.

    Valid for t >= 2.  The search is finite because an occurrence C(n,k) = t
    with 2 <= k <= n-2 forces n(n-1) <= 2t and 2^k <= t.
    """
    if t < 2:
        raise ValueError("multiplicity is only defined (and finite) for t >= 2")
    return len(occurrences(t))


def occurrences(t: int) -> List[Tuple[int, int]]:
    """All positions (n,k) of t in Pascal's triangle, sorted by row."""
    out = [(t, 1), (t, t - 1)]
    n = 4
    while n * (n - 1) <= 2 * t:
        for k in range(2, n // 2 + 1):
            c = comb(n, k)
            if c > t:
                break
            if c == t:
                out.append((n, k))
                if 2 * k != n:
                    out.append((n, n - k))
        n += 1
    return sorted(set(out))


# ----------------------------------------------------------------------------
# 2. Sharp thresholds: the least number of each multiplicity
# ----------------------------------------------------------------------------


def least_with_multiplicity_at_least(m: int, limit: int = 4000) -> int | None:
    """Smallest t in [2, limit] with N(t) >= m (None if there is none)."""
    for t in range(2, limit + 1):
        if multiplicity(t) >= m:
            return t
    return None


# ----------------------------------------------------------------------------
# 3. Smoothness theorem and the smoothness hierarchy
# ----------------------------------------------------------------------------


def prime_factors(t: int) -> List[int]:
    """The distinct prime factors of t, by trial division."""
    out: List[int] = []
    d, m = 2, t
    while d * d <= m:
        if m % d == 0:
            out.append(d)
            while m % d == 0:
                m //= d
        d += 1
    if m > 1:
        out.append(m)
    return out


def smoothness_certificate(t: int) -> Dict[str, object]:
    """Check p(p-1) <= 2t for every prime p | t, and the hierarchy level."""
    ps = prime_factors(t)
    mult = multiplicity(t)
    level = (mult - 2) // 2  # largest m with 2m+2 <= mult
    return {
        "t": t,
        "N(t)": mult,
        "primes": ps,
        "p(p-1) <= 2t": {p: (p * (p - 1), 2 * t) for p in ps},
        "hierarchy m": level,
        "C(p,m+1) <= t": {p: (comb(p, level + 1), t) for p in ps} if level >= 1 else {},
    }


def largest_prime_allowed(t: int, m: int) -> int:
    """Largest prime p that can divide t if N(t) >= 2m+2, i.e. max p with C(p,m+1) <= t."""
    p = m + 1
    while comb(p + 1, m + 1) <= t:
        p += 1
    return p


# ----------------------------------------------------------------------------
# 4. Counting bound and density one
# ----------------------------------------------------------------------------


def log2_floor(x: int) -> int:
    return x.bit_length() - 1


def count_high_multiplicity(X: int) -> int:
    """Exact count of t <= X with N(t) >= 3, via the interior-occurrence sieve.

    N(t) >= 3 holds iff t = C(n,k) for some 2 <= k <= n-2; such an occurrence
    obeys n(n-1) <= 2t <= 2X, so the search box is small.
    """
    values = set()
    n = 4
    while n * (n - 1) <= 2 * X:
        for k in range(2, n // 2 + 1):
            c = comb(n, k)
            if c > X:
                break
            values.add(c)
        n += 1
    return len(values)


def counting_bound(X: int) -> int:
    """(sqrt(2X) + 2)(log2 X + 1)."""
    return (isqrt(2 * X) + 2) * (log2_floor(X) + 1)


def sharp_log_bound(t: int) -> int:
    """log2 t + log2(2 log2 t + 1) + 1, the sharpened multiplicity bound."""
    L = log2_floor(t)
    return L + log2_floor(2 * L + 1) + 1


# ----------------------------------------------------------------------------
# 5. Adjacent repetitions: Lucas and Fibonacci parametrisations
# ----------------------------------------------------------------------------


def lucas(n: int) -> int:
    a, b = 2, 1  # L_0, L_1
    for _ in range(n):
        a, b = b, a + b
    return a


def fib(n: int) -> int:
    a, b = 0, 1
    for _ in range(n):
        a, b = b, a + b
    return a


def adjacent_from_lucas(j: int) -> Tuple[int, int]:
    """The j-th adjacent repetition from 5n+1 = L_{4j+9}, 5(n-k) = L_{4j+8} + 3."""
    n = (lucas(4 * j + 9) - 1) // 5
    u = (lucas(4 * j + 8) + 3) // 5
    return n, n - u


def adjacent_from_fibonacci(i: int) -> Tuple[int, int]:
    """The i-th adjacent repetition as (F_{2i+4}F_{2i+5}, F_{2i+2}F_{2i+5})."""
    return fib(2 * i + 4) * fib(2 * i + 5), fib(2 * i + 2) * fib(2 * i + 5)


def brute_force_adjacent(n_max: int) -> Iterator[Tuple[int, int]]:
    """All (n,k) with 1 <= k, k+2 <= n <= n_max and C(n,k) = C(n-1,k+1)."""
    for n in range(3, n_max + 1):
        for k in range(1, n - 1):
            if n * (k + 1) == (n - k) * (n - k - 1):
                yield (n, k)


def norm_form(x: int, y: int) -> int:
    """The norm form x^2 - xy - y^2 of the field of the golden ratio."""
    return x * x - x * y - y * y


# ----------------------------------------------------------------------------
# Demonstrations
# ----------------------------------------------------------------------------


def demo_classical_specimens() -> None:
    print("=" * 74)
    print("1. Multiplicities of the classical specimens")
    print("=" * 74)
    for t in [2, 3, 4, 5, 6, 7, 10, 11, 13, 20, 21, 120, 210, 3003]:
        occ = occurrences(t)
        print(f"  N({t:>5}) = {multiplicity(t)}   positions {occ}")
    print()
    print("  Every odd prime occurs exactly twice:")
    for p in [3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 97, 101]:
        assert multiplicity(p) == 2
    print("    verified for p = 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 97, 101")
    print()


def demo_sharp_thresholds() -> None:
    print("=" * 74)
    print("2. Sharp thresholds: the least number of each multiplicity")
    print("=" * 74)
    for m, expected in [(3, 6), (4, 10), (6, 120), (8, 3003)]:
        t = least_with_multiplicity_at_least(m)
        print(f"  least t with N(t) >= {m}:  {t}   (predicted {expected})")
        assert t == expected
    print()
    print("  General growth threshold  N(t) >= 2m+2  ==>  t >= C(2m+3, m+1):")
    for m in range(1, 5):
        print(f"    m = {m}: multiplicity >= {2*m+2} forces t >= C({2*m+3},{m+1})"
              f" = {comb(2*m+3, m+1)}")
    print()


def demo_smoothness() -> None:
    print("=" * 74)
    print("3. Smoothness: repetitive numbers have only small prime factors")
    print("=" * 74)
    for t in [6, 10, 120, 210, 3003]:
        cert = smoothness_certificate(t)
        print(f"  t = {t}, N(t) = {cert['N(t)']}, primes {cert['primes']}")
        for p, (lhs, rhs) in cert["p(p-1) <= 2t"].items():  # type: ignore[union-attr]
            assert lhs <= rhs
            print(f"      p = {p:>3}:  p(p-1) = {lhs:>6}  <=  2t = {rhs}")
    print()
    print("  Hierarchy applied to 3003 (N = 8 = 2*3+2, so m = 3):")
    print(f"      C(13,4) = {comb(13,4)} <= 3003, but C(18,4) = {comb(18,4)} > 3003,")
    print(f"      so every prime factor of 3003 is at most "
          f"{largest_prime_allowed(3003, 3)}; indeed 3003 = 3*7*11*13.")
    print()
    print("  Converse test: a number with one large prime factor occurs twice.")
    for c, p in [(1, 101), (2, 11), (3, 29), (5, 101)]:
        t = c * p
        assert multiplicity(t) == 2
        print(f"      t = {c}*{p} = {t:>5}: p > 2c+1 = {2*c+1}, so N(t) = 2  (checked)")
    print()


def demo_counting_and_density() -> None:
    print("=" * 74)
    print("4. Counting bound and density one for multiplicity two")
    print("=" * 74)
    print(f"  {'X':>9} {'#{t<=X : N(t)>=3}':>18} {'bound':>10} {'fraction':>12}")
    for X in [10**2, 10**3, 10**4, 10**5, 10**6]:
        exact = count_high_multiplicity(X)
        bound = counting_bound(X)
        assert exact <= bound
        print(f"  {X:>9} {exact:>18} {bound:>10} {exact / X:>12.6f}")
    print()
    print("  The fraction tends to 0: almost every integer occurs exactly twice.")
    print()


def demo_log_bound() -> None:
    print("=" * 74)
    print("5. The sharpened logarithmic bound on multiplicity")
    print("=" * 74)
    print(f"  {'t':>10} {'N(t)':>6} {'new bound':>11} {'old 2 log2 t':>14}")
    for t in [6, 10, 120, 3003, 10**4, 10**5, 10**6]:
        nt = multiplicity(t) if t <= 3003 else None
        new = sharp_log_bound(t)
        old = 2 * log2_floor(t)
        shown = f"{nt}" if nt is not None else "-"
        print(f"  {t:>10} {shown:>6} {new:>11} {old:>14}")
    print()
    print("  The new bound is strictly smaller than 2 log2 t once t >= 2^16:")
    for e in [16, 20, 32, 64]:
        t = 2 ** e
        assert sharp_log_bound(t) < 2 * log2_floor(t)
        print(f"      t = 2^{e:<3}: new = {sharp_log_bound(t):>3}  <  "
              f"2 log2 t = {2*log2_floor(t)}")
    print()


def demo_adjacent_classification() -> None:
    print("=" * 74)
    print("6. Complete classification of adjacent repetitions C(n,k) = C(n-1,k+1)")
    print("=" * 74)
    print("  Lucas parametrisation, Fibonacci parametrisation, and the value:")
    for i in range(4):
        n_l, k_l = adjacent_from_lucas(i)
        n_f, k_f = adjacent_from_fibonacci(i)
        assert (n_l, k_l) == (n_f, k_f)
        assert comb(n_l, k_l) == comb(n_l - 1, k_l + 1)
        assert n_l * (k_l + 1) == (n_l - k_l) * (n_l - k_l - 1)
        value = comb(n_l, k_l)
        digits = len(str(value))
        print(f"    i = {i}: (n,k) = ({n_l}, {k_l}),  5n+1 = L_{4*i+9} = "
              f"{lucas(4*i+9)},  value has {digits} digits")
    print()
    print("  Exhaustive search up to n = 5000 finds exactly these and no others:")
    found = list(brute_force_adjacent(5000))
    print(f"    {found}")
    predicted = [adjacent_from_fibonacci(i) for i in range(4)]
    assert found == predicted
    print()
    print("  Consecutive Lucas numbers solve x^2 - xy - y^2 = +-5:")
    for i in range(9):
        print(f"    (L_{i+1}, L_{i}) = ({lucas(i+1)}, {lucas(i)}):  "
              f"value = {norm_form(lucas(i+1), lucas(i))}")
    print()
    print("  Descent (x,y) -> (y, x-y) on a solution, flipping the sign each step:")
    x, y = lucas(10), lucas(9)
    while (x, y) != (1, 2):
        print(f"    ({x:>4}, {y:>4})  form = {norm_form(x, y):>3}")
        x, y = y, x - y
    print(f"    ({x:>4}, {y:>4})  form = {norm_form(x, y):>3}   <- bottom (L_1, L_0)")
    print()
    print("  Only the first adjacent repetition has value below 10^6:")
    print(f"    C(15,5) = C(14,6) = {comb(15,5)};  C(104,39) has "
          f"{len(str(comb(104,39)))} digits.")
    print()
    print("  3003 therefore sits in eight positions:")
    print(f"    {occurrences(3003)}")
    print()


def demo_cassini_bridge() -> None:
    print("=" * 74)
    print("7. The Cassini bridge between the Lucas and Fibonacci pictures")
    print("=" * 74)
    print("  Cassini: F_{a+1}^2 - F_a F_{a+2} = (-1)^a")
    for a in range(8):
        val = fib(a + 1) ** 2 - fib(a) * fib(a + 2)
        assert val == (-1) ** a
        print(f"    a = {a}: {fib(a+1)}^2 - {fib(a)}*{fib(a+2)} = {val}")
    print()
    print("  Dictionary:  L_{2a} = 5 F_a^2 + 2(-1)^a,  "
          "L_{2a+1} = 5 F_a F_{a+1} + (-1)^a")
    for a in range(7):
        assert lucas(2 * a) == 5 * fib(a) ** 2 + 2 * (-1) ** a
        assert lucas(2 * a + 1) == 5 * fib(a) * fib(a + 1) + (-1) ** a
        print(f"    a = {a}: L_{2*a} = {lucas(2*a)}, L_{2*a+1} = {lucas(2*a+1)}  (ok)")
    print()
    print("  Specialising a = 2i+4 turns the Lucas classification into the")
    print("  Fibonacci one:  5 F_{2i+4}F_{2i+5} + 1 = L_{4i+9}.")
    for i in range(4):
        lhs = 5 * fib(2 * i + 4) * fib(2 * i + 5) + 1
        assert lhs == lucas(4 * i + 9)
        print(f"    i = {i}: 5*{fib(2*i+4)}*{fib(2*i+5)} + 1 = {lhs} = L_{4*i+9}")
    print()


def main() -> None:
    demo_classical_specimens()
    demo_sharp_thresholds()
    demo_smoothness()
    demo_counting_and_density()
    demo_log_bound()
    demo_adjacent_classification()
    demo_cassini_bridge()
    print("All demonstrations completed successfully.")


if __name__ == "__main__":
    main()
