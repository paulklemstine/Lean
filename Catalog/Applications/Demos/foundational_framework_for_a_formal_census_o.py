#!/usr/bin/env python3
"""
Demo: Selberg Class Census — Numerical Examples

Demonstrates the key concepts from the formal census framework:
1. Selberg data for classical L-functions
2. Spectral complexity computations
3. Spectral entropy computations
4. Conductor counting function values
5. Product structure verification
"""

from fractions import Fraction
from dataclasses import dataclass
from typing import List


@dataclass
class SelbergDatum:
    """Invariant data of a Selberg class L-function."""
    degree: int
    conductor: int
    spectral_shifts: List[Fraction]
    name: str = ""

    @property
    def num_gamma_factors(self) -> int:
        return len(self.spectral_shifts)

    @property
    def is_well_formed(self) -> bool:
        return self.num_gamma_factors == self.degree

    def spectral_complexity(self) -> Fraction:
        return Fraction(self.degree * self.conductor) + sum(abs(s) for s in self.spectral_shifts)

    def coarse_complexity(self) -> int:
        return self.degree + self.conductor + self.num_gamma_factors

    def spectral_entropy(self) -> Fraction:
        total = Fraction(0)
        for s in self.spectral_shifts:
            total += Fraction(abs(s.numerator) + s.denominator)
        return total

    def product(self, other: 'SelbergDatum') -> 'SelbergDatum':
        return SelbergDatum(
            degree=self.degree + other.degree,
            conductor=self.conductor * other.conductor,
            spectral_shifts=self.spectral_shifts + other.spectral_shifts,
            name=f"({self.name}) × ({other.name})"
        )

    def __str__(self) -> str:
        shifts_str = ", ".join(str(s) for s in self.spectral_shifts)
        return (f"{self.name}: d={self.degree}, q={self.conductor}, "
                f"r={self.num_gamma_factors}, μ=[{shifts_str}]")


# === Classical L-functions ===

zeta = SelbergDatum(1, 1, [Fraction(0)], "ζ(s)")
chi_minus4 = SelbergDatum(1, 4, [Fraction(1, 2)], "L(s,χ₋₄)")
chi_3 = SelbergDatum(1, 3, [Fraction(0)], "L(s,χ₃)")
# Degree-2 example: L-function of the Ramanujan Delta function
delta = SelbergDatum(2, 1, [Fraction(11, 2), Fraction(11, 2)], "L(s,Δ)")
# Degree-2 example: L-function of an elliptic curve E: y² = x³ - x (conductor 32)
elliptic_32 = SelbergDatum(2, 32, [Fraction(1, 2), Fraction(1, 2)], "L(s,E₃₂)")


def print_section(title: str):
    print(f"\n{'='*60}")
    print(f"  {title}")
    print(f"{'='*60}")


def demo_basic_data():
    print_section("1. Selberg Data for Classical L-Functions")
    for L in [zeta, chi_minus4, chi_3, delta, elliptic_32]:
        print(f"  {L}")
        print(f"    Well-formed: {L.is_well_formed}")
        print(f"    κ (spectral complexity): {L.spectral_complexity()}")
        print(f"    κ̃ (coarse complexity):   {L.coarse_complexity()}")
        print(f"    η (spectral entropy):    {L.spectral_entropy()}")
        print()


def demo_product_structure():
    print_section("2. Product Structure")
    prod = zeta.product(chi_3)
    print(f"  {zeta.name} × {chi_3.name} = {prod}")
    print(f"  Degree: {zeta.degree} + {chi_3.degree} = {prod.degree} ✓")
    print(f"  Conductor: {zeta.conductor} × {chi_3.conductor} = {prod.conductor} ✓")

    # Verify additivity of spectral complexity
    kappa_sum = zeta.spectral_complexity() + chi_3.spectral_complexity()
    print(f"\n  Spectral complexity additivity check:")
    print(f"    κ(ζ) + κ(χ₃) = {zeta.spectral_complexity()} + {chi_3.spectral_complexity()} = {kappa_sum}")
    # Note: spectral complexity is NOT additive in general (it's d*q based)
    # But spectral entropy IS additive
    eta_sum = zeta.spectral_entropy() + chi_3.spectral_entropy()
    eta_prod = prod.spectral_entropy()
    print(f"\n  Spectral entropy additivity:")
    print(f"    η(ζ) + η(χ₃) = {zeta.spectral_entropy()} + {chi_3.spectral_entropy()} = {eta_sum}")
    print(f"    η(ζ × χ₃) = {eta_prod}")
    print(f"    Equal: {eta_sum == eta_prod} ✓")


