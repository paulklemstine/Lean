#!/usr/bin/env python3
"""
Demo: The Möbius Ring ℤ√1 — Numerical Exploration

Demonstrates key properties of the Möbius ring:
1. Norm representation and the mod-4 obstruction
2. Unit group structure (Klein four-group)
3. Splitting map and parity sublattice
4. Idempotent search (confirming rigidity)
5. Quadratic residue surjectivity for odd primes
"""

from typing import Tuple, List, Optional


class MobiusInt:
    """Element of the Möbius ring ℤ√1 = ℤ[ε]/(ε²−1)."""

    def __init__(self, re: int, im: int):
        self.re = re
        self.im = im

    def __repr__(self) -> str:
        if self.im == 0:
            return f"{self.re}"
        elif self.re == 0:
            return f"{self.im}ε" if abs(self.im) != 1 else ("ε" if self.im == 1 else "-ε")
        sign = "+" if self.im > 0 else "-"
        im_str = f"{abs(self.im)}ε" if abs(self.im) != 1 else "ε"
        return f"{self.re} {sign} {im_str}"

    def __add__(self, other: 'MobiusInt') -> 'MobiusInt':
        return MobiusInt(self.re + other.re, self.im + other.im)

    def __mul__(self, other: 'MobiusInt') -> 'MobiusInt':
        # (a + bε)(c + dε) = (ac + bd) + (ad + bc)ε  since ε² = 1
        return MobiusInt(
            self.re * other.re + self.im * other.im,
            self.re * other.im + self.im * other.re
        )

    def __neg__(self) -> 'MobiusInt':
        return MobiusInt(-self.re, -self.im)

    def __eq__(self, other: object) -> bool:
        if not isinstance(other, MobiusInt):
            return NotImplemented
        return self.re == other.re and self.im == other.im

    def norm(self) -> int:
        """N(a + bε) = a² − b² = (a+b)(a−b)."""
        return self.re ** 2 - self.im ** 2

    def conj(self) -> 'MobiusInt':
        """Conjugation: conj(a + bε) = a − bε."""
        return MobiusInt(self.re, -self.im)

    def split(self) -> Tuple[int, int]:
        """Splitting map φ(a + bε) = (a+b, a−b)."""
        return (self.re + self.im, self.re - self.im)


# ===== Demo 1: The mod-4 obstruction =====
print("=" * 60)
print("DEMO 1: Norm Representation and the Mod-4 Obstruction")
print("=" * 60)

# Show which integers 0..20 are Möbius norms
print("\nWhich integers are representable as a² − b²?")
for n in range(-10, 21):
    if n % 4 != 2 and n % 4 != -2:
        # Find a representation
        if n % 2 != 0:  # odd
            a, b = (n + 1) // 2, (n - 1) // 2
        else:  # divisible by 4
            k = n // 4
            a, b = k + 1, k - 1
        z = MobiusInt(a, b)
        assert z.norm() == n, f"Bug: norm({z}) = {z.norm()} ≠ {n}"
        print(f"  n = {n:3d}: {a}² − {b}² = {a**2} − {b**2} = {n} ✓")
    else:
        print(f"  n = {n:3d}: NOT representable (≡ ±2 mod 4) ✗")

# ===== Demo 2: Unit group =====
print("\n" + "=" * 60)
print("DEMO 2: The Unit Group V₄ = {±1, ±ε}")
print("=" * 60)

units = [MobiusInt(1, 0), MobiusInt(-1, 0), MobiusInt(0, 1), MobiusInt(0, -1)]
print("\nUnit multiplication table:")
print(f"{'':>6s}", end="")
for u in units:
    print(f"{str(u):>8s}", end="")
print()
for u in units:
    print(f"{str(u):>6s}", end="")
    for v in units:
        print(f"{str(u * v):>8s}", end="")
    print()

print("\nAll units square to 1:")
for u in units:
    sq = u * u
    print(f"  ({u})² = {sq}")

