#!/usr/bin/env python3
"""
Three Structural Barrier Theorems for Integer Factorization
===========================================================

Numerical demonstrations of three unconditional obstructions to structural
factoring of a semiprime N = p*q.

  Barrier I  (algebraic).  For every polynomial f with integer coefficients and
             every prime p dividing N:  p | f(N)  <=>  p | f(0).
             Hence gcd(f(N), N) = gcd(f(0), N): the invariant's dependence on N
             cancels completely.  A fixed f can ever expose only the primes
             dividing f(0) -- at most log2|f(0)| of them -- and if f splits
             N = p*q then min(p, q) <= |f(0)|.

  Barrier II (symmetry).  A quantity D(p, q) is a function of the product N = p*q
             if and only if D is symmetric.  Antisymmetric data (the gap p - q,
             "return the left factor") is therefore never recoverable from N.
             Conversely min(p, q) and p + q are symmetric, hence abstractly
             determined by N: the barrier is a well-definedness obstruction, not
             a hardness theorem.

  Barrier III (holomorphic rigidity).  An entire function F vanishing at two
             distinct points a != b factors as F(z) = (z - a)(z - b)G(z) with G
             entire; if the zero set is exactly {a, b} then G never vanishes off
             {a, b}.  So an analytic device whose zeros are the prime factors IS
             the factor polynomial in disguise.  Moreover the zero set of a
             nonzero entire function is countable and has planar measure zero,
             so random search finds it with probability zero.

  Escape route.  Pollard's p-1 method does split semiprimes -- but only because
             its exponent grows with the input.  For a FIXED exponent m the
             quantity a^m - 1 is a constant, i.e. a constant polynomial, and
             Barrier I applies verbatim.

Run:  python3 demo.py
Only the Python standard library is used.
"""

from __future__ import annotations

import cmath
import math
import random
from typing import Callable, Dict, Iterable, List, Sequence, Tuple

# ---------------------------------------------------------------------------
# Small arithmetic helpers (all inlined; no third-party dependencies)
# ---------------------------------------------------------------------------


def is_prime(n: int) -> bool:
    """Deterministic primality test, adequate for the sizes used here."""
    if n < 2:
        return False
    for small in (2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37):
        if n % small == 0:
            return n == small
    d, s = n - 1, 0
    while d % 2 == 0:
        d //= 2
        s += 1
    for a in (2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37):
        x = pow(a, d, n)
        if x in (1, n - 1):
            continue
        for _ in range(s - 1):
            x = x * x % n
            if x == n - 1:
                break
        else:
            return False
    return True


def primes_below(limit: int) -> List[int]:
    """All primes strictly below `limit`, by a simple sieve."""
    sieve = [True] * limit
    sieve[0:2] = [False, False]
    for i in range(2, int(limit ** 0.5) + 1):
        if sieve[i]:
            for j in range(i * i, limit, i):
                sieve[j] = False
    return [i for i, ok in enumerate(sieve) if ok]


def prime_factors(n: int) -> List[int]:
    """The distinct prime factors of |n| (empty for n = 0, by convention)."""
    n = abs(n)
    if n == 0:
        return []
    out: List[int] = []
    d = 2
    while d * d <= n:
        if n % d == 0:
            out.append(d)
            while n % d == 0:
                n //= d
        d += 1 if d == 2 else 2
    if n > 1:
        out.append(n)
    return out


def poly_eval(coeffs: Sequence[int], x: int) -> int:
    """Horner evaluation of the polynomial with coefficients [c0, c1, ..., cd]."""
    acc = 0
    for c in reversed(coeffs):
        acc = acc * x + c
    return acc


def poly_str(coeffs: Sequence[int]) -> str:
    """Human-readable rendering of a polynomial given by ascending coefficients."""
    terms: List[str] = []
    for k in range(len(coeffs) - 1, -1, -1):
        c = coeffs[k]
        if c == 0:
            continue
        if k == 0:
            terms.append(f"{c:+d}")
        elif k == 1:
            terms.append(f"{c:+d}x")
        else:
            terms.append(f"{c:+d}x^{k}")
    return " ".join(terms).lstrip("+") or "0"


def poly_witness(coeffs: Sequence[int], N: int) -> int:
    """The gcd witness gcd(f(N), N) produced by the polynomial invariant f."""
    return math.gcd(poly_eval(coeffs, N), N)


