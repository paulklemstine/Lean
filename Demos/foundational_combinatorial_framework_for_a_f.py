#!/usr/bin/env python3
"""
Demo: Selberg Class Census - Conductor Counting and Spectral Invariants

Demonstrates the key results from the formal framework:
1. Conductor counting function N_d(Q, B) and its polynomial bound
2. Spectral complexity and entropy computations
3. Additivity under products
4. Well-founded factorization decomposition
"""

from fractions import Fraction
from dataclasses import dataclass
from typing import List


@dataclass
class SelbergDatum:
    """Invariant data of a Selberg class L-function."""
    d: int          # degree
    q: int          # conductor
    mu: List[Fraction]  # spectral parameters

    def __post_init__(self):
        assert len(self.mu) == self.d, f"Expected {self.d} spectral params, got {len(self.mu)}"
        assert self.q > 0, "Conductor must be positive"

    def spectral_complexity(self) -> Fraction:
        """Sum of |μ_j| + degree."""
        return Fraction(self.d) + sum(abs(m) for m in self.mu)

    def spectral_entropy(self) -> Fraction:
        """Sum of (|numerator| + denominator) for each parameter."""
        return sum(Fraction(abs(m.numerator)) + Fraction(m.denominator) for m in self.mu)

    def dc_energy(self) -> int:
        """Degree-conductor energy d * q."""
        return self.d * self.q

    def product(self, other: "SelbergDatum") -> "SelbergDatum":
        """Rankin-Selberg product."""
        return SelbergDatum(
            d=self.d + other.d,
            q=self.q * other.q,
            mu=self.mu + other.mu,
        )

    def is_primitive(self) -> bool:
        return self.d == 1

    def __repr__(self):
        return f"SD(d={self.d}, q={self.q}, μ={[str(m) for m in self.mu]})"


# Key examples
zeta = SelbergDatum(d=1, q=1, mu=[Fraction(0)])
dirichlet_mod4 = SelbergDatum(d=1, q=4, mu=[Fraction(1, 2)])
elliptic_11a = SelbergDatum(d=2, q=11, mu=[Fraction(0), Fraction(0)])
elliptic_37a = SelbergDatum(d=2, q=37, mu=[Fraction(0), Fraction(0)])
ramanujan_delta = SelbergDatum(d=2, q=1, mu=[Fraction(11, 2), Fraction(11, 2)])


def count_bounded_data(d: int, Q: int, B: int) -> int:
    """Count Selberg data with fixed degree d, conductor ≤ Q,
    and spectral parameters with |numerator| ≤ B, 1 ≤ denominator ≤ B."""
    num_conductors = Q  # |{1, ..., Q}|
    num_params = (2 * B + 1) * B  # |[-B,B]_Z × [1,B]_N|
    return num_conductors * (num_params ** d)


def poly_bound(d: int, Q: int, B: int) -> int:
    """Polynomial upper bound: Q * ((2B+1)*B)^d."""
    return Q * ((2 * B + 1) * B) ** d


