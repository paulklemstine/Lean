#!/usr/bin/env python3
"""
Demonstration of the Möbius Ring ℤ√1 = ℤ[ε]/(ε² - 1).

This script illustrates the key properties of the Möbius ring through
concrete numerical examples.
"""

from dataclasses import dataclass


@dataclass(frozen=True)
class MoebiusInt:
    """An element a + bε of the Möbius ring ℤ√1."""
    re: int  # real part
    im: int  # twist part

    def __repr__(self):
        if self.im == 0:
            return f"{self.re}"
        elif self.re == 0:
            if self.im == 1:
                return "ε"
            elif self.im == -1:
                return "-ε"
            else:
                return f"{self.im}ε"
        else:
            sign = "+" if self.im > 0 else "-"
            im_abs = abs(self.im)
            im_str = "ε" if im_abs == 1 else f"{im_abs}ε"
            return f"{self.re} {sign} {im_str}"

    def __add__(self, other):
        return MoebiusInt(self.re + other.re, self.im + other.im)

    def __neg__(self):
        return MoebiusInt(-self.re, -self.im)

    def __sub__(self, other):
        return self + (-other)

    def __mul__(self, other):
        # (a + bε)(c + dε) = (ac + bd) + (ad + bc)ε   [since ε² = 1]
        return MoebiusInt(
            self.re * other.re + self.im * other.im,
            self.re * other.im + self.im * other.re
        )

    def __eq__(self, other):
        if isinstance(other, int):
            return self.re == other and self.im == 0
        return self.re == other.re and self.im == other.im

    def norm(self) -> int:
        """The Möbius norm: N(a + bε) = a² - b²."""
        return self.re**2 - self.im**2

    def star(self):
        """Conjugation: star(a + bε) = a - bε."""
        return MoebiusInt(self.re, -self.im)

    def is_unit(self) -> bool:
        """A Möbius integer is a unit iff its norm is ±1."""
        return self.norm() in (1, -1)

    def is_zero_divisor(self) -> bool:
        """A nonzero element is a zero divisor iff its norm is 0."""
        return self != MoebiusInt(0, 0) and self.norm() == 0

    def parity(self) -> str:
        """Classify by behavior under conjugation."""
        if self.im == 0:
            return "symmetric"
        elif self.re == 0:
            return "antisymmetric"
        else:
            return "mixed"


# Special elements
ZERO = MoebiusInt(0, 0)
ONE = MoebiusInt(1, 0)
EPSILON = MoebiusInt(0, 1)
E_PLUS = MoebiusInt(1, 1)
E_MINUS = MoebiusInt(1, -1)


def demo_basic():
    """Basic arithmetic demonstrations."""
    print("=" * 60)
    print("THE MÖBIUS RING ℤ√1 = ℤ[ε]/(ε² - 1)")
    print("=" * 60)

    print("\n--- Special Elements ---")
    print(f"  0 = {ZERO}")
    print(f"  1 = {ONE}")
    print(f"  ε = {EPSILON}")
    print(f"  1+ε = {E_PLUS}")
    print(f"  1-ε = {E_MINUS}")

    print("\n--- The Twist Theorem: ε² = 1 ---")
    eps_sq = EPSILON * EPSILON
    print(f"  ε * ε = {eps_sq}")
    assert eps_sq == ONE, "ε² should equal 1!"

    print("\n--- Arithmetic Examples ---")
    a = MoebiusInt(3, 2)
    b = MoebiusInt(1, -1)
    print(f"  ({a}) + ({b}) = {a + b}")
    print(f"  ({a}) * ({b}) = {a * b}")
    print(f"  ({a}) * ({a}) = {a * a}")


def demo_zero_divisors():
    """Demonstrate zero divisors."""
    print("\n" + "=" * 60)
    print("ZERO DIVISORS: THE TOPOLOGY OF NON-ORIENTABILITY")
    print("=" * 60)

    print("\n--- The Fundamental Zero Divisor ---")
    product = E_PLUS * E_MINUS
    print(f"  (1+ε) * (1-ε) = {product}")
    print(f"  1+ε ≠ 0? {E_PLUS != ZERO}")
    print(f"  1-ε ≠ 0? {E_MINUS != ZERO}")
    print(f"  Product = 0? {product == ZERO}")
    print("  → ℤ√1 is NOT an integral domain!")

    print("\n--- All zero divisors have norm 0 ---")
    print("  Scanning elements with |re|,|im| ≤ 5:")
    zd_count = 0
    for a in range(-5, 6):
        for b in range(-5, 6):
            x = MoebiusInt(a, b)
            if x.is_zero_divisor():
                zd_count += 1
                if zd_count <= 8:
                    print(f"    {x}: norm = {x.norm()}, "
                          f"re = {'im' if a == b else '-im' if a == -b else '?'}")
    print(f"  Total zero divisors found: {zd_count}")
    print("  All have norm 0, confirming re = ±im")


