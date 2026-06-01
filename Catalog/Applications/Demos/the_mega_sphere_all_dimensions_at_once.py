#!/usr/bin/env python3
"""
Demo: The Mega-Sphere — All Dimensions at Once

Numerical demonstrations of the key constructions and theorems
from the Mega-Sphere formalization.
"""

from algorithms import (
    sphere_euler_char,
    sphere_euler_char_sum,
    bernoulli_prime,
    bernoulli_sphere_weight,
    bernoulli_sphere_invariant,
    sphere_char_poly_coeffs,
    sphere_char_poly_eval,
    InverseSystemElement,
    euler_encoding,
    verify_euler_encoding_unfilterable,
)
from fractions import Fraction


def demo_euler_characteristics():
    """Demonstrate sphere Euler characteristics."""
    print("=" * 60)
    print("DEMO 1: Sphere Euler Characteristics χ(Sⁿ)")
    print("=" * 60)
    print(f"{'n':>4} | {'χ(Sⁿ)':>6} | {'Even/Odd':>8}")
    print("-" * 30)
    for n in range(12):
        chi = sphere_euler_char(n)
        parity = "even" if n % 2 == 0 else "odd"
        print(f"{n:>4} | {chi:>6} | {parity:>8}")
    
    print(f"\nPartial sums (verified theorem: Σ_{{i<2k+1}} χ(Sⁱ) = 2k+2):")
    for k in range(6):
        N = 2 * k + 1
        s = sphere_euler_char_sum(N - 1)  # sum over range(N) = {0,...,N-1}
        expected = 2 * k + 2
        print(f"  k={k}: Σ_{{i<{N}}} χ(Sⁱ) = {s} (expected {expected}) {'✓' if s == expected else '✗'}")
    print()


def demo_bernoulli_numbers():
    """Demonstrate Bernoulli numbers and the sphere weight function."""
    print("=" * 60)
    print("DEMO 2: Bernoulli Numbers and Sphere Weights")
    print("=" * 60)
    header = "B'_n"
    print(f"{'n':>4} | {header:>12} | {'BSW(n)':>12} | {'BSI(n)':>12}")
    print("-" * 55)
    for n in range(13):
        bn = bernoulli_prime(n)
        bsw = bernoulli_sphere_weight(n)
        bsi = bernoulli_sphere_invariant(n)
        print(f"{n:>4} | {str(bn):>12} | {str(bsw):>12} | {str(bsi):>12}")
    
    print(f"\nKey observation: BSW(2k+1) = 0 for all k (parity alignment)")
    for k in range(6):
        bsw = bernoulli_sphere_weight(2 * k + 1)
        print(f"  BSW({2*k+1}) = {bsw} {'✓' if bsw == 0 else '✗'}")
    
    print(f"\nOdd-step invariance: BSI(2k+1) = BSI(2k)")
    for k in range(6):
        bsi_odd = bernoulli_sphere_invariant(2 * k + 1)
        bsi_even = bernoulli_sphere_invariant(2 * k)
        print(f"  BSI({2*k+1}) = BSI({2*k}) = {bsi_even} {'✓' if bsi_odd == bsi_even else '✗'}")
    print()


def demo_characteristic_polynomials():
    """Demonstrate characteristic polynomials of spheres."""
    print("=" * 60)
    print("DEMO 3: Characteristic Polynomials p_n(X) = X^n + (-1)^n")
    print("=" * 60)
    for n in range(6):
        coeffs = sphere_char_poly_coeffs(n)
        eval1 = sphere_char_poly_eval(n, 1)
        chi = sphere_euler_char(n)
        terms = []
        for i, c in enumerate(coeffs):
            if c != 0:
                if i == 0:
                    terms.append(str(c))
                elif i == 1:
                    terms.append(f"{c}X" if c != 1 else "X")
                else:
                    terms.append(f"X^{i}" if c == 1 else f"{c}X^{i}")
        poly_str = " + ".join(terms) if terms else "0"
        print(f"  p_{n}(X) = {poly_str}")
        print(f"    p_{n}(1) = {eval1} = χ(S^{n}) {'✓' if eval1 == chi else '✗'}")
        if n >= 1:
            print(f"    deg(p_{n}) = {n}, monic ✓")
    print()


