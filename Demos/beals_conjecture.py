"""
Beal's conjecture: numerical demonstrations of the structure theory.

This self-contained script illustrates, by direct computation, every result in the
accompanying paper that admits a numerical demonstration:

  1.  Non-vacuity: Beal solutions A^x + B^y = C^z (x, y, z >= 3) exist, and every one
      found has a common prime factor of A, B, C.
  2.  The three-way divisibility collapse: a prime dividing two of the bases divides
      the third; hence a solution without a common prime has pairwise coprime bases.
  3.  Sharpness: relaxing any single exponent to 2 produces genuine coprime solutions
      (7^2 + 2^5 = 3^4, 7^3 + 13^2 = 2^9, 2^7 + 17^3 = 71^2).
  4.  Quantitative hyperbolicity: 1/x + 1/y + 1/z <= 11/12 for every admissible triple
      once (3,3,3) is excluded by Fermat's Last Theorem for exponent 3.
  5.  The exponent count (A*B*C)^12 <= (C^z)^11 underlying the abc argument.
  6.  Radical exponent-blindness: rad(A^x B^y C^z) = rad(A B C), and abc-qualities.
  7.  Parity trichotomy and the mod-8 obstruction on coprime solutions.
  8.  The polynomial analogue: (3X^5)^3 + (6X^5)^3 = (3X^3)^5 shares the factor X.

Run with:  python3 demo.py
"""

from __future__ import annotations

from fractions import Fraction
from math import gcd, isqrt, log
from typing import Dict, Iterable, List, Optional, Sequence, Tuple

Solution = Tuple[int, int, int, int, int, int]  # (A, B, C, x, y, z)


# ----------------------------------------------------------------------------
# Elementary number theory helpers
# ----------------------------------------------------------------------------

def prime_factors(n: int) -> List[int]:
    """Return the sorted list of distinct primes dividing n >= 1 (empty for n = 1)."""
    if n < 1:
        raise ValueError("prime_factors requires n >= 1")
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


def radical(n: int) -> int:
    """rad(n): the product of the distinct primes dividing n; rad(1) = 1."""
    result = 1
    for p in prime_factors(n):
        result *= p
    return result


def common_prime(a: int, b: int, c: int) -> Optional[int]:
    """Return a prime dividing all of a, b, c, or None if none exists."""
    g = gcd(gcd(a, b), c)
    if g <= 1:
        return None
    return prime_factors(g)[0]


def perfect_power_table(limit: int, min_exponent: int = 3) -> Dict[int, Tuple[int, int]]:
    """Map every value C^z <= limit with C >= 1, z >= min_exponent to one pair (C, z)."""
    table: Dict[int, Tuple[int, int]] = {}
    base = 1
    while base ** min_exponent <= limit:
        value = base ** min_exponent
        exponent = min_exponent
        while value <= limit:
            table.setdefault(value, (base, exponent))
            value *= base
            exponent += 1
            if base == 1:  # 1^z = 1 for all z; record once
                break
        base += 1
    return table


# ----------------------------------------------------------------------------
# 1. Searching for Beal solutions
# ----------------------------------------------------------------------------

def search_beal_solutions(
    max_base: int = 40, max_exponent: int = 8, limit: int = 10 ** 12
) -> List[Solution]:
    """Enumerate solutions of A^x + B^y = C^z with x, y, z >= 3 and A^x + B^y <= limit."""
    powers = perfect_power_table(limit, min_exponent=3)
    found: List[Solution] = []
    for a in range(1, max_base + 1):
        for x in range(3, max_exponent + 1):
            ax = a ** x
            if ax > limit:
                break
            for b in range(1, max_base + 1):
                for y in range(3, max_exponent + 1):
                    by = b ** y
                    if ax + by > limit:
                        break
                    hit = powers.get(ax + by)
                    if hit is not None:
                        c, z = hit
                        found.append((a, b, c, x, y, z))
    return sorted(set(found))