def demo_units():
    """Demonstrate the unit group = Klein four-group."""
    print("\n" + "=" * 60)
    print("UNITS: THE KLEIN FOUR-GROUP V₄")
    print("=" * 60)

    units = [ONE, MoebiusInt(-1, 0), EPSILON, MoebiusInt(0, -1)]
    print("\n--- The four units of ℤ√1 ---")
    for u in units:
        print(f"  {u}: norm = {u.norm()}, u² = {u * u}, is_unit = {u.is_unit()}")

    print("\n--- Every unit is its own inverse (exponent 2) ---")
    for u in units:
        print(f"  {u} * {u} = {u * u}")

    print("\n--- Multiplication table (Klein four-group) ---")
    labels = ["1", "-1", "ε", "-ε"]
    print("    " + "  ".join(f"{l:>4}" for l in labels))
    for i, u in enumerate(units):
        row = [u * v for v in units]
        print(f"  {labels[i]:>2}  " + "  ".join(f"{r!s:>4}" for r in row))

    print("\n--- Scanning for units with |re|,|im| ≤ 10 ---")
    found = []
    for a in range(-10, 11):
        for b in range(-10, 11):
            x = MoebiusInt(a, b)
            if x.is_unit():
                found.append(x)
    print(f"  Found {len(found)} units: {found}")
    assert len(found) == 4, "Should have exactly 4 units!"


def demo_fibers():
    """Demonstrate the Möbius Fiber Theorem."""
    print("\n" + "=" * 60)
    print("MÖBIUS FIBERS: DIFFERENCES OF TWO SQUARES")
    print("=" * 60)

    print("\n--- Which integers are a² - b²? ---")
    print("  n ≡ 2 (mod 4) → IMPOSSIBLE")
    print("  n ≢ 2 (mod 4) → POSSIBLE")

    print("\n--- Testing n = 0, 1, ..., 20 ---")
    for n in range(21):
        # Search for a representation
        found = None
        for a in range(n + 1):
            for b in range(n + 1):
                if a * a - b * b == n:
                    found = (a, b)
                    break
                if a * a - b * b == -n and n > 0:
                    pass  # We want positive n
            if found:
                break
        mod4 = n % 4
        expected = mod4 != 2
        status = "✓" if found else "✗"
        if found:
            a, b = found
            print(f"  n={n:2d} (mod 4 = {mod4}): {status}  {a}² - {b}² = {a*a - b*b}")
        else:
            print(f"  n={n:2d} (mod 4 = {mod4}): {status}  (impossible)")
        if expected and not found and n > 0:
            # Search harder
            for a in range(100):
                for b in range(100):
                    if a * a - b * b == n:
                        print(f"     Actually: {a}² - {b}² = {n}")
                        break

    print("\n--- Negative examples: n ≡ 2 (mod 4) ---")
    for n in [2, 6, 10, 14, 18]:
        found = False
        for a in range(100):
            for b in range(100):
                if a * a - b * b == n:
                    found = True
                    break
            if found:
                break
        print(f"  n={n}: {'found (BUG!)' if found else 'confirmed impossible'}")


def demo_orientation_ideals():
    """Demonstrate the orientation ideals."""
    print("\n" + "=" * 60)
    print("ORIENTATION IDEALS: I₊ AND I₋")
    print("=" * 60)

    print("\n--- I₊ = (1+ε): elements with re = im ---")
    for a in range(-3, 4):
        x = MoebiusInt(a, 0) * E_PLUS
        print(f"  {a} * (1+ε) = {x}  [re={x.re}, im={x.im}]")

    print("\n--- I₋ = (1-ε): elements with re = -im ---")
    for a in range(-3, 4):
        x = MoebiusInt(a, 0) * E_MINUS
        print(f"  {a} * (1-ε) = {x}  [re={x.re}, im={x.im}]")

    print("\n--- I₊ · I₋ = {0}: orientation annihilation ---")
    for a in range(-2, 3):
        for b in range(-2, 3):
            x = MoebiusInt(a, 0) * E_PLUS
            y = MoebiusInt(b, 0) * E_MINUS
            product = x * y
            assert product == ZERO, f"{x} * {y} = {product} ≠ 0!"
    print("  Verified: every product of I₊ and I₋ elements is 0  ✓")