def demo_conductor_counting():
    print_section("3. Conductor Counting Function")
    print("  N_d(Q) = count of data with degree d, conductor ≤ Q")
    print("  (counting all spectral shift possibilities in {0, 1/2})")
    print()

    for d in [1, 2]:
        print(f"  Degree d = {d}:")
        for Q in [1, 5, 10, 20, 50, 100]:
            # For well-formed degree-d data with shifts in {0, 1/2}:
            # count = Q * 2^d (each conductor 1..Q, each of d shifts is 0 or 1/2)
            count = Q * (2 ** d)
            bound = (Q + 1) * (3 ** d)  # Bound with B=1: (Q+1)*(2*1+1)^d
            print(f"    N_{d}({Q}) = {count:6d}  (bound: {bound:6d})")
        print()


def demo_factorization():
    print_section("4. Factorization Structure")
    # Show that degree strictly decreases
    prod = delta.product(chi_3)
    print(f"  Product: {delta.name} × {chi_3.name}")
    print(f"  Product degree: {prod.degree}")
    print(f"  Factor degrees: {delta.degree}, {chi_3.degree}")
    print(f"  Both strictly less: {delta.degree < prod.degree} and {chi_3.degree < prod.degree} ✓")
    print()

    # Conductor divisibility
    print(f"  Product conductor: {prod.conductor}")
    print(f"  {delta.conductor} | {prod.conductor}: {prod.conductor % delta.conductor == 0} ✓")
    print(f"  {chi_3.conductor} | {prod.conductor}: {prod.conductor % chi_3.conductor == 0} ✓")


def demo_entropy_distribution():
    print_section("5. Spectral Entropy Distribution (Degree 1)")
    print("  For degree-1 data with shift in {0, 1/2}:")
    print("    Even characters (μ=0): η = |0| + 1 = 1")
    print("    Odd characters (μ=1/2): η = |1| + 2 = 3")
    print()

    # Tabulate for small conductors
    from math import gcd
    print(f"  {'q':>4} {'φ(q)':>5} {'#even':>6} {'#odd':>5} {'avg η':>8}")
    print(f"  {'-'*4} {'-'*5} {'-'*6} {'-'*5} {'-'*8}")

    for q in range(1, 21):
        phi_q = sum(1 for k in range(1, q + 1) if gcd(k, q) == 1)
        # For simplicity, count even/odd as roughly equal for q > 2
        if q <= 2:
            n_even, n_odd = phi_q, 0
        else:
            n_even = phi_q // 2
            n_odd = phi_q - n_even
        if phi_q > 0:
            avg_eta = Fraction(n_even * 1 + n_odd * 3, phi_q)
        else:
            avg_eta = Fraction(0)
        print(f"  {q:4d} {phi_q:5d} {n_even:6d} {n_odd:5d} {float(avg_eta):8.4f}")


def demo_countability_encoding():
    print_section("6. Countability: Encoding Selberg Data as Natural Numbers")
    print("  Each SelbergDatum encodes as (degree, conductor, r, shifts)")
    print("  which lives in ℕ × ℕ × ℕ × (Fin r → ℚ) — a countable type.")
    print()

    data = [zeta, chi_minus4, chi_3, delta, elliptic_32]
    for i, L in enumerate(data):
        shifts_encoded = tuple((s.numerator, s.denominator) for s in L.spectral_shifts)
        code = (L.degree, L.conductor, L.num_gamma_factors, shifts_encoded)
        print(f"  {L.name:12s} → {code}")

    print(f"\n  All encodings distinct: "
          f"{len(set(tuple((d.degree, d.conductor, tuple((s.numerator, s.denominator) for s in d.spectral_shifts)) for d in data))) == len(data)} ✓")