def splits(coeffs: Sequence[int], N: int) -> bool:
    """True iff the gcd witness is a nontrivial divisor of N."""
    w = poly_witness(coeffs, N)
    return 1 < w < N


def revealed_primes(coeffs: Sequence[int]) -> List[int]:
    """The primes a fixed invariant can ever expose: the prime factors of f(0)."""
    return prime_factors(poly_eval(coeffs, 0))


# ---------------------------------------------------------------------------
# Demonstration 1: Barrier I, the collapse gcd(f(N), N) = gcd(f(0), N)
# ---------------------------------------------------------------------------


def demo_barrier_one_collapse() -> None:
    print("=" * 74)
    print("BARRIER I (algebraic).  gcd(f(N), N) = gcd(f(0), N) for every f in Z[x]")
    print("=" * 74)

    families: Dict[str, List[int]] = {
        "x^2 + 5x + 6": [6, 5, 1],
        "x^3 - 7x + 12": [12, -7, 0, 1],
        "3x^5 + 2x - 30": [-30, 2, 0, 0, 0, 3],
        "x^2 + 1": [1, 0, 1],
        "x": [0, 1],
        "x^2 + 210": [210, 0, 1],
    }

    small = primes_below(60)
    semiprimes = [
        (p, q, p * q) for i, p in enumerate(small) for q in small[i + 1:]
    ]
    print(f"Sweeping {len(semiprimes)} semiprimes N = pq with p < q < 60.\n")

    header = f"{'invariant f':<18}{'f(0)':>7}{'splits':>9}{'primes ever revealed':>26}"
    print(header)
    print("-" * len(header))
    total_checks = 0
    collapse_failures = 0
    for name, coeffs in families.items():
        n_split = 0
        seen: set[int] = set()
        for p, q, N in semiprimes:
            total_checks += 1
            if poly_witness(coeffs, N) != math.gcd(poly_eval(coeffs, 0), N):
                collapse_failures += 1
            if splits(coeffs, N):
                n_split += 1
                for r in (p, q):
                    if poly_eval(coeffs, N) % r == 0:
                        seen.add(r)
        shown = "{" + ", ".join(map(str, sorted(seen))) + "}" if seen else "(none)"
        print(f"{name:<18}{poly_eval(coeffs, 0):>7}{n_split:>9}{shown:>26}")

    print(f"\nCollapse identity checked in {total_checks} cases; failures: {collapse_failures}.")
    for name, coeffs in families.items():
        assert set(revealed_primes(coeffs)) >= {
            r
            for p, q, N in semiprimes
            for r in (p, q)
            if splits(coeffs, N) and poly_eval(coeffs, N) % r == 0
        }, name
    print("Every prime ever revealed divides f(0), exactly as the barrier predicts.")


def demo_barrier_one_quantitative() -> None:
    print()
    print("-" * 74)
    print("Quantitative form: if f splits N = pq then min(p, q) <= |f(0)|;")
    print("and a fixed f can expose at most log2|f(0)| distinct primes ever.")
    print("-" * 74)

    families = {
        "x^2 + 5x + 6": [6, 5, 1],
        "x^2 + 210": [210, 0, 1],
        "3x^5 + 2x - 30": [-30, 2, 0, 0, 0, 3],
    }
    small = primes_below(200)
    for name, coeffs in families.items():
        c0 = abs(poly_eval(coeffs, 0))
        budget = int(math.log2(c0)) if c0 > 1 else 0
        worst = 0
        for i, p in enumerate(small):
            for q in small[i + 1:]:
                if splits(coeffs, p * q):
                    worst = max(worst, min(p, q))
        card = len(revealed_primes(coeffs))
        print(
            f"  f = {name:<16} |f(0)| = {c0:<5} "
            f"largest min(p,q) ever split = {worst:<5} (<= {c0}); "
            f"#revealed = {card} <= log2|f(0)| = {budget}"
        )
        assert worst <= c0 and card <= budget

    print("\n  Cryptographic consequence: to split a 2048-bit RSA modulus whose")
    print("  factors are 1024 bits each, a polynomial invariant needs a constant")
    print("  term of at least 1024 bits -- and writing it down already names a factor.")


