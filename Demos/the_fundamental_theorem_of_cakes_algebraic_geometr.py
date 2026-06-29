#!/usr/bin/env python3
"""
Stratified Cake Theory: Numerical Demonstrations

Demonstrates the key mathematical results from the Fundamental Theorem of Cakes:
- Euler characteristic computation
- Moduli dimension formulas
- Stratification properties
- Gluing superadditivity
"""

from dataclasses import dataclass
from typing import List, Tuple


@dataclass
class CakeData:
    """Combinatorial topology of a cake."""
    genus: int
    boundary: int
    cherries: int
    layers: int

    def euler_char(self) -> int:
        """Euler characteristic: χ = 2 - 2g - b"""
        return 2 - 2 * self.genus - self.boundary

    def moduli_dim_real(self) -> int:
        """Real moduli dimension: 6g - 6 + 2n"""
        return 6 * self.genus - 6 + 2 * self.cherries

    def moduli_dim_complex(self) -> int:
        """Complex moduli dimension: 3g - 3 + n"""
        return 3 * self.genus - 3 + self.cherries

    def complexity(self) -> int:
        """Combined complexity measure."""
        return 3 * self.genus + self.boundary + self.cherries + self.layers

    def __repr__(self) -> str:
        return f"Cake(g={self.genus}, b={self.boundary}, n={self.cherries}, k={self.layers})"


def glue_cakes(c1: CakeData, c2: CakeData) -> CakeData:
    """Glue two cakes along one boundary component each."""
    assert c1.boundary >= 1 and c2.boundary >= 1, "Both cakes need boundary for gluing"
    return CakeData(
        genus=c1.genus + c2.genus,
        boundary=c1.boundary + c2.boundary - 2,
        cherries=c1.cherries + c2.cherries,
        layers=c1.layers + c2.layers,
    )


def canonical_flag(d: int) -> List[int]:
    """Canonical complete flag stratification: d, d-1, ..., 1, 0"""
    return list(range(d, -1, -1))


def demo_euler_characteristics():
    """Demonstrate Euler characteristic computation for classical surfaces."""
    print("=" * 60)
    print("EULER CHARACTERISTICS OF CLASSICAL SURFACES")
    print("=" * 60)
    surfaces = [
        ("Sphere", CakeData(0, 0, 0, 1)),
        ("Torus", CakeData(1, 0, 0, 1)),
        ("Genus-2", CakeData(2, 0, 0, 1)),
        ("Disk", CakeData(0, 1, 0, 1)),
        ("Annulus", CakeData(0, 2, 0, 1)),
        ("Pair of pants", CakeData(0, 3, 0, 1)),
        ("Torus with hole", CakeData(1, 1, 0, 1)),
    ]
    for name, cake in surfaces:
        print(f"  {name:20s}: g={cake.genus}, b={cake.boundary}, χ = {cake.euler_char()}")
    print()


def demo_moduli_dimensions():
    """Demonstrate the 3g-3 and 6g-6+2n formulas."""
    print("=" * 60)
    print("MODULI DIMENSIONS (3g-3 FORMULA)")
    print("=" * 60)
    for g in range(0, 6):
        cake = CakeData(g, 0, 0, 1)
        print(f"  Genus {g}: dim_C = {cake.moduli_dim_complex()}, dim_R = {cake.moduli_dim_real()}")
    print()

    print("With cherries (genus 2):")
    for n in range(0, 6):
        cake = CakeData(2, 0, n, 1)
        print(f"  n={n}: dim_C = {cake.moduli_dim_complex()}, dim_R = {cake.moduli_dim_real()}")
    print()


def demo_gluing_superadditivity():
    """Demonstrate the +6 superadditivity under gluing."""
    print("=" * 60)
    print("GLUING SUPERADDITIVITY")
    print("=" * 60)
    pairs = [
        (CakeData(0, 1, 3, 1), CakeData(0, 1, 3, 1)),
        (CakeData(1, 1, 0, 1), CakeData(1, 1, 0, 1)),
        (CakeData(1, 2, 1, 2), CakeData(0, 1, 4, 1)),
    ]
    for c1, c2 in pairs:
        glued = glue_cakes(c1, c2)
        d1, d2, dg = c1.moduli_dim_real(), c2.moduli_dim_real(), glued.moduli_dim_real()
        print(f"  {c1} + {c2}")
        print(f"    → {glued}")
        print(f"    dim(glued) = {dg} = {d1} + {d2} + 6 ✓" if dg == d1 + d2 + 6 else "    MISMATCH!")
        print()


def demo_stratification():
    """Demonstrate canonical flags and length bounds."""
    print("=" * 60)
    print("CANONICAL FLAG STRATIFICATIONS")
    print("=" * 60)
    for d in range(1, 6):
        flag = canonical_flag(d)
        print(f"  d={d}: {flag}  (length = {len(flag)} = d+1 = {d+1} ✓)")
    print()