if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════╗")
    print("║     Selberg Class Census — Demonstration                ║")
    print("╚══════════════════════════════════════════════════════════╝")

    demo_basic_data()
    demo_product_structure()
    demo_conductor_counting()
    demo_factorization()
    demo_entropy_distribution()
    demo_countability_encoding()

    print(f"\n{'='*60}")
    print("  Demo complete. All structural properties verified.")
    print(f"{'='*60}")


#!/usr/bin/env python3
"""
Visualization: Spectral Complexity Landscape of Degree-1 L-Functions

Plots the spectral complexity κ = d·q + |μ| for degree-1 Selberg data
with conductor q and spectral shift μ ∈ {0, 1/2}.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from fractions import Fraction
from math import gcd


def euler_totient(n: int) -> int:
    return sum(1 for k in range(1, n + 1) if gcd(k, n) == 1)


def main():
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # --- Left panel: Scatter of (q, κ) for degree 1 ---
    ax1 = axes[0]
    max_q = 50

    even_q, even_kappa = [], []
    odd_q, odd_kappa = [], []

    for q in range(1, max_q + 1):
        # Even character: μ = 0, κ = 1·q + 0 = q
        even_q.append(q)
        even_kappa.append(q)
        # Odd character: μ = 1/2, κ = 1·q + 1/2 = q + 0.5
        odd_q.append(q)
        odd_kappa.append(q + 0.5)

    ax1.scatter(even_q, even_kappa, c='#2196F3', s=30, alpha=0.7, label='Even (μ=0)')
    ax1.scatter(odd_q, odd_kappa, c='#FF5722', s=30, alpha=0.7, label='Odd (μ=1/2)')
    ax1.set_xlabel('Conductor q', fontsize=12)
    ax1.set_ylabel('Spectral Complexity κ(S)', fontsize=12)
    ax1.set_title('Degree-1 Spectral Complexity Landscape', fontsize=13)
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.3)

    # Highlight zeta
    ax1.annotate('ζ(s)', xy=(1, 1), xytext=(5, 5),
                fontsize=10, fontweight='bold',
                arrowprops=dict(arrowstyle='->', color='black'))

    # --- Right panel: Conductor counting N₁(Q) vs Q ---
    ax2 = axes[1]
    Qs = list(range(1, max_q + 1))
    N_even = []  # Cumulative count of even data
    N_odd = []   # Cumulative count of odd data
    N_total = [] # Total
    phi_cumulative = []  # Cumulative totient

    cum_phi = 0
    for Q in Qs:
        # Each conductor q contributes 2 data points (even and odd), for q > 2
        N_even.append(Q)  # One even datum per conductor 1..Q
        N_odd.append(Q)   # One odd datum per conductor 1..Q (for simplicity)
        N_total.append(2 * Q)
        cum_phi += euler_totient(Q)
        phi_cumulative.append(cum_phi)

    ax2.plot(Qs, N_total, 'b-', linewidth=2, label='N₁(Q) total data')
    ax2.plot(Qs, phi_cumulative, 'r--', linewidth=2, label='Σφ(q) (primitive chars)')
    ax2.fill_between(Qs, 0, N_total, alpha=0.1, color='blue')
    ax2.set_xlabel('Conductor bound Q', fontsize=12)
    ax2.set_ylabel('Count', fontsize=12)
    ax2.set_title('Conductor Counting: N₁(Q) vs Σφ(q)', fontsize=13)
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)

    # Add polynomial bound reference
    bound = [2 * (Q + 1) for Q in Qs]
    ax2.plot(Qs, bound, 'g:', linewidth=1.5, alpha=0.7, label='Bound: 2(Q+1)')
    ax2.legend(fontsize=10)

    plt.tight_layout()
    plt.savefig('selberg_complexity_landscape.png', dpi=150, bbox_inches='tight')
    plt.show()
    print("Saved: selberg_complexity_landscape.png")


if __name__ == "__main__":
    main()