def demo_parity():
    """Demonstrate twist parity classification."""
    print("\n" + "=" * 60)
    print("TWIST PARITY: SYMMETRIC / ANTISYMMETRIC / MIXED")
    print("=" * 60)

    examples = [
        MoebiusInt(3, 0), MoebiusInt(-2, 0),
        MoebiusInt(0, 4), MoebiusInt(0, -1),
        MoebiusInt(2, 3), MoebiusInt(1, 1),
    ]
    for x in examples:
        print(f"  {x}: parity = {x.parity()}, star = {x.star()}")

    print("\n--- Product of antisymmetric elements is symmetric ---")
    x = MoebiusInt(0, 3)
    y = MoebiusInt(0, -2)
    print(f"  {x} * {y} = {x * y}  (parity: {(x * y).parity()})")

    print("\n--- ε swaps coordinates ---")
    x = MoebiusInt(5, 3)
    ex = EPSILON * x
    print(f"  ε * ({x}) = {ex}  [re and im swapped]")


if __name__ == "__main__":
    demo_basic()
    demo_zero_divisors()
    demo_units()
    demo_fibers()
    demo_orientation_ideals()
    demo_parity()
    print("\n" + "=" * 60)
    print("All demonstrations completed successfully!")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization of the Möbius Ring ℤ√1.

Produces three plots:
1. Lattice points colored by norm value
2. Zero divisors and units highlighted
3. Möbius fiber sizes (difference of squares count)
"""

import matplotlib.pyplot as plt
import matplotlib.patches as patches
import numpy as np


def plot_moebius_lattice():
    """Plot the Möbius ring lattice colored by norm."""
    fig, axes = plt.subplots(1, 3, figsize=(18, 6))

    bound = 8

    # Plot 1: Norm values
    ax = axes[0]
    for a in range(-bound, bound + 1):
        for b in range(-bound, bound + 1):
            norm = a * a - b * b
            color = plt.cm.RdBu(0.5 + norm / (2 * bound * bound))
            ax.scatter(a, b, c=[color], s=30, edgecolors='gray', linewidths=0.3)

    # Highlight zero divisors (norm = 0)
    for a in range(-bound, bound + 1):
        ax.scatter(a, a, c='red', s=60, marker='D', zorder=5, label='re=im' if a == 1 else '')
        ax.scatter(a, -a, c='orange', s=60, marker='D', zorder=5, label='re=-im' if a == 1 else '')

    ax.set_xlabel('re (real part)')
    ax.set_ylabel('im (twist part)')
    ax.set_title('Möbius Ring ℤ√1: Norm Coloring\n(Red=positive, Blue=negative, Diamonds=zero divisors)')
    ax.set_aspect('equal')
    ax.grid(True, alpha=0.3)
    ax.legend(loc='upper left', fontsize=8)

    # Plot 2: Units and zero divisors
    ax = axes[1]
    for a in range(-bound, bound + 1):
        for b in range(-bound, bound + 1):
            norm = a * a - b * b
            if norm == 0 and (a != 0 or b != 0):
                ax.scatter(a, b, c='red', s=40, alpha=0.6, zorder=3)
            elif abs(norm) == 1:
                ax.scatter(a, b, c='gold', s=100, marker='*', zorder=4)
            else:
                ax.scatter(a, b, c='lightgray', s=10, zorder=1)

    # Label units
    units = [(1, 0, '1'), (-1, 0, '-1'), (0, 1, 'ε'), (0, -1, '-ε')]
    for x, y, label in units:
        ax.annotate(label, (x, y), textcoords="offset points",
                    xytext=(8, 8), fontsize=12, fontweight='bold', color='darkgoldenrod')

    ax.set_xlabel('re')
    ax.set_ylabel('im')
    ax.set_title('Units (★) and Zero Divisors (●)\nKlein four-group V₄ = {1, -1, ε, -ε}')
    ax.set_aspect('equal')
    ax.grid(True, alpha=0.3)

    # Plot 3: Fiber sizes
    ax = axes[2]
    norms = list(range(-30, 31))
    fiber_sizes = []
    search_bound = 30
    for n in norms:
        count = 0
        for a in range(-search_bound, search_bound + 1):
            b_sq = a * a - n
            if b_sq >= 0:
                b = int(b_sq ** 0.5)
                if b * b == b_sq and -search_bound <= b <= search_bound:
                    count += 1
                if b > 0 and (-b) >= -search_bound:
                    count += 1
        fiber_sizes.append(count)

    colors = ['red' if n % 4 in (2, -2) else 'steelblue' for n in norms]
    ax.bar(norms, fiber_sizes, color=colors, width=0.8, alpha=0.7)
    ax.set_xlabel('Norm value n')
    ax.set_ylabel('|Fiber(n)| (count of representations)')
    ax.set_title('Möbius Fiber Sizes: n = a² - b²\n(Red = n ≡ 2 mod 4: impossible)')
    ax.axhline(y=0, color='black', linewidth=0.5)

    plt.tight_layout()
    plt.savefig('moebius_ring_visualization.png', dpi=150, bbox_inches='tight')
    plt.show()
    print("Saved: moebius_ring_visualization.png")


if __name__ == "__main__":
    plot_moebius_lattice()
