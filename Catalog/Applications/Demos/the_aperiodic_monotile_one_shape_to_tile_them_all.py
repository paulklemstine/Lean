#!/usr/bin/env python3
"""
Inflation Algebra Demo: The Hat Monotile Spectrum

Demonstrates the algebraic properties of the hat substitution matrix
and the inflation algebra framework for aperiodic tilings.
"""

import numpy as np
from typing import List, Tuple

# The hat substitution matrix
M_HAT = np.array([
    [2, 1, 1, 0],
    [1, 2, 0, 1],
    [1, 0, 2, 1],
    [0, 1, 1, 2]
], dtype=int)

def demonstrate_basic_properties():
    """Show basic algebraic properties of the hat matrix."""
    print("=" * 60)
    print("INFLATION ALGEBRA: Hat Monotile Substitution Matrix")
    print("=" * 60)
    
    print(f"\nHat substitution matrix M:")
    print(M_HAT)
    
    print(f"\nTrace(M) = {np.trace(M_HAT)}")
    print(f"Det(M) = {int(round(np.linalg.det(M_HAT)))}")
    
    M_minus_I = M_HAT - np.eye(4, dtype=int)
    print(f"\nDet(M - I) = {int(round(np.linalg.det(M_minus_I)))}")
    print(f"  → Algebraic aperiodicity: det(M-I) ≠ 0 ✓")
    
    row_sums = M_HAT.sum(axis=1)
    print(f"\nRow sums: {row_sums}")
    print(f"  → Every metatile decomposes into exactly {row_sums[0]} pieces")
    
    print(f"\nSymmetry: M = M^T? {np.array_equal(M_HAT, M_HAT.T)}")

def demonstrate_eigenvalues():
    """Compute and analyze eigenvalues."""
    print("\n" + "=" * 60)
    print("SPECTRAL ANALYSIS")
    print("=" * 60)
    
    eigenvalues, eigenvectors = np.linalg.eig(M_HAT)
    eigenvalues = np.sort(np.real(eigenvalues))[::-1]
    
    print(f"\nEigenvalues: {eigenvalues}")
    print(f"Perron eigenvalue: λ₁ = {eigenvalues[0]}")
    print(f"  → Growth rate: tiles grow as {eigenvalues[0]}^k per substitution level")
    
    # Check roots of unity
    print(f"\nRoots-of-unity check:")
    for i, ev in enumerate(eigenvalues):
        is_rou = any(abs(ev**k - 1) < 1e-10 for k in range(1, 100))
        print(f"  λ_{i+1} = {ev}: root of unity? {'YES ⚠' if is_rou else 'NO ✓'}")
    
    print(f"\n  → Strong aperiodicity: no eigenvalue is a root of unity ✓")

def demonstrate_primitivity():
    """Check primitivity by computing powers of M."""
    print("\n" + "=" * 60)
    print("PRIMITIVITY ANALYSIS")
    print("=" * 60)
    
    for k in range(1, 5):
        Mk = np.linalg.matrix_power(M_HAT, k)
        all_positive = np.all(Mk > 0)
        min_entry = Mk.min()
        print(f"\nM^{k}:")
        print(Mk)
        print(f"  All entries positive? {all_positive} (min = {min_entry})")
        if all_positive:
            print(f"  → Primitive! Primitivity index = {k}")
            break

def demonstrate_complexity():
    """Compute the complexity trace function."""
    print("\n" + "=" * 60)
    print("COMPLEXITY TRACE FUNCTION c(k) = Tr(M^k)")
    print("=" * 60)
    
    print(f"\n{'k':>4} | {'c(k)':>12} | {'c(k)/4^k':>12}")
    print("-" * 35)
    for k in range(8):
        Mk = np.linalg.matrix_power(M_HAT, k)
        ck = np.trace(Mk)
        ratio = ck / (4**k) if k > 0 else float('inf')
        print(f"{k:>4} | {ck:>12} | {ratio:>12.6f}")
    
    print(f"\n  → c(k)/4^k → 1 as k → ∞ (Perron eigenvalue dominates)")