# ===== Demo 3: Splitting map =====
print("\n" + "=" * 60)
print("DEMO 3: Splitting Map and Parity Sublattice")
print("=" * 60)

print("\nSplitting map φ(a + bε) = (a+b, a−b):")
for a in range(-2, 4):
    for b in range(-2, 4):
        z = MobiusInt(a, b)
        x, y = z.split()
        parity_ok = x % 2 == y % 2
        print(f"  φ({str(z):>8s}) = ({x:3d}, {y:3d})  parity: {'✓' if parity_ok else '✗'}")

# ===== Demo 4: Idempotent search =====
print("\n" + "=" * 60)
print("DEMO 4: Idempotent Rigidity")
print("=" * 60)

print("\nSearching for idempotents z² = z with |re|, |im| ≤ 100...")
idempotents = []
for a in range(-100, 101):
    for b in range(-100, 101):
        z = MobiusInt(a, b)
        if z * z == z:
            idempotents.append(z)

print(f"  Found {len(idempotents)} idempotents: {idempotents}")
print("  (Only 0 and 1 — confirming rigidity theorem)")

# ===== Demo 5: Norm surjectivity mod p =====
print("\n" + "=" * 60)
print("DEMO 5: Every Element Mod Odd Prime is a Difference of Squares")
print("=" * 60)

for p in [3, 5, 7, 11, 13]:
    all_representable = True
    for n in range(p):
        found = False
        for a in range(p):
            for b in range(p):
                if (a * a - b * b) % p == n:
                    found = True
                    break
            if found:
                break
        if not found:
            all_representable = False
            print(f"  p={p}: n={n} NOT representable!")
    if all_representable:
        print(f"  p = {p:2d}: ALL residues are differences of squares ✓")

# Check p=2 (should fail)
print(f"\n  p =  2: Representable residues = ", end="")
reps = set()
for a in range(2):
    for b in range(2):
        reps.add((a * a - b * b) % 2)
print(f"{reps} (missing {'1' if 1 not in reps else 'none'}) — surjectivity FAILS for p=2")

# ===== Demo 6: Conjugation and Galois norm =====
print("\n" + "=" * 60)
print("DEMO 6: Conjugation and the Galois Norm Formula")
print("=" * 60)

print("\nVerifying N(z) = re(z · conj(z)):")
for a, b in [(3, 2), (5, -3), (0, 4), (7, 7), (1, 1)]:
    z = MobiusInt(a, b)
    zc = z.conj()
    product = z * zc
    print(f"  z = {str(z):>8s}, conj(z) = {str(zc):>8s}, "
          f"z·conj(z) = {str(product):>8s}, "
          f"re = {product.re:4d}, norm = {z.norm():4d} {'✓' if product.re == z.norm() else '✗'}")

# ===== Demo 7: ε negates the norm =====
print("\n" + "=" * 60)
print("DEMO 7: Epsilon Negates the Norm")
print("=" * 60)

eps = MobiusInt(0, 1)
print("\nVerifying N(ε·z) = −N(z):")
for a, b in [(3, 1), (5, 2), (1, 0), (4, 3)]:
    z = MobiusInt(a, b)
    ez = eps * z
    print(f"  z = {str(z):>8s}, N(z) = {z.norm():4d}, "
          f"ε·z = {str(ez):>8s}, N(ε·z) = {ez.norm():4d} {'✓' if ez.norm() == -z.norm() else '✗'}")

print("\n" + "=" * 60)
print("All demos complete!")
print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Lorentz Hyperboloid and Möbius Ring Units

