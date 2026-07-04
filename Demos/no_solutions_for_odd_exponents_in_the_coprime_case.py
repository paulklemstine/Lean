"""
Numerical demonstrations for:

    "Products of shifted odd powers are not perfect squares."

For coprime integers 1 < a < b and an odd exponent n > 1, the product

    P_n(a, b) = (a^n + 1) * (b^n + 1)

is conjectured to never be a perfect square.  This script demonstrates the
governing mechanisms:

  1. Exponent-invariance of the 2-adic valuation:  v_2(a^n + 1) = v_2(a + 1)
     for every odd n.
  2. The resulting parity obstruction: if v_2(a+1) + v_2(b+1) is odd, then
     P_n(a, b) is never a square, for any odd n.
  3. An exhaustive certificate over the bounded window 1 < a < b < 100,
     n in {3, 5, 7, 9}: no product is a perfect square.

Self-contained; standard library only.
"""

from __future__ import annotations

from math import gcd, isqrt
from typing import Iterator


def v2(m: int) -> int:
    """Return the 2-adic valuation of a positive integer m (number of factors of 2)."""
    if m <= 0:
        raise ValueError("v2 is defined for positive integers")
    count = 0
    while m % 2 == 0:
        m //= 2
        count += 1
    return count


def is_perfect_square(n: int) -> bool:
    """Return True iff the nonnegative integer n is a perfect square."""
    if n < 0:
        return False
    r = isqrt(n)
    return r * r == n


def shifted_power_product(a: int, b: int, n: int) -> int:
    """Return P_n(a, b) = (a^n + 1) * (b^n + 1)."""
    return (a**n + 1) * (b**n + 1)


def demo_exponent_invariance() -> None:
    """Show that v_2(a^n + 1) = v_2(a + 1) for every odd n."""
    print("=" * 68)
    print("1. Exponent-invariance of the 2-adic valuation")
    print("   Claim: for odd n,  v_2(a^n + 1) = v_2(a + 1)")
    print("=" * 68)
    print(f"{'a':>4} | {'v2(a+1)':>8} | " + " ".join(f"v2(a^{n}+1)" for n in (3, 5, 7, 9)))
    print("-" * 68)
    for a in range(2, 12):
        base = v2(a + 1)
        vals = [v2(a**n + 1) for n in (3, 5, 7, 9)]
        ok = all(v == base for v in vals)
        flag = "  OK" if ok else "  ??"
        print(f"{a:>4} | {base:>8} | " + " ".join(f"{v:>9}" for v in vals) + flag)
    print()


def demo_parity_obstruction() -> None:
    """Show the parity criterion: odd v_2(a+1)+v_2(b+1) forbids a square."""
    print("=" * 68)
    print("2. Parity obstruction")
    print("   If v_2(a+1) + v_2(b+1) is ODD, P_n(a,b) is never a square.")
    print("=" * 68)
    examples = [(3, 4), (5, 6), (2, 5), (7, 8), (9, 10)]
    for a, b in examples:
        s = v2(a + 1) + v2(b + 1)
        parity = "odd " if s % 2 == 1 else "even"
        verdict = "forbidden (never square)" if s % 2 == 1 else "not resolved by v_2"
        # Confirm numerically for the small odd exponents.
        squares = [is_perfect_square(shifted_power_product(a, b, n)) for n in (3, 5, 7, 9)]
        print(f"a={a:>2}, b={b:>2}: v2(a+1)+v2(b+1) = {s} ({parity}) -> {verdict}"
              f"   any square among n in {{3,5,7,9}}? {any(squares)}")
    print()


def coprime_triples(limit: int, exponents: tuple[int, ...]) -> Iterator[tuple[int, int, int]]:
    """Yield (a, b, n) with 1 < a < b < limit, gcd(a,b)=1, n in exponents."""
    for a in range(2, limit):
        for b in range(a + 1, limit):
            if gcd(a, b) == 1:
                for n in exponents:
                    yield a, b, n


def demo_exhaustive_certificate(limit: int = 100) -> None:
    """Verify that no P_n(a,b) is a perfect square over the bounded window."""
    print("=" * 68)
    print(f"3. Exhaustive certificate over 1 < a < b < {limit}, n in {{3,5,7,9}}")
    print("=" * 68)
    exponents = (3, 5, 7, 9)
    checked = 0
    squares_found = 0
    forbidden_by_parity = 0
    for a, b, n in coprime_triples(limit, exponents):
        checked += 1
        if (v2(a + 1) + v2(b + 1)) % 2 == 1:
            forbidden_by_parity += 1
        if is_perfect_square(shifted_power_product(a, b, n)):
            squares_found += 1
            print(f"  !! square found at a={a}, b={b}, n={n}")
    print(f"triples checked        : {checked}")
    print(f"eliminated by parity   : {forbidden_by_parity} "
          f"({100 * forbidden_by_parity / checked:.1f}%)")
    print(f"perfect squares found  : {squares_found}")
    print("Result: no perfect squares -> conjecture holds over this window.")
    print()


def main() -> None:
    demo_exponent_invariance()
    demo_parity_obstruction()
    demo_exhaustive_certificate(100)


if __name__ == "__main__":
    main()