def main():
    print("=" * 60)
    print("  SELBERG CLASS CENSUS: NUMERICAL DEMONSTRATIONS")
    print("=" * 60)

    # Demo 1: Spectral Complexity
    print("\n--- Demo 1: Spectral Complexity ---")
    examples = [zeta, dirichlet_mod4, elliptic_11a, ramanujan_delta]
    for s in examples:
        print(f"  {s}")
        print(f"    Complexity: {s.spectral_complexity()}")
        print(f"    Entropy:    {s.spectral_entropy()}")
        print(f"    DC Energy:  {s.dc_energy()}")
        print()

    # Demo 2: Additivity
    print("--- Demo 2: Additivity under Products ---")
    prod = zeta.product(elliptic_11a)
    print(f"  ζ ⊗ L(E_11a) = {prod}")
    print(f"  C(ζ) + C(E_11a) = {zeta.spectral_complexity()} + {elliptic_11a.spectral_complexity()} = {zeta.spectral_complexity() + elliptic_11a.spectral_complexity()}")
    print(f"  C(ζ ⊗ E_11a)   = {prod.spectral_complexity()}")
    print(f"  Match: {prod.spectral_complexity() == zeta.spectral_complexity() + elliptic_11a.spectral_complexity()}")
    print()

    prod2 = dirichlet_mod4.product(ramanujan_delta)
    print(f"  χ₄ ⊗ Δ = {prod2}")
    print(f"  H(χ₄) + H(Δ) = {dirichlet_mod4.spectral_entropy()} + {ramanujan_delta.spectral_entropy()} = {dirichlet_mod4.spectral_entropy() + ramanujan_delta.spectral_entropy()}")
    print(f"  H(χ₄ ⊗ Δ)    = {prod2.spectral_entropy()}")
    print(f"  Match: {prod2.spectral_entropy() == dirichlet_mod4.spectral_entropy() + ramanujan_delta.spectral_entropy()}")
    print()

    # Demo 3: Counting
    print("--- Demo 3: Conductor Counting Function ---")
    print(f"  {'d':>3} {'Q':>6} {'B':>4} {'N_d(Q,B)':>12} {'Bound':>12} {'Tight':>6}")
    print(f"  {'-'*3} {'-'*6} {'-'*4} {'-'*12} {'-'*12} {'-'*6}")
    for d in [1, 2, 3]:
        for Q in [10, 100, 1000]:
            B = 5
            N = count_bounded_data(d, Q, B)
            bound = poly_bound(d, Q, B)
            print(f"  {d:>3} {Q:>6} {B:>4} {N:>12} {bound:>12} {N == bound:>6}")
    print()

    # Demo 4: Energy decrease under factorization
    print("--- Demo 4: Energy Decrease under Factorization ---")
    s1 = SelbergDatum(d=1, q=3, mu=[Fraction(0)])
    s2 = SelbergDatum(d=1, q=5, mu=[Fraction(1, 3)])
    prod = s1.product(s2)
    print(f"  s1 = {s1}, E = {s1.dc_energy()}")
    print(f"  s2 = {s2}, E = {s2.dc_energy()}")
    print(f"  s1 ⊗ s2 = {prod}, E = {prod.dc_energy()}")
    print(f"  E(s1) < E(s1 ⊗ s2): {s1.dc_energy()} < {prod.dc_energy()} = {s1.dc_energy() < prod.dc_energy()}")
    print()

    # Demo 5: Polynomial growth visualization data
    print("--- Demo 5: Growth Rate Analysis ---")
    B = 3
    for d in [1, 2, 3]:
        print(f"  Degree d={d}, B={B}:")
        ratios = []
        for Q in [10, 50, 100, 500, 1000]:
            N = count_bounded_data(d, Q, B)
            ratio = N / (Q ** (d + 1)) if Q > 0 else 0
            ratios.append(ratio)
            print(f"    Q={Q:>5}: N={N:>15}, N/Q^{d+1} = {ratio:.6f}")
        print()


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Spectral Complexity Landscape

Plots the spectral complexity of Selberg data as a function of
degree and spectral parameters, showing the minimum at the zeta datum.
"""
import matplotlib.pyplot as plt
import numpy as np
from fractions import Fraction


def spectral_complexity(d: int, mu_abs_sum: float) -> float:
    return d + mu_abs_sum


def main():
    fig, ax = plt.subplots(figsize=(10, 7))

    # Generate data points: (degree, sum|mu|, complexity)
    degrees = range(1, 6)
    mu_sums = np.linspace(0, 5, 50)

    for d in degrees:
        complexities = [spectral_complexity(d, m) for m in mu_sums]
        ax.plot(mu_sums, complexities, linewidth=2, label=f'd = {d}')

    # Mark the zeta datum
    ax.plot(0, 1, 'r*', markersize=20, zorder=5, label='Riemann ζ (minimum)')

    # Mark some named L-functions
    named = [
        (1, 0.5, 'χ₄', 'go'),
        (2, 0, 'E₁₁', 'bs'),
        (2, 11, 'Δ', 'mp'),
    ]
    for d, mu_sum, name, fmt in named:
        c = spectral_complexity(d, mu_sum)
        ax.plot(mu_sum, c, fmt, markersize=12, zorder=5)
        ax.annotate(name, (mu_sum, c), textcoords="offset points",
                   xytext=(10, 5), fontsize=12, fontweight='bold')

    ax.set_xlabel('Sum of |spectral parameters|', fontsize=14)
    ax.set_ylabel('Spectral Complexity C(σ)', fontsize=14)
    ax.set_title('Spectral Complexity Landscape', fontsize=16)
    ax.legend(fontsize=11, loc='upper left')
    ax.grid(True, alpha=0.3)
    ax.set_xlim(-0.2, 5.2)
    ax.set_ylim(0, 11)

    plt.tight_layout()
    plt.savefig('complexity_landscape.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved complexity_landscape.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Conductor Counting Function Growth

Plots N_d(Q, B) for various degrees d and compares with the
polynomial upper bound Q · ((2B+1)B)^d.
"""
import matplotlib.pyplot as plt
import numpy as np


def count_bounded_data(d: int, Q: int, B: int) -> int:
    return Q * ((2 * B + 1) * B) ** d