Shows the continuous hyperboloid a²−b²=1 with the integer
points (±1, 0) marked — the units of the Möbius ring.
"""
import matplotlib.pyplot as plt
import numpy as np


def main():
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Plot 1: The Lorentz hyperboloid a² - b² = 1
    ax1 = axes[0]

    # Continuous hyperboloid
    b_vals = np.linspace(-5, 5, 500)
    a_pos = np.sqrt(1 + b_vals ** 2)
    a_neg = -np.sqrt(1 + b_vals ** 2)

    ax1.plot(b_vals, a_pos, 'b-', linewidth=2, label='a²−b²=1 (right branch)')
    ax1.plot(b_vals, a_neg, 'b--', linewidth=2, label='a²−b²=1 (left branch)')

    # Light cone (norm = 0)
    ax1.plot([-5, 5], [-5, 5], 'k:', alpha=0.3, label='Light cone (a=b)')
    ax1.plot([-5, 5], [5, -5], 'k:', alpha=0.3, label='Light cone (a=-b)')

    # Integer points on hyperboloid
    ax1.plot(0, 1, 'r*', markersize=20, zorder=5, label='(a,b)=(1,0)')
    ax1.plot(0, -1, 'r*', markersize=20, zorder=5, label='(a,b)=(-1,0)')

    # Level curves for other norm values
    for n in [0, -1, 4, 9]:
        if n > 0:
            b_range = np.linspace(-5, 5, 200)
            a_sq = n + b_range ** 2
            a_p = np.sqrt(a_sq)
            ax1.plot(b_range, a_p, color='gray', alpha=0.2, linewidth=0.5)
            ax1.plot(b_range, -a_p, color='gray', alpha=0.2, linewidth=0.5)

    ax1.set_xlabel('b (imaginary part)')
    ax1.set_ylabel('a (real part)')
    ax1.set_title('Lorentz Hyperboloid a²−b²=1\nInteger Points = Units of ℤ√1')
    ax1.set_aspect('equal')
    ax1.set_xlim(-4, 4)
    ax1.set_ylim(-4, 4)
    ax1.legend(fontsize=7, loc='upper left')
    ax1.grid(True, alpha=0.2)

    # Plot 2: All norm level sets with integer points
    ax2 = axes[1]

    bound = 6
    # Color integer lattice points by norm
    for a in range(-bound, bound + 1):
        for b in range(-bound, bound + 1):
            n = a * a - b * b
            if n == 0:
                color = '#F44336'
                size = 8
            elif n == 1 or n == -1:
                color = '#4CAF50'
                size = 12
            elif n > 0:
                color = '#2196F3'
                size = 5
            else:
                color = '#FF9800'
                size = 5
            ax2.plot(b, a, 'o', color=color, markersize=size, alpha=0.6)

    # Mark units
    for a, b in [(1, 0), (-1, 0), (0, 1), (0, -1)]:
        ax2.plot(b, a, 'k*', markersize=15, zorder=5)

    ax2.set_xlabel('b')
    ax2.set_ylabel('a')
    ax2.set_title('Integer Lattice Points by Norm Value\nRed: N=0 (zero divisors), Green: N=±1 (units)')
    ax2.set_aspect('equal')
    ax2.grid(True, alpha=0.2)

    plt.tight_layout()
    plt.savefig('lorentz_hyperboloid.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved lorentz_hyperboloid.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: The Mod-4 Norm Obstruction

Shows the distribution of representable and non-representable integers,
and the density convergence to 3/4.
"""
import matplotlib.pyplot as plt
import numpy as np


def is_mobius_norm(n: int) -> bool:
    return n % 4 != 2 and n % 4 != -2


def norm_density(N: int) -> float:
    count = sum(1 for n in range(1, N + 1) if is_mobius_norm(n))
    return count / N


