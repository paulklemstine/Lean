#!/usr/bin/env python3
"""
Visualization: Schanuel Independence Landscape

Visualizes the landscape of ℚ-linear independence for pairs of algebraic numbers
with bounded rational coordinates. Each pixel represents a pair (z₁, z₂) where
z_i = a_i·1 + b_i·√2, and the color indicates whether the pair is certified
ℚ-linearly independent (blue) or dependent (red).

This directly illustrates the domain of applicability of the Schanuel lower bound:
blue regions are where the conjecture produces genuine transcendence consequences;
red regions are where schanuel_vacuous_on_dependent_tuples applies.
"""

import numpy as np
import matplotlib.pyplot as plt
from fractions import Fraction

def rational_rank_2x2(a, b, c, d):
    """Rank of [[a,b],[c,d]] over ℚ."""
    # det = ad - bc
    det = a * d - b * c
    if det != 0:
        return 2
    if a != 0 or b != 0 or c != 0 or d != 0:
        return 1
    return 0

def main():
    # We represent z₁ = a₁ + b₁√2, z₂ = a₂ + b₂√2
    # Coordinate matrix: [[a₁, a₂], [b₁, b₂]]
    # Independent iff det(M) = a₁b₂ - a₂b₁ ≠ 0
    
    bound = 10
    coords = np.arange(-bound, bound + 1)
    
    # For visualization, fix b₁ and vary a₁, a₂ with b₂ 
    # Actually, let's do a 2D slice: fix z₁ = 1 (a₁=1, b₁=0)
    # and vary z₂ = a₂ + b₂√2
    
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))
    
    # Panel 1: Independence landscape for pairs in ℚ(√2)
    # z₁ = a₁ + b₁√2, z₂ = a₂ + b₂√2
    # Fix z₁ = 1 (a₁=1, b₁=0), vary z₂
    N = 41
    a2_range = np.linspace(-5, 5, N)
    b2_range = np.linspace(-5, 5, N)
    
    indep_map = np.zeros((N, N))
    for i, b2 in enumerate(b2_range):
        for j, a2 in enumerate(a2_range):
            # z₁ = 1, z₂ = a₂ + b₂√2
            # Coord matrix: [[1, a₂], [0, b₂]]
            # Rank = 2 iff b₂ ≠ 0
            # But we use rational approximations
            a2_frac = Fraction(a2).limit_denominator(100)
            b2_frac = Fraction(b2).limit_denominator(100)
            det = Fraction(1) * b2_frac - a2_frac * Fraction(0)  # 1·b₂ - a₂·0 = b₂
            indep_map[i, j] = 1 if det != 0 else 0
    
    im1 = axes[0].imshow(indep_map, extent=[-5, 5, -5, 5], origin='lower',
                          cmap='RdBu', aspect='auto', vmin=0, vmax=1)
    axes[0].set_xlabel('a₂ (rational component)', fontsize=12)
    axes[0].set_ylabel('b₂ (√2 component)', fontsize=12)
    axes[0].set_title('Independence: z₁ = 1, z₂ = a₂ + b₂√2', fontsize=13)
    axes[0].axhline(y=0, color='black', linewidth=0.5, linestyle='--', alpha=0.5)
    axes[0].text(0, -4.5, 'Red = dependent\n(Schanuel vacuous)', 
                 ha='center', fontsize=10, color='darkred',
                 bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))
    axes[0].text(0, 3.5, 'Blue = independent\n(Schanuel applicable)', 
                 ha='center', fontsize=10, color='darkblue',
                 bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))
    
    # Panel 2: General pairs z₁ = a₁ + b₁√2, z₂ = a₂ + b₂√2
    # Fix a₁=1, b₁=1 (z₁ = 1+√2), vary z₂ = a₂ + b₂√2
    N2 = 41
    indep_map2 = np.zeros((N2, N2))
    for i, b2 in enumerate(np.linspace(-5, 5, N2)):
        for j, a2 in enumerate(np.linspace(-5, 5, N2)):
            a2_frac = Fraction(a2).limit_denominator(100)
            b2_frac = Fraction(b2).limit_denominator(100)
            # Coord matrix: [[1, a₂], [1, b₂]]
            det = Fraction(1) * b2_frac - a2_frac * Fraction(1)  # b₂ - a₂
            indep_map2[i, j] = 1 if det != 0 else 0
    
    im2 = axes[1].imshow(indep_map2, extent=[-5, 5, -5, 5], origin='lower',
                          cmap='RdBu', aspect='auto', vmin=0, vmax=1)
    axes[1].set_xlabel('a₂ (rational component)', fontsize=12)
    axes[1].set_ylabel('b₂ (√2 component)', fontsize=12)
    axes[1].set_title('Independence: z₁ = 1+√2, z₂ = a₂ + b₂√2', fontsize=13)
    # Draw the dependency line b₂ = a₂
    axes[1].plot([-5, 5], [-5, 5], 'r-', linewidth=2, alpha=0.7, label='b₂ = a₂ (dependent)')
    axes[1].legend(fontsize=10)
    
    plt.suptitle('Schanuel Independence Landscape\nBlue = certified independent → transcendence consequences',
                 fontsize=14, fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig('viz_schanuel_landscape.png', dpi=150, bbox_inches='tight')
    print("Saved viz_schanuel_landscape.png")

if __name__ == "__main__":
    main()
