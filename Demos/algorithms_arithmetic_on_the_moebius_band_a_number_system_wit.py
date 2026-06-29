#!/usr/bin/env python3
"""
Algorithms for the Möbius Ring ℤ√1 = ℤ[ε]/(ε² - 1).

Type-hinted implementations of key algorithms.
"""

from dataclasses import dataclass
from typing import Optional


@dataclass(frozen=True)
class MoebiusInt:
    """Element of the Möbius ring ℤ√1 = ℤ[ε]/(ε²-1)."""
    re: int
    im: int

    def __add__(self, other: 'MoebiusInt') -> 'MoebiusInt':
        return MoebiusInt(self.re + other.re, self.im + other.im)

    def __neg__(self) -> 'MoebiusInt':
        return MoebiusInt(-self.re, -self.im)

    def __sub__(self, other: 'MoebiusInt') -> 'MoebiusInt':
        return self + (-other)

    def __mul__(self, other: 'MoebiusInt') -> 'MoebiusInt':
        return MoebiusInt(
            self.re * other.re + self.im * other.im,
            self.re * other.im + self.im * other.re
        )

    def __repr__(self) -> str:
        if self.im == 0:
            return f"M({self.re})"
        elif self.re == 0:
            return f"M({self.im}ε)"
        return f"M({self.re}+{self.im}ε)"

    def norm(self) -> int:
        """N(a + bε) = a² - b²."""
        return self.re**2 - self.im**2

    def star(self) -> 'MoebiusInt':
        """Conjugation: a + bε ↦ a - bε."""
        return MoebiusInt(self.re, -self.im)

    def is_zero(self) -> bool:
        return self.re == 0 and self.im == 0

    def is_unit(self) -> bool:
        return self.norm() in (1, -1)

    def is_zero_divisor(self) -> bool:
        return not self.is_zero() and self.norm() == 0


# Constants
ZERO = MoebiusInt(0, 0)
ONE = MoebiusInt(1, 0)
EPSILON = MoebiusInt(0, 1)
E_PLUS = MoebiusInt(1, 1)
E_MINUS = MoebiusInt(1, -1)


def classify_parity(x: MoebiusInt) -> str:
    """
    Classify element by twist parity.

    Algorithm:
      if im = 0: symmetric (fixed by star)
      elif re = 0: antisymmetric (negated by star)
      else: mixed
    """
    if x.im == 0:
        return "symmetric"
    elif x.re == 0:
        return "antisymmetric"
    return "mixed"


def find_zero_divisor_witness(x: MoebiusInt) -> Optional[MoebiusInt]:
    """
    Given a zero divisor x, find y ≠ 0 with xy = 0.

    Algorithm:
      If norm(x) ≠ 0: return None (not a zero divisor)
      If re = im: return (1, -1) = e₋
      If re = -im: return (1, 1) = e₊
    """
    if x.is_zero() or x.norm() != 0:
        return None
    if x.re == x.im:
        return E_MINUS
    else:  # x.re == -x.im
        return E_PLUS


def difference_of_squares(n: int) -> Optional[tuple[int, int]]:
    """
    Find a, b such that a² - b² = n, if possible.

    Algorithm:
      If n % 4 == 2: impossible (return None)
      If n is odd: a = (n+1)//2, b = (n-1)//2
      If n % 4 == 0: a = n//4 + 1, b = n//4 - 1

    Returns (a, b) or None.
    """
    if n % 4 == 2 or n % 4 == -2:
        return None

    if n % 2 != 0:
        # n = ((n+1)/2)² - ((n-1)/2)²
        a = (n + 1) // 2
        b = (n - 1) // 2
        assert a * a - b * b == n
        return (a, b)
    else:
        # n = 4m, use (m+1)² - (m-1)²
        m = n // 4
        a = m + 1
        b = m - 1
        assert a * a - b * b == n
        return (a, b)


def moebius_fiber(n: int, bound: int = 100) -> list[MoebiusInt]:
    """
    Find all elements x with |x.re|, |x.im| ≤ bound and norm(x) = n.

    Brute-force enumeration of the Möbius fiber F(n).
    """
    results = []
    for a in range(-bound, bound + 1):
        for b in range(-bound, bound + 1):
            if a * a - b * b == n:
                results.append(MoebiusInt(a, b))
    return results


def unit_group_table() -> dict[tuple[str, str], str]:
    """
    Compute the multiplication table of the unit group V₄ = {1, -1, ε, -ε}.

    Returns a dict mapping (label_a, label_b) → label_product.
    """
    units = {"1": ONE, "-1": MoebiusInt(-1, 0), "ε": EPSILON, "-ε": MoebiusInt(0, -1)}
    inv_map = {v: k for k, v in units.items()}
    table: dict[tuple[str, str], str] = {}
    for na, a in units.items():
        for nb, b in units.items():
            product = a * b
            table[(na, nb)] = inv_map[product]
    return table


def orientation_decompose(x: MoebiusInt) -> tuple[int, int]:
    """
    Decompose x into its I₊ and I₋ components (over ℚ).

    x = α·e₊ + β·e₋ where e₊ = (1,1) and e₋ = (1,-1).
    Then α = (x.re + x.im)/2 and β = (x.re - x.im)/2.

    Returns (2α, 2β) = (x.re + x.im, x.re - x.im) to stay in ℤ.
    """
    return (x.re + x.im, x.re - x.im)


def norm_distribution(bound: int = 20) -> dict[int, int]:
    """
    Count elements in each Möbius fiber for norms in [-bound, bound].

    Returns dict mapping norm value → fiber size (for |re|, |im| ≤ bound).
    """
    counts: dict[int, int] = {}
    for a in range(-bound, bound + 1):
        for b in range(-bound, bound + 1):
            n = a * a - b * b
            if -bound <= n <= bound:
                counts[n] = counts.get(n, 0) + 1
    return dict(sorted(counts.items()))


if __name__ == "__main__":
    print("=== Difference of Squares Algorithm ===")
    for n in range(-10, 21):
        result = difference_of_squares(n)
        if result:
            a, b = result
            print(f"  {n} = {a}² - {b}²")
        else:
            print(f"  {n}: impossible (≡ 2 mod 4)")

    print("\n=== Unit Group Multiplication Table ===")
    table = unit_group_table()
    labels = ["1", "-1", "ε", "-ε"]
    print("    " + "  ".join(f"{l:>4}" for l in labels))
    for a in labels:
        row = [table[(a, b)] for b in labels]
        print(f"  {a:>2}  " + "  ".join(f"{r:>4}" for r in row))

    print("\n=== Norm Distribution (|coords| ≤ 10) ===")
    dist = norm_distribution(10)
    for n, count in list(dist.items())[:20]:
        bar = "█" * (count // 2)
        print(f"  N={n:4d}: {count:4d} elements  {bar}")