def demo_cherry_genus_tradeoff():
    """Demonstrate the minimum cherry count for non-negative moduli dim."""
    print("=" * 60)
    print("CHERRY-GENUS TRADE-OFF")
    print("=" * 60)
    print("  Minimum cherries for dim_R ≥ 0:")
    for g in range(0, 5):
        min_n = max(0, (6 - 6 * g + 1) // 2)  # ceil((6-6g)/2)
        if 6 * g - 6 + 2 * min_n < 0:
            min_n += 1
        cake = CakeData(g, 0, min_n, 1)
        print(f"    Genus {g}: need n ≥ {min_n}, dim_R = {cake.moduli_dim_real()}")
    print()


def demo_even_dimension():
    """Verify that real moduli dimension is always even."""
    print("=" * 60)
    print("EVENNESS OF REAL MODULI DIMENSION")
    print("=" * 60)
    all_even = True
    for g in range(10):
        for n in range(10):
            d = 6 * g - 6 + 2 * n
            if d % 2 != 0:
                all_even = False
                print(f"  COUNTEREXAMPLE: g={g}, n={n}, dim={d}")
    if all_even:
        print("  Verified: 6g - 6 + 2n is even for all g,n ∈ [0,9] ✓")
    print()


if __name__ == "__main__":
    print("\n🎂 STRATIFIED CAKE THEORY: NUMERICAL DEMONSTRATIONS 🎂\n")
    demo_euler_characteristics()
    demo_moduli_dimensions()
    demo_gluing_superadditivity()
    demo_stratification()
    demo_cherry_genus_tradeoff()
    demo_even_dimension()
    print("All demonstrations complete.")


#!/usr/bin/env python3
"""
Visualization: Gluing Superadditivity

Bar chart showing how moduli dimension of glued cakes exceeds
the sum of components by exactly 6.
"""

import matplotlib.pyplot as plt
import numpy as np


def moduli_real(g: int, n: int) -> int:
    return 6 * g - 6 + 2 * n


def main():
    # Define pairs to glue (each must have boundary >= 1)
    pairs = [
        ((0, 1, 3, 1), (0, 1, 3, 1)),  # two disks with 3 cherries
        ((1, 1, 0, 1), (1, 1, 0, 1)),  # two tori with hole
        ((1, 2, 1, 2), (0, 1, 4, 1)),  # mixed
        ((2, 1, 0, 1), (0, 1, 5, 1)),  # genus 2 + sphere with 5 pts
        ((1, 1, 2, 1), (1, 1, 2, 1)),  # two genus-1 with 2 cherries
    ]

    labels = []
    dim1_vals = []
    dim2_vals = []
    bonus_vals = []

    for (g1, b1, n1, k1), (g2, b2, n2, k2) in pairs:
        d1 = moduli_real(g1, n1)
        d2 = moduli_real(g2, n2)
        g_glued = g1 + g2
        n_glued = n1 + n2
        d_glued = moduli_real(g_glued, n_glued)

        labels.append(f"({g1},{n1})+({g2},{n2})")
        dim1_vals.append(d1)
        dim2_vals.append(d2)
        bonus_vals.append(6)

    x = np.arange(len(labels))
    width = 0.6

    fig, ax = plt.subplots(figsize=(10, 6))
    bars1 = ax.bar(x, dim1_vals, width, label='dim(C₁)', color='#3498db')
    bars2 = ax.bar(x, dim2_vals, width, bottom=dim1_vals, label='dim(C₂)', color='#2ecc71')
    bars3 = ax.bar(x, bonus_vals, width,
                   bottom=[d1 + d2 for d1, d2 in zip(dim1_vals, dim2_vals)],
                   label='Gluing bonus (+6)', color='#e74c3c', hatch='//')

    ax.set_xlabel('Gluing pair (genus, cherries)', fontsize=12)
    ax.set_ylabel('Real moduli dimension', fontsize=12)
    ax.set_title('Gluing Superadditivity: dim(C₁⊕C₂) = dim(C₁) + dim(C₂) + 6',
                 fontsize=14)
    ax.set_xticks(x)
    ax.set_xticklabels(labels, rotation=15)
    ax.legend(fontsize=11)
    ax.grid(axis='y', alpha=0.3)

    plt.tight_layout()
    plt.savefig('gluing_superadditivity.png', dpi=150)
    plt.show()


if __name__ == '__main__':
    main()


#!/usr/bin/env python3
"""
Visualization: Moduli Dimension Landscape

A heatmap showing how the complex moduli dimension 3g-3+n varies
with genus g and cherry count n. Highlights the "rigidity threshold"
where moduli dimension first becomes non-negative.
"""

import matplotlib.pyplot as plt
import numpy as np


def moduli_dim_complex(g: int, n: int) -> int:
    return 3 * g - 3 + n


def main():
    max_g = 8
    max_n = 12
    g_vals = np.arange(0, max_g + 1)
    n_vals = np.arange(0, max_n + 1)
    G, N = np.meshgrid(g_vals, n_vals, indexing='ij')
    D = 3 * G - 3 + N

    fig, ax = plt.subplots(figsize=(10, 7))
    im = ax.imshow(D, origin='lower', aspect='auto',
                   cmap='RdYlGn', vmin=-3, vmax=24,
                   extent=[-0.5, max_n + 0.5, -0.5, max_g + 0.5])

    # Mark the rigidity threshold (dim = 0 contour)
    ax.contour(n_vals, g_vals, D, levels=[0], colors='black',
               linewidths=2, linestyles='--')

    # Annotate cells
    for g in range(max_g + 1):
        for n in range(max_n + 1):
            d = moduli_dim_complex(g, n)
            color = 'white' if d < 0 else 'black'
            ax.text(n, g, str(d), ha='center', va='center',
                    fontsize=7, color=color, fontweight='bold')

    ax.set_xlabel('Number of Cherries (n)', fontsize=12)
    ax.set_ylabel('Genus (g)', fontsize=12)
    ax.set_title('Complex Moduli Dimension: 3g − 3 + n\n'
                 '(Dashed line = rigidity threshold, dim = 0)',
                 fontsize=14)
    ax.set_xticks(range(0, max_n + 1))
    ax.set_yticks(range(0, max_g + 1))

    cbar = plt.colorbar(im, ax=ax, label='dim_ℂ M_{g,n}')
    plt.tight_layout()
    plt.savefig('moduli_landscape.png', dpi=150)
    plt.show()


if __name__ == '__main__':
    main()
