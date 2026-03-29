"""
Langlands Program: Publication-Quality Visualizations
=====================================================

Generates matplotlib plots for the research paper and article.

Usage: python langlands_plots.py
Output: PNG files in the current directory.
"""

import numpy as np
import math
import os
from typing import List, Tuple

try:
    import matplotlib
    matplotlib.use('Agg')
    import matplotlib.pyplot as plt
    HAS_MATPLOTLIB = True
except ImportError:
    HAS_MATPLOTLIB = False
    print("matplotlib not available.")

from langlands_visualizations import (
    sieve_primes, legendre_symbol, count_points_mod_p,
    trace_of_frobenius, sato_tate_angles, sato_tate_density,
    chi_4, chi_3, dirichlet_L, splitting_in_Q_sqrt_d,
    ramanujan_delta_coefficients, hasse_bound_check
)

OUTPUT_DIR = os.path.dirname(os.path.abspath(__file__))

def save_data(filename, header, data):
    filepath = os.path.join(OUTPUT_DIR, filename)
    with open(filepath, 'w') as f:
        f.write(header + '\n')
        for row in data:
            f.write(','.join(str(x) for x in row) + '\n')
    print(f"  Saved data: {filepath}")

def plot_sato_tate():
    """Sato-Tate distribution for a non-CM elliptic curve."""
    print("Generating Sato-Tate distribution...")
    angles = sato_tate_angles(1, 1, 1000)
    theta_range = np.linspace(0.01, np.pi - 0.01, 200)
    st_density = (2 / np.pi) * np.sin(theta_range)**2
    save_data("sato_tate_data.csv", "angle", [(a,) for a in angles])
    if not HAS_MATPLOTLIB:
        return
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))
    ax1.hist(angles, bins=30, density=True, alpha=0.7, color='steelblue',
             edgecolor='navy', label='Empirical')
    ax1.plot(theta_range, st_density, 'r-', linewidth=2.5,
             label=r'$(2/\pi)\sin^2\theta$')
    ax1.set_xlabel('Angle', fontsize=13)
    ax1.set_ylabel('Density', fontsize=13)
    ax1.set_title('Sato-Tate Distribution', fontsize=14, fontweight='bold')
    ax1.legend(fontsize=11)
    ax1.set_xlim(0, np.pi)
    sorted_angles = np.sort(angles)
    n = len(sorted_angles)
    empirical_cdf = np.arange(1, n + 1) / n
    theoretical_cdf = sorted_angles / np.pi - np.sin(2 * sorted_angles) / (2 * np.pi)
    ax2.plot(theoretical_cdf, empirical_cdf, '.', markersize=1, color='steelblue')
    ax2.plot([0, 1], [0, 1], 'r-', linewidth=1.5, label='Perfect fit')
    ax2.set_xlabel('Theoretical CDF', fontsize=13)
    ax2.set_ylabel('Empirical CDF', fontsize=13)
    ax2.set_title('QQ Plot: Sato-Tate Goodness of Fit', fontsize=14, fontweight='bold')
    ax2.legend(fontsize=11)
    ax2.set_aspect('equal')
    plt.tight_layout()
    plt.savefig(os.path.join(OUTPUT_DIR, 'sato_tate.png'), dpi=150, bbox_inches='tight')
    plt.close()
    print("  Saved: sato_tate.png")

def plot_hasse_bound():
    """Frobenius traces vs Hasse bound."""
    print("Generating Hasse bound plot...")
    primes = sieve_primes(200)
    a_vals, p_vals = [], []
    disc = 4 + 27
    for p in primes:
        if p == 2 or disc % p == 0:
            continue
        ap = trace_of_frobenius(1, 1, p)
        a_vals.append(ap)
        p_vals.append(p)
    save_data("hasse_bound_data.csv", "p,a_p", list(zip(p_vals, a_vals)))
    if not HAS_MATPLOTLIB:
        return
    fig, ax = plt.subplots(figsize=(12, 6))
    p_arr = np.array(p_vals)
    a_arr = np.array(a_vals)
    ax.scatter(p_arr, a_arr, s=15, alpha=0.7, color='steelblue', label='a_p(E)')
    p_smooth = np.linspace(3, max(p_vals), 1000)
    ax.plot(p_smooth, 2 * np.sqrt(p_smooth), 'r-', linewidth=1.5, label='Hasse bound')
    ax.plot(p_smooth, -2 * np.sqrt(p_smooth), 'r-', linewidth=1.5)
    ax.axhline(y=0, color='gray', linewidth=0.5, linestyle='--')
    ax.set_xlabel('Prime p', fontsize=13)
    ax.set_ylabel('a_p', fontsize=13)
    ax.set_title('Frobenius Traces and the Hasse Bound', fontsize=14, fontweight='bold')
    ax.legend(fontsize=11)
    plt.tight_layout()
    plt.savefig(os.path.join(OUTPUT_DIR, 'hasse_bound.png'), dpi=150, bbox_inches='tight')
    plt.close()
    print("  Saved: hasse_bound.png")