def demo_no_universal_family() -> None:
    print()
    print("-" * 74)
    print("No finite family of polynomial invariants is universal.")
    print("-" * 74)
    family = {
        "x^2 + 5x + 6": [6, 5, 1],
        "x^3 - 7x + 12": [12, -7, 0, 1],
        "3x^5 + 2x - 30": [-30, 2, 0, 0, 0, 3],
        "x^2 + 210": [210, 0, 1],
    }
    B = max(abs(poly_eval(c, 0)) for c in family.values())
    print(f"  Family bound B = max |f(0)| = {B}.")
    p = next(x for x in range(B + 2, 10 * B) if is_prime(x))
    q = next(x for x in range(p + 1, 20 * B) if is_prime(x))
    N = p * q
    print(f"  Defeating modulus: N = {p} * {q} = {N} (both primes exceed B).")
    for name, coeffs in family.items():
        w = poly_witness(coeffs, N)
        print(f"    f = {name:<16} gcd(f(N), N) = {w}  -> {'SPLIT' if 1 < w < N else 'no split'}")
        assert not (1 < w < N)
    print("  Every member of the family fails, as guaranteed.")


# ---------------------------------------------------------------------------
# Demonstration 2: Barrier II, symmetry
# ---------------------------------------------------------------------------


def demo_barrier_two_symmetry() -> None:
    print()
    print("=" * 74)
    print("BARRIER II (symmetry).  D(p,q) is a function of N = pq  <=>  D is symmetric")
    print("=" * 74)

    quantities: List[Tuple[str, Callable[[int, int], int], bool]] = [
        ("p + q", lambda p, q: p + q, True),
        ("min(p, q)", lambda p, q: min(p, q), True),
        ("|p - q|", lambda p, q: abs(p - q), True),
        ("p - q  (gap)", lambda p, q: p - q, False),
        ("p  (left factor)", lambda p, q: p, False),
    ]
    pairs = [(3, 5), (5, 7), (7, 13), (11, 101)]
    print(f"{'quantity D(p,q)':<20}{'symmetric?':>12}{'function of N?':>18}   witness")
    print("-" * 74)
    for name, D, expected in quantities:
        sym = all(D(p, q) == D(q, p) for p, q in pairs)
        assert sym == expected, name
        if sym:
            witness = "-"
        else:
            p, q = next((p, q) for p, q in pairs if D(p, q) != D(q, p))
            witness = f"D({p},{q})={D(p,q)} but D({q},{p})={D(q,p)}, same N={p*q}"
        print(f"{name:<20}{str(sym):>12}{('YES' if sym else 'NO'):>18}   {witness}")

    print("\n  The transposition (p, q) -> (q, p) fixes N, so every function of N is")
    print("  blind to it.  Conversely unique factorization makes N determine the")
    print("  unordered pair, so every symmetric quantity IS a function of N: e.g.")
    for p, q in pairs:
        print(f"    N = {p*q:<6} determines  p+q = {p+q:<5} and min(p,q) = {min(p,q)}")
    print("  -- which is why the barrier forbids well-definedness, not hardness.")


# ---------------------------------------------------------------------------
# Demonstration 3: Barrier III, holomorphic rigidity
# ---------------------------------------------------------------------------