def demo_solutions_have_common_prime() -> None:
    print("=" * 78)
    print("1.  Beal solutions exist -- and every one has a common prime factor")
    print("=" * 78)
    solutions = search_beal_solutions(max_base=30, max_exponent=7, limit=10 ** 10)
    print(f"    found {len(solutions)} solutions with bases <= 30, exponents 3..7\n")
    print(f"    {'A^x + B^y = C^z':<34}{'gcd(A,B)':>10}{'common prime':>16}")
    print("    " + "-" * 60)
    coprime_hits = 0
    for (a, b, c, x, y, z) in solutions[:16]:
        p = common_prime(a, b, c)
        eq = f"{a}^{x} + {b}^{y} = {c}^{z}"
        print(f"    {eq:<34}{gcd(a, b):>10}{str(p):>16}")
        if p is None:
            coprime_hits += 1
    for (a, b, c, x, y, z) in solutions:
        if common_prime(a, b, c) is None:
            coprime_hits += 1
    print(f"\n    counterexamples found (coprime bases): {coprime_hits}")
    print("    -> consistent with Beal's conjecture.\n")


# ----------------------------------------------------------------------------
# 2. The three-way divisibility collapse
# ----------------------------------------------------------------------------

def demo_divisibility_collapse() -> None:
    print("=" * 78)
    print("2.  Three-way collapse: a prime dividing two bases divides the third")
    print("=" * 78)
    examples: Sequence[Solution] = [
        (3, 6, 3, 3, 3, 5),
        (7, 7, 98, 6, 7, 3),
        (2, 8, 2, 9, 3, 10),
        (96, 192, 24, 3, 3, 5),
    ]
    for (a, b, c, x, y, z) in examples:
        assert a ** x + b ** y == c ** z, f"bad example {(a, b, c, x, y, z)}"
        p = common_prime(a, b, c)
        pairwise = (gcd(a, b), gcd(a, c), gcd(b, c))
        print(f"    {a}^{x} + {b}^{y} = {c}^{z}")
        print(f"        common prime = {p};  pairwise gcds = {pairwise}")
        for q in prime_factors(gcd(a, b)):
            assert c % q == 0
        print(f"        every prime dividing A and B also divides C:  verified")
    print()


# ----------------------------------------------------------------------------
# 3. Sharpness of the hypothesis x, y, z >= 3
# ----------------------------------------------------------------------------

def demo_sharpness() -> None:
    print("=" * 78)
    print("3.  Sharpness: dropping any single exponent to 2 breaks the conclusion")
    print("=" * 78)
    witnesses: Sequence[Tuple[Solution, str]] = [
        ((7, 2, 3, 2, 5, 4), "first exponent relaxed to 2"),
        ((7, 13, 2, 3, 2, 9), "middle exponent relaxed to 2"),
        ((2, 17, 71, 7, 3, 2), "last exponent relaxed to 2"),
    ]
    for (a, b, c, x, y, z), label in witnesses:
        assert a ** x + b ** y == c ** z
        p = common_prime(a, b, c)
        print(f"    {label}:")
        print(f"        {a}^{x} + {b}^{y} = {a**x} + {b**y} = {c**z} = {c}^{z}")
        print(f"        pairwise gcds = {(gcd(a,b), gcd(a,c), gcd(b,c))}, "
              f"common prime = {p}")
    print("    -> the threshold 3 is exactly right in every coordinate.\n")


# ----------------------------------------------------------------------------
# 4. Quantitative hyperbolicity
# ----------------------------------------------------------------------------

def exponent_sum(x: int, y: int, z: int) -> Fraction:
    """The exponent characteristic 1/x + 1/y + 1/z as an exact rational."""
    return Fraction(1, x) + Fraction(1, y) + Fraction(1, z)


def demo_hyperbolicity(max_exponent: int = 12) -> None:
    print("=" * 78)
    print("4.  Quantitative hyperbolicity: 1/x + 1/y + 1/z <= 11/12")
    print("=" * 78)
    bound = Fraction(11, 12)
    worst: List[Tuple[int, int, int]] = []
    violations = 0
    for x in range(3, max_exponent + 1):
        for y in range(3, max_exponent + 1):
            for z in range(3, max_exponent + 1):
                s = exponent_sum(x, y, z)
                if (x, y, z) == (3, 3, 3):
                    continue  # excluded by Fermat's Last Theorem for exponent 3
                if s > bound:
                    violations += 1
                if s == bound:
                    worst.append((x, y, z))
    print(f"    triples with 3 <= x,y,z <= {max_exponent}, excluding (3,3,3):")
    print(f"        violations of the bound 11/12 : {violations}")
    print(f"        triples attaining 11/12 exactly: {worst}")
    print(f"    the euclidean triple (3,3,3) has sum {exponent_sum(3,3,3)} = 1, "
          "removed by FLT_3.\n")