def plot_prime_splitting():
    """Prime splitting in quadratic fields."""
    print("Generating prime splitting visualization...")
    fields = [(-1, 'Q(i)'), (5, 'Q(sqrt5)'), (-3, 'Q(sqrt-3)'), (-23, 'Q(sqrt-23)')]
    if not HAS_MATPLOTLIB:
        return
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    axes = axes.flatten()
    for idx, (d, name) in enumerate(fields):
        ax = axes[idx]
        data = splitting_in_Q_sqrt_d(d, 300)
        primes = sieve_primes(300)
        colors = []
        for p in primes:
            if p in data['split']:
                colors.append('green')
            elif p in data['inert']:
                colors.append('red')
            else:
                colors.append('gold')
        ax.scatter(range(len(primes)), primes, c=colors, s=8, alpha=0.7)
        ax.set_ylabel('Prime p', fontsize=11)
        ax.set_xlabel('Index', fontsize=11)
        n_s, n_i, n_r = len(data['split']), len(data['inert']), len(data['ramified'])
        n_t = n_s + n_i + n_r
        ax.set_title(f'{name}: split={n_s} ({n_s/n_t*100:.0f}%), inert={n_i}, ram={n_r}',
                     fontsize=11, fontweight='bold')
    from matplotlib.patches import Patch
    legend_elements = [
        Patch(facecolor='green', label='Split'),
        Patch(facecolor='red', label='Inert'),
        Patch(facecolor='gold', label='Ramified'),
    ]
    fig.legend(handles=legend_elements, loc='lower center', ncol=3, fontsize=12)
    fig.suptitle('Prime Splitting: GL(1) Langlands Correspondence', fontsize=15, fontweight='bold')
    plt.tight_layout(rect=[0, 0.05, 1, 0.95])
    plt.savefig(os.path.join(OUTPUT_DIR, 'prime_splitting.png'), dpi=150, bbox_inches='tight')
    plt.close()
    print("  Saved: prime_splitting.png")

def plot_ramanujan_tau():
    """Ramanujan tau function visualization."""
    print("Generating Ramanujan tau plot...")
    N = 30
    coeffs = ramanujan_delta_coefficients(N)
    primes = sieve_primes(N)
    save_data("ramanujan_tau_data.csv", "p,tau_p",
              [(p, coeffs[p]) for p in primes if p <= N])
    if not HAS_MATPLOTLIB:
        return
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))
    ns = list(range(1, N + 1))
    taus = [coeffs[n] for n in ns]
    ax1.bar(ns, taus, width=0.8, color='steelblue', alpha=0.7)
    ax1.set_xlabel('n', fontsize=13)
    ax1.set_ylabel('tau(n)', fontsize=13)
    ax1.set_title('Ramanujan tau function', fontsize=14, fontweight='bold')
    ax1.axhline(y=0, color='gray', linewidth=0.5)
    ps = [p for p in primes if p <= N]
    ratios = [abs(coeffs[p]) / (p**(11/2)) for p in ps]
    ax2.bar(range(len(ps)), ratios, width=0.8, color='coral', alpha=0.7)
    ax2.axhline(y=2, color='red', linewidth=2, linestyle='--', label='Ramanujan bound')
    ax2.set_xticks(range(len(ps)))
    ax2.set_xticklabels([str(p) for p in ps], fontsize=9)
    ax2.set_xlabel('Prime p', fontsize=13)
    ax2.set_ylabel('|tau(p)| / p^{11/2}', fontsize=13)
    ax2.set_title('Ramanujan-Petersson Conjecture', fontsize=14, fontweight='bold')
    ax2.legend(fontsize=11)
    plt.tight_layout()
    plt.savefig(os.path.join(OUTPUT_DIR, 'ramanujan_tau.png'), dpi=150, bbox_inches='tight')
    plt.close()
    print("  Saved: ramanujan_tau.png")