def demo_inverse_limit():
    """Demonstrate the inverse limit construction."""
    print("=" * 60)
    print("DEMO 4: Inverse Limit (Mega-Sphere) Construction")
    print("=" * 60)
    
    # Create the Euler encoding
    enc = euler_encoding(20)
    print("Euler encoding element of the Mega-Sphere:")
    print(f"  Sequence: {enc.to_seq(15)}")
    print(f"  Compatibility verified: {enc.verify_compatibility(50)}")
    
    print(f"\nProjections (truncations at each level):")
    for n in range(6):
        proj = enc.proj(n)
        print(f"  π_{n}: {proj}")
        if n > 0:
            bond = enc.bond(n - 1)
            proj_prev = enc.proj(n - 1)
            print(f"    bond_{n-1}(π_{n}) = {bond} = π_{n-1} {'✓' if bond == proj_prev else '✗'}")
    
    print(f"\nFiltration check (Euler encoding has infinite support):")
    print(f"  Not filtered: {verify_euler_encoding_unfilterable(100)}")
    print()


def demo_bernoulli_sphere_growth():
    """Demonstrate growth of the Bernoulli-sphere invariant."""
    print("=" * 60)
    print("DEMO 5: Bernoulli-Sphere Invariant Growth")
    print("=" * 60)
    print("Testing conjecture: |BSI(2N)| ≤ C·N² for some constant C")
    print()
    print(f"{'N':>4} | {'BSI(2N)':>20} | {'|BSI(2N)|':>12} | {'N²':>6} | {'ratio':>10}")
    print("-" * 60)
    
    for N in range(1, 16):
        bsi = bernoulli_sphere_invariant(2 * N)
        abs_bsi = abs(bsi)
        n_sq = N * N
        ratio = float(abs_bsi) / n_sq if n_sq > 0 else float('inf')
        print(f"{N:>4} | {str(bsi):>20} | {float(abs_bsi):>12.4f} | {n_sq:>6} | {ratio:>10.4f}")
    
    print("\nConclusion: The ratio grows without bound (conjecture is FALSE)")
    print("due to the rapid growth of Bernoulli numbers |B_{2n}| ~ 4√(πn)(n/(πe))^{2n}")
    print()


if __name__ == "__main__":
    demo_euler_characteristics()
    demo_bernoulli_numbers()
    demo_characteristic_polynomials()
    demo_inverse_limit()
    demo_bernoulli_sphere_growth()


