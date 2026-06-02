"""
Möbius Ring ℤ√1 — Demonstration Script

Demonstrates the key properties of the Möbius ring:
  - Arithmetic operations
  - Zero divisors and non-domain structure
  - Norm computation and factorization
  - Unit classification (Klein four-group V₄)
  - Splitting homomorphism
  - Parity obstruction
  - Idempotent rigidity
  - Mod-4 norm obstruction
"""

from typing import Tuple


class MobiusElement:
    """Element a + bε of the Möbius ring ℤ√1."""

    def __init__(self, re: int, im: int):
        self.re = re
        self.im = im

    def __repr__(self) -> str:
        if self.im == 0:
            return f"{self.re}"
        if self.re == 0:
            return f"{self.im}ε" if abs(self.im) != 1 else ("ε" if self.im == 1 else "-ε")
        sign = "+" if self.im > 0 else "-"
        im_str = f"{abs(self.im)}ε" if abs(self.im) != 1 else "ε"
        return f"{self.re} {sign} {im_str}"

    def __add__(self, other: "MobiusElement") -> "MobiusElement":
        return MobiusElement(self.re + other.re, self.im + other.im)

    def __mul__(self, other: "MobiusElement") -> "MobiusElement":
        # (a + bε)(c + dε) = (ac + bd) + (ad + bc)ε since ε² = 1
        return MobiusElement(
            self.re * other.re + self.im * other.im,
            self.re * other.im + self.im * other.re,
        )

    def __neg__(self) -> "MobiusElement":
        return MobiusElement(-self.re, -self.im)

    def __sub__(self, other: "MobiusElement") -> "MobiusElement":
        return self + (-other)

    def __eq__(self, other: object) -> bool:
        if not isinstance(other, MobiusElement):
            return NotImplemented
        return self.re == other.re and self.im == other.im

    def __pow__(self, n: int) -> "MobiusElement":
        if n == 0:
            return MobiusElement(1, 0)
        result = MobiusElement(1, 0)
        base = self
        while n > 0:
            if n % 2 == 1:
                result = result * base
            base = base * base
            n //= 2
        return result

    def norm(self) -> int:
        """N(a + bε) = a² - b² = (a+b)(a-b)"""
        return self.re ** 2 - self.im ** 2

    def split(self) -> Tuple[int, int]:
        """The splitting map φ(a + bε) = (a+b, a-b)"""
        return (self.re + self.im, self.re - self.im)

    def is_unit(self) -> bool:
        """z is a unit iff (re+im) and (re-im) are both ±1"""
        s, t = self.split()
        return abs(s) == 1 and abs(t) == 1

    def is_idempotent(self) -> bool:
        """z is idempotent iff z² = z"""
        return self * self == self

    def is_zero(self) -> bool:
        return self.re == 0 and self.im == 0


# Named elements
ZERO = MobiusElement(0, 0)
ONE = MobiusElement(1, 0)
EPS = MobiusElement(0, 1)
E_POS = MobiusElement(1, 1)   # 1 + ε
E_NEG = MobiusElement(1, -1)  # 1 - ε


def demo_basic():
    print("=" * 60)
    print("MÖBIUS RING ℤ√1 — BASIC PROPERTIES")
    print("=" * 60)

    print(f"\nε = {EPS}")
    print(f"ε² = {EPS ** 2}  (should be 1)")

    print(f"\ne₊ = 1 + ε = {E_POS}")
    print(f"e₋ = 1 - ε = {E_NEG}")
    print(f"e₊ · e₋ = {E_POS * E_NEG}  (ZERO DIVISOR!)")

    print(f"\nThis proves ℤ√1 is NOT an integral domain.")


def demo_norm():
    print("\n" + "=" * 60)
    print("NORM FACTORIZATION: N(a+bε) = (a+b)(a-b)")
    print("=" * 60)

    examples = [
        MobiusElement(3, 2),
        MobiusElement(5, 3),
        MobiusElement(7, 4),
        MobiusElement(1, 1),
        MobiusElement(0, 1),
    ]
    for z in examples:
        s, t = z.split()
        print(f"  N({z}) = {z.re}² - {z.im}² = {z.norm()}"
              f"  =  ({s}) × ({t}) = {s * t}")