# ----------------------------------------------------------------------------
# 5. The exponent count (A B C)^12 <= (C^z)^11
# ----------------------------------------------------------------------------

def demo_exponent_count() -> None:
    print("=" * 78)
    print("5.  The exponent count (A*B*C)^12 <= N^11 with N = C^z")
    print("=" * 78)
    solutions = search_beal_solutions(max_base=20, max_exponent=6, limit=10 ** 9)
    print(f"    {'solution':<28}{'(ABC)^12 <= N^11':>20}{'log ratio':>14}")
    print("    " + "-" * 62)
    for (a, b, c, x, y, z) in solutions[:12]:
        n = c ** z
        lhs = (a * b * c) ** 12
        rhs = n ** 11
        ratio = log(lhs) / log(rhs) if rhs > 1 else 0.0
        eq = f"{a}^{x} + {b}^{y} = {c}^{z}"
        print(f"    {eq:<28}{str(lhs <= rhs):>20}{ratio:>14.4f}")
        assert lhs <= rhs
    print("    (the log ratio is 12*s/11 with s = 1/x+1/y+1/z <= 11/12, so it is <= 1)\n")


# ----------------------------------------------------------------------------
# 6. Radicals and abc quality
# ----------------------------------------------------------------------------

def abc_quality(a: int, b: int, c: int) -> float:
    """q(a,b,c) = log c / log rad(abc) for a coprime triple a + b = c."""
    r = radical(a * b * c)
    if r <= 1:
        return float("inf")
    return log(c) / log(r)


def demo_radicals_and_quality() -> None:
    print("=" * 78)
    print("6.  Radicals are blind to exponents; abc quality of Beal solutions")
    print("=" * 78)
    print("    rad(A^x B^y C^z) = rad(A B C):")
    for (a, b, c, x, y, z) in [(3, 6, 3, 3, 3, 5), (7, 7, 98, 6, 7, 3), (2, 8, 2, 9, 3, 10)]:
        left = radical(a ** x * b ** y * c ** z)
        right = radical(a * b * c)
        print(f"        {a}^{x} + {b}^{y} = {c}^{z}:  rad(lhs) = {left}, "
              f"rad(ABC) = {right}, equal = {left == right}")
    print("\n    abc quality q = log c / log rad(abc) for famous coprime triples:")
    triples = [(1, 8, 9), (5, 27, 32), (1, 4374, 4375), (2, 6436341, 6436343),
               (32, 49, 81), (343, 169, 512), (128, 4913, 5041)]
    for (a, b, c) in triples:
        assert a + b == c and gcd(a, b) == 1
        print(f"        {a:>9} + {b:>9} = {c:>9}   rad = {radical(a*b*c):>9}   "
              f"q = {abc_quality(a, b, c):.5f}")
    print("    the abc conjecture asserts limsup q = 1; only finitely many triples")
    print("    should have q > 1 + eps for each eps > 0.\n")


# ----------------------------------------------------------------------------
# 7. Parity trichotomy and the mod-8 obstruction
# ----------------------------------------------------------------------------

def demo_parity_and_mod8(max_base: int = 60, max_exponent: int = 6,
                         limit: int = 10 ** 9) -> None:
    print("=" * 78)
    print("7.  Parity trichotomy and the mod-8 obstruction (coprime solutions)")
    print("=" * 78)
    checked = 0
    for a in range(1, max_base + 1):
        for b in range(1, max_base + 1):
            if gcd(a, b) != 1:
                continue
            for x in range(3, max_exponent + 1):
                ax = a ** x
                if ax > limit:
                    break
                for y in range(3, max_exponent + 1):
                    by = b ** y
                    if ax + by > limit:
                        break
                    s = ax + by
                    parities = (a % 2 == 0, b % 2 == 0, s % 2 == 0)
                    # exactly one of A, B, and (any C with C^z = s) is even
                    assert sum(parities) == 1, (a, b, x, y)
                    if s % 8 == 0 and x % 2 == 0 and y % 2 == 0:
                        raise AssertionError("mod-8 obstruction violated")
                    checked += 1
    print(f"    checked {checked} coprime pairs (A^x, B^y) with bases <= {max_base},")
    print(f"    exponents 3..{max_exponent}:")
    print("        exactly one of A, B, C even  : always")
    print("        A^x + B^y = 0 mod 8 with x,y both even : never observed")
    print("    (an odd number to an even power is 1 mod 8, so the sum is 2 mod 8,")
    print("     while C even with z >= 3 forces C^z = 0 mod 8.)\n")