#!/usr/bin/env python3
"""
Visualization: The Mega-Sphere — Sphere Tower and Bernoulli Alignment

Creates a multi-panel figure showing:
1. Euler characteristics across dimensions
2. Bernoulli-sphere weight function
3. Cumulative invariant growth
4. Characteristic polynomial roots
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from fractions import Fraction
import math


def bernoulli_prime(n, cache={}):
    if n in cache:
        return cache[n]
    if n == 0:
        cache[0] = Fraction(1)
        return Fraction(1)
    s = Fraction(0)
    for k in range(n):
        binom = math.comb(n, n - k)
        s += Fraction(binom, n - k + 1) * bernoulli_prime(k, cache)
    result = Fraction(1) - s
    cache[n] = result
    return result


def sphere_euler_char(n):
    return 1 + (-1) ** n


def bernoulli_sphere_weight(n):
    return bernoulli_prime(n) * Fraction(1 + (-1) ** n)


def bernoulli_sphere_invariant(N):
    return sum(bernoulli_sphere_weight(k) for k in range(N + 1))


fig, axes = plt.subplots(2, 2, figsize=(14, 10))
fig.suptitle('The Mega-Sphere: All Dimensions at Once', fontsize=16, fontweight='bold')

# Panel 1: Euler characteristics
ax1 = axes[0, 0]
dims = list(range(20))
chis = [sphere_euler_char(n) for n in dims]
colors = ['#2196F3' if n % 2 == 0 else '#FF5722' for n in dims]
ax1.bar(dims, chis, color=colors, alpha=0.8, edgecolor='black', linewidth=0.5)
ax1.set_xlabel('Dimension n', fontsize=11)
ax1.set_ylabel('χ(Sⁿ)', fontsize=11)
ax1.set_title('Euler Characteristic χ(Sⁿ) = 1 + (-1)ⁿ', fontsize=12)
ax1.set_ylim(-0.5, 2.5)
even_patch = mpatches.Patch(color='#2196F3', label='Even dim (χ=2)')
odd_patch = mpatches.Patch(color='#FF5722', label='Odd dim (χ=0)')
ax1.legend(handles=[even_patch, odd_patch], fontsize=9)
ax1.grid(axis='y', alpha=0.3)

# Panel 2: Bernoulli-sphere weights
ax2 = axes[0, 1]
N_max = 24
bsw_vals = [float(bernoulli_sphere_weight(n)) for n in range(N_max + 1)]
bar_colors = ['#4CAF50' if v >= 0 else '#F44336' for v in bsw_vals]
ax2.bar(range(N_max + 1), bsw_vals, color=bar_colors, alpha=0.8, 
        edgecolor='black', linewidth=0.5)
ax2.set_xlabel('Dimension n', fontsize=11)
ax2.set_ylabel('BSW(n) = B\'_n · (1+(-1)ⁿ)', fontsize=11)
ax2.set_title('Bernoulli-Sphere Weight Function', fontsize=12)
ax2.axhline(y=0, color='black', linewidth=0.5)
ax2.grid(axis='y', alpha=0.3)

# Panel 3: Cumulative invariant
ax3 = axes[1, 0]
N_range = list(range(25))
bsi_vals = [float(bernoulli_sphere_invariant(n)) for n in N_range]
ax3.plot(N_range, bsi_vals, 'o-', color='#9C27B0', markersize=4, linewidth=1.5)
ax3.fill_between(N_range, bsi_vals, alpha=0.15, color='#9C27B0')
ax3.set_xlabel('Dimension N', fontsize=11)
ax3.set_ylabel('BSI(N)', fontsize=11)
ax3.set_title('Cumulative Bernoulli-Sphere Invariant', fontsize=12)
ax3.grid(alpha=0.3)
# Highlight odd-step invariance
for k in range(12):
    ax3.plot([2*k, 2*k+1], [bsi_vals[2*k], bsi_vals[2*k+1]], 
             color='#FF9800', linewidth=3, alpha=0.6)

# Panel 4: Characteristic polynomial roots in complex plane
ax4 = axes[1, 1]
for n in range(1, 9):
    # Roots of X^n + (-1)^n = 0, i.e., X^n = -(-1)^n = (-1)^{n+1}
    roots = []
    for k in range(n):
        if n % 2 == 0:
            # X^n = -1, roots are e^{i(2k+1)π/n}
            angle = (2 * k + 1) * np.pi / n
        else:
            # X^n = 1, roots are e^{i·2kπ/n}
            angle = 2 * k * np.pi / n
        roots.append(complex(np.cos(angle), np.sin(angle)))
    
    xs = [r.real for r in roots]
    ys = [r.imag for r in roots]
    ax4.scatter(xs, ys, s=30, alpha=0.7, label=f'n={n}', zorder=3)

theta = np.linspace(0, 2 * np.pi, 100)
ax4.plot(np.cos(theta), np.sin(theta), 'k--', alpha=0.3, linewidth=1)
ax4.set_xlabel('Re(z)', fontsize=11)
ax4.set_ylabel('Im(z)', fontsize=11)
ax4.set_title('Roots of Sphere Char. Polynomials', fontsize=12)
ax4.set_aspect('equal')
ax4.legend(fontsize=7, ncol=2, loc='upper right')
ax4.grid(alpha=0.3)

plt.tight_layout()
plt.savefig('megasphere_visualization.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved megasphere_visualization.png")