def demo_units():
    print("\n" + "=" * 60)
    print("UNIT GROUP: V₄ = {1, -1, ε, -ε}")
    print("=" * 60)

    units = [ONE, -ONE, EPS, -EPS]
    print("\nUnits and their squares:")
    for u in units:
        print(f"  {str(u):>4}  →  ({u})² = {u ** 2}   (norm = {u.norm()})")

    print(f"\nAll units square to 1: {all((u ** 2) == ONE for u in units)}")
    print("This is the Klein four-group V₄ = (ℤ/2ℤ)²")

    # Multiplication table
    print("\nMultiplication table:")
    print("     |  1   -1    ε   -ε")
    print("-----+--------------------")
    for u in units:
        row = "  ".join(f"{str(u * v):>3}" for v in units)
        print(f"  {str(u):>2} | {row}")


def demo_splitting():
    print("\n" + "=" * 60)
    print("SPLITTING HOMOMORPHISM: φ(a+bε) = (a+b, a-b)")
    print("=" * 60)

    examples = [ONE, EPS, E_POS, E_NEG,
                MobiusElement(3, 2), MobiusElement(5, -1)]
    for z in examples:
        s = z.split()
        parity_ok = s[0] % 2 == s[1] % 2
        print(f"  φ({z}) = {s}   parity match: {parity_ok}")

    print("\nParity obstruction: φ(z).1 ≡ φ(z).2 (mod 2) always holds")
    print("Checking 1000 random elements...")
    import random
    random.seed(42)
    all_match = all(
        (a + b) % 2 == (a - b) % 2
        for a, b in [(random.randint(-100, 100), random.randint(-100, 100)) for _ in range(1000)]
    )
    print(f"  All parity matches: {all_match}")


def demo_idempotent():
    print("\n" + "=" * 60)
    print("IDEMPOTENT RIGIDITY")
    print("=" * 60)

    print("\nSearching for idempotents z with z² = z in range |re|, |im| ≤ 100:")
    idempotents = []
    for a in range(-100, 101):
        for b in range(-100, 101):
            z = MobiusElement(a, b)
            if z.is_idempotent():
                idempotents.append(z)
    print(f"  Found: {idempotents}")
    print(f"  Only 0 and 1 — confirming idempotent rigidity over ℤ!")

    print("\nOver ℚ, the idempotents would be (1+ε)/2 and (1-ε)/2:")
    print(f"  (1+ε)/2 = (0.5, 0.5) — not in ℤ√1!")
    print(f"  Check: (0.5+0.5ε)² = {0.5**2 + 0.5**2} + {2*0.5*0.5}ε = 0.5 + 0.5ε ✓")


def demo_mod4():
    print("\n" + "=" * 60)
    print("MOD-4 NORM OBSTRUCTION")
    print("=" * 60)

    print("\nNorm values mod 4 for all elements with |re|, |im| ≤ 20:")
    norm_mod4: set[int] = set()
    for a in range(-20, 21):
        for b in range(-20, 21):
            z = MobiusElement(a, b)
            norm_mod4.add(z.norm() % 4)
    print(f"  Observed residues mod 4: {sorted(norm_mod4)}")
    print(f"  Note: 2 is NEVER a residue (mod 4 obstruction)")

    print("\nIs 2 a Möbius norm?")
    found = False
    for a in range(-1000, 1001):
        for b in range(-1000, 1001):
            if a * a - b * b == 2:
                found = True
                break
        if found:
            break
    print(f"  Search in |a|, |b| ≤ 1000: found = {found}")

    print("\nDensity of Möbius norms in [1, N]:")
    for N in [100, 1000, 10000, 100000]:
        count = sum(1 for n in range(1, N + 1) if n % 4 != 2)
        print(f"  N = {N:>6}: {count}/{N} = {count/N:.4f}  (predicted: 0.7500)")