# ----------------------------------------------------------------------------
# 8. The polynomial analogue
# ----------------------------------------------------------------------------

Poly = Tuple[Fraction, ...]  # coefficients, lowest degree first


def poly_mul(p: Poly, q: Poly) -> Poly:
    out = [Fraction(0)] * (len(p) + len(q) - 1)
    for i, pi in enumerate(p):
        for j, qj in enumerate(q):
            out[i + j] += pi * qj
    return tuple(out)


def poly_pow(p: Poly, n: int) -> Poly:
    result: Poly = (Fraction(1),)
    for _ in range(n):
        result = poly_mul(result, p)
    return result


def poly_add(p: Poly, q: Poly) -> Poly:
    n = max(len(p), len(q))
    return tuple(
        (p[i] if i < len(p) else Fraction(0)) + (q[i] if i < len(q) else Fraction(0))
        for i in range(n)
    )


def poly_str(p: Poly) -> str:
    terms = [f"{c}X^{i}" for i, c in enumerate(p) if c != 0]
    return " + ".join(reversed(terms)) if terms else "0"


def x_valuation(p: Poly) -> int:
    """The multiplicity of the irreducible factor X in a nonzero polynomial."""
    for i, c in enumerate(p):
        if c != 0:
            return i
    raise ValueError("zero polynomial")


def demo_polynomial_analogue() -> None:
    print("=" * 78)
    print("8.  The polynomial analogue is a theorem: (3X^5)^3 + (6X^5)^3 = (3X^3)^5")
    print("=" * 78)
    zero = Fraction(0)
    a: Poly = tuple([zero] * 5 + [Fraction(3)])   # 3 X^5
    b: Poly = tuple([zero] * 5 + [Fraction(6)])   # 6 X^5
    c: Poly = tuple([zero] * 3 + [Fraction(3)])   # 3 X^3
    lhs = poly_add(poly_pow(a, 3), poly_pow(b, 3))
    rhs = poly_pow(c, 5)
    print(f"    a = {poly_str(a)},  b = {poly_str(b)},  c = {poly_str(c)}")
    print(f"    a^3 + b^3 = {poly_str(lhs)}")
    print(f"    c^5       = {poly_str(rhs)}")
    print(f"    identity holds: {lhs == rhs}")
    print(f"    multiplicity of the common irreducible factor X: "
          f"a -> {x_valuation(a)}, b -> {x_valuation(b)}, c -> {x_valuation(c)}")
    print("    -> a, b, c share the irreducible factor X, exactly as the theorem")
    print("       (over a field of characteristic zero) demands.\n")


# ----------------------------------------------------------------------------
# 9. Small-box exhaustive verification
# ----------------------------------------------------------------------------

def demo_small_box() -> None:
    print("=" * 78)
    print("9.  Exhaustive verification: no coprime solution in the small box")
    print("=" * 78)
    hits = 0
    tested = 0
    for a in range(1, 11):
        for b in range(1, 11):
            if gcd(a, b) != 1:
                continue
            for x in range(3, 6):
                for y in range(3, 6):
                    s = a ** x + b ** y
                    for c in range(1, 41):
                        for z in range(3, 6):
                            tested += 1
                            if c ** z == s:
                                hits += 1
    print(f"    tested {tested} tuples with A,B <= 10, C <= 40, 3 <= x,y,z <= 5")
    print(f"    coprime solutions found: {hits}")
    print("    -> Beal's conjecture holds throughout this box.\n")


def main() -> None:
    print()
    print("#" * 78)
    print("#  BEAL'S CONJECTURE:  A^x + B^y = C^z  with  x, y, z >= 3")
    print("#  numerical demonstrations of the structure theory")
    print("#" * 78)
    print()
    demo_solutions_have_common_prime()
    demo_divisibility_collapse()
    demo_sharpness()
    demo_hyperbolicity()
    demo_exponent_count()
    demo_radicals_and_quality()
    demo_parity_and_mod8()
    demo_polynomial_analogue()
    demo_small_box()
    print("all demonstrations completed successfully.")


if __name__ == "__main__":
    main()