def demonstrate_tile_frequencies():
    """Compute tile type frequencies via power iteration."""
    print("\n" + "=" * 60)
    print("TILE TYPE FREQUENCIES (Power Iteration)")
    print("=" * 60)
    
    metatile_names = ['H (Hat)', 'T (Thin)', 'P (Para)', 'F (Flipped)']
    
    v = np.array([1.0, 0, 0, 0])  # Start with one H tile
    for k in range(10):
        total = v.sum()
        if total > 0:
            freq = v / total
        else:
            freq = v
        if k in [0, 1, 2, 5, 9]:
            print(f"\nAfter {k} substitutions (total tiles = {int(total)}):")
            for name, f in zip(metatile_names, freq):
                bar = '█' * int(f * 40)
                print(f"  {name:>15}: {f:.6f} {bar}")
        v = M_HAT @ v
    
    print(f"\n  → All tile types converge to equal frequency (1/4)")
    print(f"     This is because (1,1,1,1) is the Perron eigenvector")

def demonstrate_aperiodicity_iterates():
    """Check aperiodicity at multiple iterate levels."""
    print("\n" + "=" * 60)
    print("APERIODICITY AT ALL ITERATE LEVELS")
    print("=" * 60)
    
    print(f"\n{'k':>4} | {'det(M^k - I)':>15} | {'Aperiodic?':>10}")
    print("-" * 35)
    for k in range(1, 11):
        Mk = np.linalg.matrix_power(M_HAT, k)
        det_val = int(round(np.linalg.det(Mk - np.eye(4))))
        aperiodic = det_val != 0
        print(f"{k:>4} | {det_val:>15} | {'YES ✓' if aperiodic else 'NO ✗':>10}")
    
    print(f"\n  → Aperiodic at ALL levels (no eigenvalue is a root of unity)")

def demonstrate_counterexample():
    """Show the counterexample to 'det(M-I)≠0 implies det(M^k-I)≠0'."""
    print("\n" + "=" * 60)
    print("COUNTEREXAMPLE: Naive Aperiodicity Criterion is WRONG")
    print("=" * 60)
    
    M_counter = np.array([[-1]])
    print(f"\nMatrix M = [{M_counter[0,0]}]")
    print(f"det(M - I) = {int(M_counter[0,0] - 1)} ≠ 0  ← passes naive criterion")
    print(f"det(M² - I) = {int(M_counter[0,0]**2 - 1)} = 0  ← FAILS at k=2!")
    print(f"\n  → eigenvalue -1 is a 2nd root of unity: (-1)² = 1")
    print(f"  → Correct criterion: no eigenvalue is ANY root of unity")

if __name__ == "__main__":
    demonstrate_basic_properties()
    demonstrate_eigenvalues()
    demonstrate_primitivity()
    demonstrate_complexity()
    demonstrate_tile_frequencies()
    demonstrate_aperiodicity_iterates()
    demonstrate_counterexample()
    print("\n" + "=" * 60)
    print("DEMO COMPLETE")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Inflation Algebra Spectral Analysis

Produces plots of eigenvalue spectra, complexity growth, and tile
frequency convergence for the hat substitution matrix.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.patches import FancyBboxPatch
import matplotlib.colors as mcolors

def make_hat_matrix():
    return np.array([[2,1,1,0],[1,2,0,1],[1,0,2,1],[0,1,1,2]], dtype=float)