def main():
    B = 3
    Q_values = np.arange(1, 201)

    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    for idx, d in enumerate([1, 2, 3]):
        ax = axes[idx]
        N_values = [count_bounded_data(d, int(Q), B) for Q in Q_values]

        ax.plot(Q_values, N_values, 'b-', linewidth=2, label=f'$N_{d}(Q, {B})$')
        ax.plot(Q_values, [Q * ((2*B+1)*B)**d for Q in Q_values],
                'r--', linewidth=1, alpha=0.7, label=f'Bound $Q \\cdot {(2*B+1)*B}^{d}$')

        ax.set_xlabel('Conductor bound Q', fontsize=12)
        ax.set_ylabel(f'$N_{d}(Q, {B})$', fontsize=12)
        ax.set_title(f'Degree d = {d}', fontsize=14)
        ax.legend(fontsize=10)
        ax.grid(True, alpha=0.3)

    plt.suptitle('Conductor Counting Function: Polynomial Growth', fontsize=16, y=1.02)
    plt.tight_layout()
    plt.savefig('counting_growth.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved counting_growth.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Factorization Tree and Energy Decrease

Shows the well-founded factorization ordering and how degree-conductor
energy strictly decreases under nontrivial factorization.
"""
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def dc_energy(d: int, q: int) -> int:
    return d * q


def main():
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    # Panel 1: Factorization tree of a degree-4 datum
    ax1.set_xlim(-1, 11)
    ax1.set_ylim(-0.5, 4.5)
    ax1.set_title('Factorization Tree', fontsize=14)
    ax1.axis('off')

    # Root: degree 4, conductor 30
    nodes = {
        'root': (5, 4, 'd=4, q=30\nE=120'),
        'L': (2, 2.5, 'd=2, q=6\nE=12'),
        'R': (8, 2.5, 'd=2, q=5\nE=10'),
        'LL': (0.5, 1, 'd=1, q=2\nE=2'),
        'LR': (3.5, 1, 'd=1, q=3\nE=3'),
        'RL': (6.5, 1, 'd=1, q=1\nE=1'),
        'RR': (9.5, 1, 'd=1, q=5\nE=5'),
    }

    edges = [('root', 'L'), ('root', 'R'), ('L', 'LL'), ('L', 'LR'),
             ('R', 'RL'), ('R', 'RR')]

    colors = {'root': '#ff6b6b', 'L': '#ffa500', 'R': '#ffa500',
              'LL': '#4ecdc4', 'LR': '#4ecdc4', 'RL': '#4ecdc4', 'RR': '#4ecdc4'}

    for name, (x, y, label) in nodes.items():
        circle = plt.Circle((x, y), 0.45, color=colors[name], alpha=0.8, zorder=3)
        ax1.add_patch(circle)
        ax1.text(x, y, label, ha='center', va='center', fontsize=7, fontweight='bold', zorder=4)

    for parent, child in edges:
        px, py, _ = nodes[parent]
        cx, cy, _ = nodes[child]
        ax1.annotate('', xy=(cx, cy + 0.45), xytext=(px, py - 0.45),
                    arrowprops=dict(arrowstyle='->', color='gray', lw=2))

    ax1.text(5, -0.2, 'Primitive factors (d=1) are the atoms',
            ha='center', fontsize=10, style='italic', color='#4ecdc4')

    # Panel 2: Energy decrease
    ax2.set_title('Degree-Conductor Energy Decrease', fontsize=14)

    # Show energy levels for various factorizations
    d_values = range(1, 6)
    q_values = range(1, 21)

    for d in d_values:
        energies = [dc_energy(d, q) for q in q_values]
        ax2.plot(q_values, energies, 'o-', markersize=4, linewidth=1.5,
                label=f'd = {d}', alpha=0.8)

    # Highlight the factorization: (2, 6) -> (1, 2) + (1, 3)
    ax2.annotate('', xy=(2, dc_energy(1, 2)), xytext=(6, dc_energy(2, 6)),
                arrowprops=dict(arrowstyle='->', color='red', lw=2))
    ax2.annotate('', xy=(3, dc_energy(1, 3)), xytext=(6, dc_energy(2, 6)),
                arrowprops=dict(arrowstyle='->', color='red', lw=2))
    ax2.plot(6, dc_energy(2, 6), 'r*', markersize=15, zorder=5)
    ax2.text(6.3, dc_energy(2, 6), 'Composite\n(d=2, q=6)', fontsize=9, color='red')

    ax2.set_xlabel('Conductor q', fontsize=12)
    ax2.set_ylabel('Energy E = d · q', fontsize=12)
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('factorization_energy.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved factorization_energy.png")


if __name__ == "__main__":
    main()