def demo_annihilators():
    print("\n" + "=" * 60)
    print("ORIENTATION IDEALS AND ANNIHILATORS")
    print("=" * 60)

    print("\nAnnihilation: (a·e₊)(b·e₋) = 0 for all a, b ∈ ℤ")
    for a in range(-3, 4):
        for b in range(-3, 4):
            ae = MobiusElement(a, a)      # a · (1+ε)
            be = MobiusElement(b, -b)     # b · (1-ε)
            product = ae * be
            assert product.is_zero(), f"Failed for a={a}, b={b}"
    print("  Verified for all a, b ∈ [-3, 3] ✓")

    print("\nAnnihilator intersection: if e₊·z = 0 and e₋·z = 0, then z = 0")
    count = 0
    for a in range(-10, 11):
        for b in range(-10, 11):
            z = MobiusElement(a, b)
            if (E_POS * z).is_zero() and (E_NEG * z).is_zero():
                count += 1
                assert z.is_zero()
    print(f"  Found {count} element(s) annihilated by both e₊ and e₋: only z = 0 ✓")


if __name__ == "__main__":
    demo_basic()
    demo_norm()
    demo_units()
    demo_splitting()
    demo_idempotent()
    demo_mod4()
    demo_annihilators()
    print("\n" + "=" * 60)
    print("All demonstrations completed successfully!")
    print("=" * 60)


"""
Visualization: Möbius Ring Norm Landscape

Plots the norm N(a+bε) = a² - b² as a heatmap over the (a, b) plane,
revealing the hyperbolic structure and zero-divisor lines.
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.colors import TwoSlopeNorm

def plot_norm_landscape(bound: int = 20) -> None:
    a = np.arange(-bound, bound + 1)
    b = np.arange(-bound, bound + 1)
    A, B = np.meshgrid(a, b)
    N = A**2 - B**2

    fig, axes = plt.subplots(1, 2, figsize=(16, 7))

    # Left: Norm heatmap
    ax = axes[0]
    norm_range = max(abs(N.min()), abs(N.max()))
    cnorm = TwoSlopeNorm(vmin=-norm_range, vcenter=0, vmax=norm_range)
    im = ax.pcolormesh(A, B, N, cmap='RdBu_r', norm=cnorm, shading='auto')
    ax.contour(A, B, N, levels=[0], colors='black', linewidths=2)
    ax.set_xlabel('a (real part)', fontsize=12)
    ax.set_ylabel('b (imaginary part)', fontsize=12)
    ax.set_title('Norm N(a + bε) = a² − b²', fontsize=14)
    ax.set_aspect('equal')
    plt.colorbar(im, ax=ax, label='Norm value')

    # Mark units
    units = [(1, 0), (-1, 0), (0, 1), (0, -1)]
    for ua, ub in units:
        ax.plot(ua, ub, 'g*', markersize=15, markeredgecolor='black')
    ax.annotate('Zero divisor\nlines: a = ±b', xy=(10, 10), fontsize=10,
                color='black', ha='center',
                bbox=dict(boxstyle='round', facecolor='yellow', alpha=0.8))

    # Right: Norm mod 4 distribution
    ax2 = axes[1]
    norms = set()
    for aa in range(-50, 51):
        for bb in range(-50, 51):
            norms.add(aa**2 - bb**2)
    norm_mod4 = {}
    for n in sorted(norms):
        r = n % 4
        norm_mod4[r] = norm_mod4.get(r, 0) + 1

    residues = sorted(norm_mod4.keys())
    counts = [norm_mod4[r] for r in residues]
    colors = ['#e74c3c' if r == 2 else '#3498db' for r in residues]
    ax2.bar(residues, counts, color=colors, edgecolor='black')
    ax2.set_xlabel('Norm mod 4', fontsize=12)
    ax2.set_ylabel('Count (in search range)', fontsize=12)
    ax2.set_title('Mod-4 Obstruction: n ≡ 2 (mod 4) never occurs', fontsize=14)
    ax2.set_xticks(residues)

    plt.tight_layout()
    plt.savefig('mobius_norm_landscape.png', dpi=150, bbox_inches='tight')
    plt.show()
    print("Saved: mobius_norm_landscape.png")


if __name__ == "__main__":
    plot_norm_landscape()