def demo_barrier_three_rigidity() -> None:
    print()
    print("=" * 74)
    print("BARRIER III (holomorphic rigidity).  Zeros at p and q force the factor")
    print("polynomial (z - p)(z - q) to divide the device inside the entire functions")
    print("=" * 74)

    p, q = 61, 97
    N = p * q

    def F(z: complex) -> complex:
        """An entire 'device' whose zero set is exactly {p, q}: (z-p)(z-q)e^z."""
        return (z - p) * (z - q) * cmath.exp(z / 200.0)

    def cofactor(z: complex) -> complex:
        """The entire cofactor G with F(z) = (z - p)(z - q) G(z)."""
        return cmath.exp(z / 200.0)

    print(f"  Device F(z) = (z - {p})(z - {q})e^(z/200), zeros exactly at {p} and {q}.")
    print(f"  F({p}) = {F(p):.3e},  F({q}) = {F(q):.3e}")
    print("  Recovered cofactor G is nonvanishing off the zero set:")
    for z in (0.0 + 0j, 10 + 5j, p + q + 1, 300 - 40j):
        g = cofactor(z)
        rebuilt = (z - p) * (z - q) * g
        print(
            f"    z = {z!s:>14}  |G(z)| = {abs(g):.6f}  "
            f"reconstruction error = {abs(rebuilt - F(z)):.2e}"
        )
        assert abs(g) > 0 and abs(rebuilt - F(z)) < 1e-6 * max(1.0, abs(F(z)))

    print("\n  Writing F down required knowing p and q: the 'analytic' content is a unit.")

    print()
    print("  Null-set obstruction: the zero set of a nonzero entire function is")
    print("  countable, hence of planar measure zero.  Random search for a zero:")
    random.seed(20240812)
    trials = 200_000
    hits = 0
    tol = 1e-9
    for _ in range(trials):
        z = complex(random.uniform(0, 200), random.uniform(-100, 100))
        if abs(F(z)) < tol:
            hits += 1
    area = 200 * 200
    print(f"    sampled {trials} points uniformly from a square of area {area}")
    print(f"    points with |F(z)| < {tol}: {hits}   (empirical hit rate {hits/trials:.1e})")
    print("    theoretical hit probability: exactly 0")
    assert hits == 0

    print()
    print("  Arithmetic form of the circularity (integral devices).  If an integer")
    print("  polynomial vanishes at a prime factor p of N, then p divides its")
    print("  constant term, so the device is at least as large as the secret:")
    for coeffs, label in (([-N, 0, 1], "x^2 - N"), ([p * q, -(p + q), 1], "(x-p)(x-q)")):
        c0 = poly_eval(coeffs, 0)
        roots = [r for r in (p, q) if poly_eval(coeffs, r) == 0]
        print(
            f"    f = {label:<12} f(0) = {c0:<8} prime roots {roots}  "
            f"and indeed max root {max(roots) if roots else 0} <= |f(0)| = {abs(c0)}"
        )
        for r in roots:
            assert r <= abs(c0)


# ---------------------------------------------------------------------------
# Demonstration 4: the escape route -- Pollard's p-1 and growing exponents
# ---------------------------------------------------------------------------


def pollard_witness(a: int, m: int, N: int) -> int:
    """The p-1 style gcd witness gcd(a^m - 1, N)."""
    return math.gcd(pow(a, m, N) - 1, N)


def demo_escape_growing_exponent() -> None:
    print()
    print("=" * 74)
    print("THE ESCAPE ROUTE.  Pollard's p-1 works -- only because m grows with N")
    print("=" * 74)

    print("  Correctness: if (p-1) | m, p does not divide a, and q does not divide")
    print("  a^m - 1, then gcd(a^m - 1, N) = p exactly.")
    for (p, q, a, m) in [(5, 7, 2, 4), (13, 31, 2, 12), (41, 103, 3, 40)]:
        N = p * q
        w = pollard_witness(a, m, N)
        print(f"    N = {p}*{q} = {N:<6} a = {a}, m = {m}  ->  gcd = {w}   (p = {p})")
        assert w == p

    print("\n  Failure mode: if m is a multiple of both p-1 and q-1 the witness")
    print("  returns all of N and nothing is learned.")
    for (p, q, a, m) in [(3, 5, 2, 4), (5, 13, 2, 12)]:
        N = p * q
        w = pollard_witness(a, m, N)
        print(f"    N = {p}*{q} = {N:<6} a = {a}, m = {m}  ->  gcd = {w}   (= N)")
        assert w == N

    print("\n  But a FIXED exponent is a constant polynomial: a^m - 1 does not depend")
    print("  on N at all, so Barrier I applies and some semiprime defeats it.")
    a, m = 2, 12
    c = a ** m - 1
    print(f"    a = {a}, m = {m}:  a^m - 1 = {c}, prime factors {prime_factors(c)}")
    p = next(x for x in range(c + 2, 10 * c) if is_prime(x))
    q = next(x for x in range(p + 1, 20 * c) if is_prime(x))
    N = p * q
    w = pollard_witness(a, m, N)
    print(f"    defeating modulus N = {p} * {q} = {N}: gcd = {w} (trivial)")
    assert w == 1
    print("    All the power of the method lives in letting m grow with the input.")


# ---------------------------------------------------------------------------


def main() -> None:
    demo_barrier_one_collapse()
    demo_barrier_one_quantitative()
    demo_no_universal_family()
    demo_barrier_two_symmetry()
    demo_barrier_three_rigidity()
    demo_escape_growing_exponent()
    print()
    print("=" * 74)
    print("All demonstrations completed; every assertion held.")
    print("=" * 74)


if __name__ == "__main__":
    main()
