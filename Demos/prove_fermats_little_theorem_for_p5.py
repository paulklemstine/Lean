"""
demo.py -- Numerical demonstrations for the fifth-power congruence modulo five
and its Pythagorean consequences.

Results demonstrated:
  1. For every integer a, 5 | a^5 - a   (Fermat's little theorem, p = 5).
  2. The residue table of squares modulo 5 is {0, 1, 4}.
  3. Every Pythagorean triple (a, b, c) with a^2 + b^2 = c^2 contains an
     entry divisible by 5; moreover 60 | a*b*c.
  4. The stronger universal divisor 30 of a^5 - a, and the general modulus
     of a^k - a as the product of primes p with (p-1) | (k-1).

Self-contained: standard library only, fully type-hinted.
"""

from __future__ import annotations

from typing import List, Tuple


# ---------------------------------------------------------------------------
# 1. The main congruence: 5 | a^5 - a
# ---------------------------------------------------------------------------
def divides_five_pow_five_sub_self(a: int) -> bool:
    """Return True iff 5 divides a**5 - a (always True mathematically)."""
    return (a ** 5 - a) % 5 == 0


def cofactor_pow_five(a: int) -> int:
    """Return k with a**5 - a == 5 * k, i.e. the explicit multiple-of-5 witness."""
    value = a ** 5 - a
    assert value % 5 == 0
    return value // 5


def demo_main_congruence(lo: int = -20, hi: int = 20) -> None:
    print("=== 1. 5 | a^5 - a for all integers ===")
    all_ok = all(divides_five_pow_five_sub_self(a) for a in range(lo, hi + 1))
    print(f"Checked a in [{lo}, {hi}]: all divisible by 5 -> {all_ok}")
    for a in (2, 3, 7, -3):
        print(f"  a={a:>3}: a^5 - a = {a**5 - a:>8} = 5 * {cofactor_pow_five(a)}")
    print()


# ---------------------------------------------------------------------------
# 2. Quadratic residues modulo 5
# ---------------------------------------------------------------------------
def quadratic_residues_mod(m: int) -> List[int]:
    """Return the sorted list of distinct quadratic residues modulo m."""
    return sorted({(x * x) % m for x in range(m)})


def demo_square_table() -> None:
    print("=== 2. Squares modulo 5 ===")
    for x in range(5):
        print(f"  {x}^2 = {x*x:>2} ≡ {(x*x) % 5} (mod 5)")
    print(f"  Quadratic residues mod 5: {quadratic_residues_mod(5)}")
    print(f"  Non-residues mod 5: {sorted(set(range(5)) - set(quadratic_residues_mod(5)))}")
    print()


# ---------------------------------------------------------------------------
# 3. Pythagorean triples: the guaranteed multiple of five and divisor 60
# ---------------------------------------------------------------------------
def generate_pythagorean_triples(limit: int) -> List[Tuple[int, int, int]]:
    """Return primitive-and-imprimitive triples (a,b,c) with a<b<c<=limit."""
    triples: List[Tuple[int, int, int]] = []
    for a in range(1, limit + 1):
        for b in range(a + 1, limit + 1):
            c2 = a * a + b * b
            c = int(c2 ** 0.5)
            if c * c == c2 and c <= limit:
                triples.append((a, b, c))
    return triples


def five_witness(triple: Tuple[int, int, int]) -> int:
    """Return the first entry of the triple divisible by 5 (guaranteed to exist)."""
    for x in triple:
        if x % 5 == 0:
            return x
    raise ValueError("No multiple of 5 -- contradicts the theorem!")


def demo_pythagorean(limit: int = 50) -> None:
    print("=== 3. Pythagorean triples always contain a multiple of 5, and 60 | abc ===")
    triples = generate_pythagorean_triples(limit)
    all_have_five = all(any(x % 5 == 0 for x in t) for t in triples)
    all_div_60 = all((t[0] * t[1] * t[2]) % 60 == 0 for t in triples)
    print(f"Triples with c <= {limit}: {len(triples)} found")
    print(f"  Every triple has an entry divisible by 5: {all_have_five}")
    print(f"  Every product a*b*c divisible by 60:      {all_div_60}")
    for t in triples[:6]:
        prod = t[0] * t[1] * t[2]
        print(f"  {t}: 5-witness = {five_witness(t):>2}, abc = {prod} = 60 * {prod // 60}")
    print()


# ---------------------------------------------------------------------------
# 4. General fixed-power modulus: product of primes p with (p-1) | (k-1)
# ---------------------------------------------------------------------------
def is_prime(n: int) -> bool:
    if n < 2:
        return False
    d = 2
    while d * d <= n:
        if n % d == 0:
            return False
        d += 1
    return True


def universal_modulus(k: int) -> int:
    """Product of all primes p with (p-1) | (k-1); the sharp divisor of a^k - a."""
    m = 1
    for p in range(2, k + 1):
        if is_prime(p) and (k - 1) % (p - 1) == 0:
            m *= p
    return m


def demo_general_modulus() -> None:
    print("=== 4. Universal modulus of a^k - a ===")
    for k in (2, 3, 5, 7, 9, 13):
        m = universal_modulus(k)
        # empirical confirmation over a range of a
        ok = all((a ** k - a) % m == 0 for a in range(-30, 31))
        print(f"  k={k:>2}: universal modulus = {m:>4}  (empirically confirmed: {ok})")
    print("  Note: for k=5 the modulus is 30, strengthening 5 | a^5 - a.")
    print()


if __name__ == "__main__":
    demo_main_congruence()
    demo_square_table()
    demo_pythagorean()
    demo_general_modulus()