def plot_correspondence_map():
    """Visual map of the Langlands correspondence."""
    print("Generating correspondence map...")
    if not HAS_MATPLOTLIB:
        return
    fig, ax = plt.subplots(figsize=(16, 10))
    ax.set_xlim(-1, 11)
    ax.set_ylim(-1, 8)
    ax.set_aspect('equal')
    ax.axis('off')
    ax.text(5, 7.5, 'THE LANGLANDS CORRESPONDENCE', fontsize=18,
            fontweight='bold', ha='center', va='center',
            bbox=dict(boxstyle='round,pad=0.5', facecolor='lightblue', alpha=0.8))
    ax.text(1.5, 6.5, 'NUMBER THEORY', fontsize=14, fontweight='bold',
            ha='center', va='center', color='darkblue')
    ax.text(8.5, 6.5, 'AUTOMORPHIC FORMS', fontsize=14, fontweight='bold',
            ha='center', va='center', color='darkred')
    boxes_left = [(1.5, 5.5, 'Dirichlet\nCharacters', 'lightgreen'),
                  (1.5, 4.0, 'Elliptic Curve\nGalois Rep.', 'lightgreen'),
                  (1.5, 2.5, 'GL(n) Galois\nRepresentations', 'lightyellow'),
                  (1.5, 1.0, 'Motivic\nGalois Rep.', 'lightsalmon')]
    boxes_right = [(8.5, 5.5, 'Hecke\nCharacters', 'lightgreen'),
                   (8.5, 4.0, 'Weight-2\nModular Forms', 'lightgreen'),
                   (8.5, 2.5, 'Automorphic Rep.\nof GL(n)', 'lightyellow'),
                   (8.5, 1.0, 'General\nAutomorphic Rep.', 'lightsalmon')]
    labels = ['GL(1): CLASS FIELD THEORY (proved)', 'GL(2): MODULARITY THM (proved)',
              'GL(n): PARTIAL (local proved)', 'GENERAL: OPEN']
    for (lx, ly, lt, lc), (rx, ry, rt, rc), label in zip(boxes_left, boxes_right, labels):
        ax.add_patch(plt.Rectangle((lx-1, ly-0.5), 2, 1, fill=True,
                                    facecolor=lc, edgecolor='black', linewidth=1.5))
        ax.text(lx, ly, lt, ha='center', va='center', fontsize=10)
        ax.add_patch(plt.Rectangle((rx-1, ry-0.5), 2, 1, fill=True,
                                    facecolor=rc, edgecolor='black', linewidth=1.5))
        ax.text(rx, ry, rt, ha='center', va='center', fontsize=10)
        ax.annotate('', xy=(rx-1, ry), xytext=(lx+1, ly),
                    arrowprops=dict(arrowstyle='<->', color='darkblue',
                                   linewidth=2, connectionstyle='arc3,rad=0'))
        ax.text(5, (ly + ry) / 2, label, ha='center', va='center',
                fontsize=9, fontweight='bold',
                bbox=dict(boxstyle='round,pad=0.3', facecolor='white',
                          edgecolor='gray', alpha=0.9))
    ax.text(5, -0.5, 'Bridge: L-functions  L(s, rho) = L(s, pi)',
            ha='center', va='center', fontsize=13, fontweight='bold',
            style='italic', color='purple')
    plt.tight_layout()
    plt.savefig(os.path.join(OUTPUT_DIR, 'langlands_map.png'), dpi=150, bbox_inches='tight')
    plt.close()
    print("  Saved: langlands_map.png")

def plot_dirichlet_L_convergence():
    """Show convergence of L-functions to exact values."""
    print("Generating L-function convergence plot...")
    if not HAS_MATPLOTLIB:
        return
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))
    Ns = list(range(1, 501))
    partial_sums = []
    s = 0
    for n in range(1, 501):
        s += chi_4(n) / n
        partial_sums.append(s)
    ax1.plot(Ns, partial_sums, 'b-', linewidth=0.8, alpha=0.7, label='Partial sums')
    ax1.axhline(y=math.pi/4, color='red', linewidth=2, linestyle='--', label='pi/4')
    ax1.set_xlabel('N', fontsize=13)
    ax1.set_ylabel('Partial sum', fontsize=13)
    ax1.set_title('Leibniz: L(1, chi_4) = pi/4', fontsize=13, fontweight='bold')
    ax1.legend(fontsize=11)
    partial_sums_zeta = []
    s = 0
    for n in range(1, 501):
        s += 1 / n**2
        partial_sums_zeta.append(s)
    ax2.plot(Ns, partial_sums_zeta, 'b-', linewidth=0.8, alpha=0.7, label='Partial sums')
    ax2.axhline(y=math.pi**2/6, color='red', linewidth=2, linestyle='--', label='pi^2/6')
    ax2.set_xlabel('N', fontsize=13)
    ax2.set_ylabel('Partial sum', fontsize=13)
    ax2.set_title('Basel: zeta(2) = pi^2/6', fontsize=13, fontweight='bold')
    ax2.legend(fontsize=11)
    plt.tight_layout()
    plt.savefig(os.path.join(OUTPUT_DIR, 'L_function_convergence.png'), dpi=150, bbox_inches='tight')
    plt.close()
    print("  Saved: L_function_convergence.png")

if __name__ == "__main__":
    print("=" * 60)
    print("LANGLANDS PROGRAM: Generating Visualizations")
    print("=" * 60)
    plot_sato_tate()
    plot_hasse_bound()
    plot_prime_splitting()
    plot_ramanujan_tau()
    plot_correspondence_map()
    plot_dirichlet_L_convergence()
    print("\n" + "=" * 60)
    print("All visualizations generated successfully!")
    print("=" * 60)
