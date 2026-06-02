"""
Möbius Ring ℤ√1 — Algorithms

Type-hinted implementations of key algorithms for the Möbius ring.
"""

from typing import Optional, Tuple, List
from dataclasses import dataclass


@dataclass(frozen=True)
class MobiusInt:
    """Element of the Möbius ring ℤ√1 = ℤ[ε]/(ε²-1)."""
    re: int
    im: int

    def __add__(self, other: "MobiusInt") -> "MobiusInt":
        return MobiusInt(self.re + other.re, self.im + other.im)

    def __mul__(self, other: "MobiusInt") -> "MobiusInt":
        return MobiusInt(
            self.re * other.re + self.im * other.im,
            self.re * other.im + self.im * other.re,
        )

    def __neg__(self) -> "MobiusInt":
        return MobiusInt(-self.re, -self.im)

    def __str__(self) -> str:
        if self.im == 0:
            return str(self.re)
        if self.re == 0:
            return f"{self.im}ε"
        sign = "+" if self.im > 0 else "-"
        return f"{self.re} {sign} {abs(self.im)}ε"


def norm(z: MobiusInt) -> int:
    """Compute the norm N(a+bε) = a² - b² = (a+b)(a-b).

    Time: O(1) arithmetic operations.
    """
    return (z.re + z.im) * (z.re - z.im)


def split(z: MobiusInt) -> Tuple[int, int]:
    """The splitting homomorphism φ(a+bε) = (a+b, a-b).

    This is a ring homomorphism ℤ√1 → ℤ × ℤ.
    Time: O(1).
    """
    return (z.re + z.im, z.re - z.im)


def is_unit(z: MobiusInt) -> bool:
    """Check if z is a unit in ℤ√1.

    z is a unit iff |re+im| = 1 and |re-im| = 1.
    Equivalently, (re, im) ∈ {(1,0), (-1,0), (0,1), (0,-1)}.
    Time: O(1).
    """
    s, t = split(z)
    return abs(s) == 1 and abs(t) == 1


def all_units() -> List[MobiusInt]:
    """Return all four units of ℤ√1: {1, -1, ε, -ε}.

    These form the Klein four-group V₄.
    """
    return [
        MobiusInt(1, 0),   # 1
        MobiusInt(-1, 0),  # -1
        MobiusInt(0, 1),   # ε
        MobiusInt(0, -1),  # -ε
    ]


def is_mobius_norm(n: int) -> bool:
    """Check if n is representable as a norm of some element of ℤ√1.

    An integer n is a Möbius norm iff n ≢ 2 (mod 4).
    Time: O(1).

    Algorithm: n = a² - b² = (a+b)(a-b). Since a+b ≡ a-b (mod 2),
    the product is either 0 mod 4 (both factors even) or odd (both odd).
    So n mod 4 ∈ {0, 1, 3} (equivalently, n mod 4 ≠ 2).
    """
    return n % 4 != 2


def find_norm_witness(n: int) -> Optional[MobiusInt]:
    """Find z ∈ ℤ√1 with N(z) = n, if one exists.

    Returns None if n ≡ 2 (mod 4).
    Time: O(1).

    Algorithm:
    - If n is odd: a = (n+1)/2, b = (n-1)/2. Then a²-b² = n.
    - If n ≡ 0 (mod 4): a = n/4 + 1, b = n/4 - 1. Then a²-b² = 4·(n/4) = ... wait.
      Actually for n = 4k: a = k+1, b = k-1. Then a²-b² = (k+1)²-(k-1)² = 4k = n. ✓
    - If n ≡ 2 (mod 4): impossible.
    """
    if n % 4 == 2:
        return None
    if n % 2 == 1:  # odd
        a = (n + 1) // 2
        b = (n - 1) // 2
        return MobiusInt(a, b)
    else:  # n ≡ 0 (mod 4)
        k = n // 4
        a = k + 1
        b = k - 1
        return MobiusInt(a, b)


def norm_fiber_count(n: int, bound: int) -> int:
    """Count elements z with |re|, |im| ≤ bound and N(z) = n.

    Time: O(bound²).
    """
    count = 0
    for a in range(-bound, bound + 1):
        for b in range(-bound, bound + 1):
            if a * a - b * b == n:
                count += 1
    return count


def multiplication_table() -> str:
    """Generate the V₄ multiplication table for the unit group."""
    units = all_units()
    labels = ["1", "-1", "ε", "-ε"]

    header = "     | " + "  ".join(f"{l:>3}" for l in labels)
    sep = "-----+" + "-" * (len(labels) * 5)

    rows = [header, sep]
    for i, u in enumerate(units):
        products = []
        for v in units:
            p = u * v
            idx = units.index(p)
            products.append(f"{labels[idx]:>3}")
        rows.append(f"  {labels[i]:>2} | {'  '.join(products)}")

    return "\n".join(rows)


def mobius_norm_density(N: int) -> float:
    """Compute the density of Möbius norms in [1, N].

    Should converge to 3/4 as N → ∞.
    """
    count = sum(1 for n in range(1, N + 1) if is_mobius_norm(n))
    return count / N


if __name__ == "__main__":
    print("Möbius Ring Algorithms — Self-Test")
    print()

    # Test norm
    z = MobiusInt(3, 2)
    print(f"norm({z}) = {norm(z)} (expected: 5)")

    # Test units
    print(f"Units: {[str(u) for u in all_units()]}")

    # Test norm witnesses
    for n in [0, 1, 3, 4, 5, 7, 8, -1, -3]:
        w = find_norm_witness(n)
        if w:
            assert norm(w) == n, f"Witness check failed for n={n}"
            print(f"  N({w}) = {n} ✓")

    # Test 2 is not a norm
    w = find_norm_witness(2)
    print(f"  find_norm_witness(2) = {w} (should be None)")

    # Density
    for N in [100, 1000, 10000]:
        d = mobius_norm_density(N)
        print(f"  Density in [1,{N}]: {d:.4f}")

    # Multiplication table
    print(f"\nUnit group multiplication table (V₄):")
    print(multiplication_table())