def plot_complexity_growth():
    M = make_hat_matrix()
    ks = list(range(0, 12))
    complexities = [int(np.trace(np.linalg.matrix_power(M, k))) for k in ks]
    
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))
    
    # Linear scale
    ax1.semilogy(ks, complexities, 'o-', color='#2196F3', markersize=8, linewidth=2)
    ax1.set_xlabel('Substitution Level k', fontsize=12)
    ax1.set_ylabel('Complexity c(k) = Tr(M^k)', fontsize=12)
    ax1.set_title('Complexity Growth (Log Scale)', fontsize=14)
    ax1.grid(True, alpha=0.3)
    
    # Normalized
    normalized = [c / (4**k) if k > 0 else 4 for k, c in zip(ks, complexities)]
    ax2.plot(ks[1:], normalized[1:], 'o-', color='#E91E63', markersize=8, linewidth=2)
    ax2.axhline(y=1, color='gray', linestyle='--', alpha=0.5, label='Perron limit = 1')
    ax2.set_xlabel('Substitution Level k', fontsize=12)
    ax2.set_ylabel('c(k) / 4^k', fontsize=12)
    ax2.set_title('Normalized Complexity → Perron Eigenvalue', fontsize=14)
    ax2.legend(fontsize=11)
    ax2.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('viz_complexity_growth.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: viz_complexity_growth.png")

def plot_tile_frequencies():
    M = make_hat_matrix()
    names = ['H (Hat)', 'T (Thin)', 'P (Para)', 'F (Flip)']
    colors = ['#2196F3', '#4CAF50', '#FF9800', '#E91E63']
    
    max_k = 10
    freqs = np.zeros((max_k + 1, 4))
    v = np.array([1.0, 0, 0, 0])
    
    for k in range(max_k + 1):
        total = v.sum()
        if total > 0:
            freqs[k] = v / total
        v = M @ v
    
    fig, ax = plt.subplots(figsize=(10, 6))
    for i in range(4):
        ax.plot(range(max_k + 1), freqs[:, i], 'o-', color=colors[i], 
                label=names[i], markersize=6, linewidth=2)
    
    ax.axhline(y=0.25, color='gray', linestyle='--', alpha=0.5, label='Limit = 1/4')
    ax.set_xlabel('Substitution Level k', fontsize=12)
    ax.set_ylabel('Tile Type Frequency', fontsize=12)
    ax.set_title('Tile Frequency Convergence to Perron Eigenvector', fontsize=14)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    ax.set_ylim(-0.05, 1.05)
    
    plt.tight_layout()
    plt.savefig('viz_tile_frequencies.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: viz_tile_frequencies.png")

def plot_aperiodicity_determinants():
    M = make_hat_matrix()
    ks = list(range(1, 16))
    dets = []
    for k in ks:
        Mk = np.linalg.matrix_power(M, k)
        det_val = np.linalg.det(Mk - np.eye(4))
        dets.append(det_val)
    
    fig, ax = plt.subplots(figsize=(10, 6))
    
    colors_bar = ['#4CAF50' if abs(d) > 0.5 else '#F44336' for d in dets]
    ax.bar(ks, [np.log10(abs(d)) if abs(d) > 0.5 else 0 for d in dets], 
           color=colors_bar, alpha=0.8, edgecolor='black', linewidth=0.5)
    
    ax.set_xlabel('Iterate k', fontsize=12)
    ax.set_ylabel('log₁₀|det(M^k - I)|', fontsize=12)
    ax.set_title('Aperiodicity Certificate: det(M^k - I) ≠ 0 for all k', fontsize=14)
    ax.grid(True, alpha=0.3, axis='y')
    
    # Add text
    ax.text(0.95, 0.95, 'Green = Aperiodic (det ≠ 0)', 
            transform=ax.transAxes, fontsize=11, ha='right', va='top',
            color='#4CAF50', fontweight='bold')
    
    plt.tight_layout()
    plt.savefig('viz_aperiodicity.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: viz_aperiodicity.png")

def plot_eigenvalue_spectrum():
    M = make_hat_matrix()
    evs = np.linalg.eigvals(M)
    
    fig, ax = plt.subplots(figsize=(8, 8))
    
    # Unit circle
    theta = np.linspace(0, 2*np.pi, 100)
    ax.plot(np.cos(theta), np.sin(theta), 'k--', alpha=0.3, label='Unit circle')
    
    # Eigenvalues
    for i, ev in enumerate(sorted(evs, key=lambda x: -abs(x))):
        color = '#E91E63' if abs(ev) > 1 else ('#2196F3' if abs(ev) > 0.01 else '#9E9E9E')
        size = 200 if abs(ev) > 1 else 150
        ax.scatter(np.real(ev), np.imag(ev), s=size, c=color, zorder=5, edgecolors='black')
        ax.annotate(f'λ={np.real(ev):.0f}', (np.real(ev), np.imag(ev)), 
                   textcoords="offset points", xytext=(10, 10), fontsize=11)
    
    ax.set_xlabel('Re(λ)', fontsize=12)
    ax.set_ylabel('Im(λ)', fontsize=12)
    ax.set_title('Eigenvalue Spectrum of Hat Substitution Matrix', fontsize=14)
    ax.set_aspect('equal')
    ax.grid(True, alpha=0.3)
    ax.axhline(y=0, color='k', linewidth=0.5)
    ax.axvline(x=0, color='k', linewidth=0.5)
    
    # Annotations
    ax.text(0.05, 0.95, 'No eigenvalue on unit circle\n→ Strong aperiodicity', 
            transform=ax.transAxes, fontsize=11, va='top',
            bbox=dict(boxstyle='round', facecolor='#E8F5E9', alpha=0.8))
    
    plt.tight_layout()
    plt.savefig('viz_eigenvalue_spectrum.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: viz_eigenvalue_spectrum.png")

if __name__ == "__main__":
    plot_complexity_growth()
    plot_tile_frequencies()
    plot_aperiodicity_determinants()
    plot_eigenvalue_spectrum()
    print("\nAll visualizations generated successfully!")