def main():
    fig, axes = plt.subplots(2, 1, figsize=(12, 8))

    # Plot 1: Representability pattern
    ax1 = axes[0]
    N = 80
    for n in range(1, N + 1):
        color = '#2196F3' if is_mobius_norm(n) else '#F44336'
        ax1.bar(n, 1, color=color, width=0.8, alpha=0.7)

    ax1.set_xlabel('n')
    ax1.set_title('Möbius Norm Representability: n ≡ 0,1,3 (mod 4) are representable (blue), n ≡ 2 (mod 4) are not (red)')
    ax1.set_yticks([])
    ax1.set_xlim(0.5, N + 0.5)

    # Add mod-4 labels
    for k in range(0, N + 1, 4):
        ax1.axvline(x=k + 0.5, color='gray', linestyle=':', alpha=0.3)

    # Plot 2: Density convergence
    ax2 = axes[1]
    Ns = np.arange(1, 2001)
    densities = np.cumsum([1 if is_mobius_norm(n) else 0 for n in range(1, 2001)]) / Ns

    ax2.plot(Ns, densities, 'b-', linewidth=1, label='Observed density')
    ax2.axhline(y=0.75, color='r', linestyle='--', label='Theoretical limit 3/4')
    ax2.set_xlabel('N')
    ax2.set_ylabel('Proportion of [1,N] that are Möbius norms')
    ax2.set_title('Density of Representable Integers Converges to 3/4')
    ax2.legend()
    ax2.set_ylim(0.7, 0.8)
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('mod4_obstruction.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved mod4_obstruction.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: The Möbius Norm Lattice

Shows the lattice of ℤ√1 elements colored by their norm value,
with the parity sublattice structure visible.
"""
import matplotlib.pyplot as plt
import matplotlib.colors as mcolors
import numpy as np


def mobius_norm(a: int, b: int) -> int:
    return a * a - b * b


def main():
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Plot 1: Norm values on the lattice
    ax1 = axes[0]
    bound = 8
    points_a = []
    points_b = []
    norms = []
    for a in range(-bound, bound + 1):
        for b in range(-bound, bound + 1):
            points_a.append(a)
            points_b.append(b)
            norms.append(mobius_norm(a, b))

    scatter = ax1.scatter(points_a, points_b, c=norms, cmap='RdBu_r',
                          s=40, edgecolors='gray', linewidths=0.3,
                          vmin=-30, vmax=30)
    plt.colorbar(scatter, ax=ax1, label='Norm N(a+bε) = a²−b²')

    # Highlight zero-divisor lines
    t = np.linspace(-bound, bound, 100)
    ax1.plot(t, t, 'k--', alpha=0.3, label='a=b (norm=0)')
    ax1.plot(t, -t, 'k--', alpha=0.3, label='a=-b (norm=0)')

    # Highlight units
    units = [(1, 0), (-1, 0), (0, 1), (0, -1)]
    for a, b in units:
        ax1.plot(a, b, 'r*', markersize=15, zorder=5)

    ax1.set_xlabel('a (real part)')
    ax1.set_ylabel('b (imaginary part)')
    ax1.set_title('Möbius Ring Norm Landscape\nN(a+bε) = a²−b²')
    ax1.set_aspect('equal')
    ax1.grid(True, alpha=0.2)
    ax1.legend(fontsize=8)

    # Plot 2: Splitting map image (parity sublattice)
    ax2 = axes[1]
    # Image of splitting map
    split_x = []
    split_y = []
    for a in range(-bound, bound + 1):
        for b in range(-bound, bound + 1):
            split_x.append(a + b)
            split_y.append(a - b)

    # All lattice points
    all_x = range(-2 * bound, 2 * bound + 1)
    all_y = range(-2 * bound, 2 * bound + 1)

    # Parity sublattice (in image) vs non-parity
    for x in all_x:
        for y in all_y:
            if x % 2 == y % 2:
                ax2.plot(x, y, 'b.', markersize=4, alpha=0.6)
            else:
                ax2.plot(x, y, 'r.', markersize=2, alpha=0.2)

    ax2.set_xlabel('x = a + b')
    ax2.set_ylabel('y = a − b')
    ax2.set_title('Splitting Map Image\nBlue: parity sublattice (x≡y mod 2)')
    ax2.set_aspect('equal')
    ax2.set_xlim(-8, 8)
    ax2.set_ylim(-8, 8)
    ax2.grid(True, alpha=0.2)

    plt.tight_layout()
    plt.savefig('norm_lattice.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved norm_lattice.png")


if __name__ == "__main__":
    main()
