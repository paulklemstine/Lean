#!/usr/bin/env python3
"""
INTEGER ENERGY EXPLORER
=======================
Oracle Team Research — Visualizing the Energy Landscape of Integers

This script computes multiple "energy" measures for positive integers and
produces rich visualizations showing which integers carry the most energy.

Energy Measures:
  E1: Abundance ratio σ(n)/n (divisor sum energy)
  E2: Factorization entropy (information-theoretic energy)
  E3: Logarithmic arithmetic derivative (derivative energy)
  E4: Normalized divisor count (combinatorial energy)
  E5: Collatz stopping time / log(n) (dynamical energy)
  E_total: Weighted geometric mean of all energies

Usage:
    python integer_energy_explorer.py
    
Outputs PNG visualizations to the output/ directory.
"""

import math
import os
from collections import Counter

# ─── Try to import plotting libraries, graceful fallback ───
try:
    import matplotlib
    matplotlib.use('Agg')  # Non-interactive backend
    import matplotlib.pyplot as plt
    import matplotlib.gridspec as gridspec
    from matplotlib.colors import Normalize
    from matplotlib.cm import ScalarMappable
    HAS_MPL = True
except ImportError:
    HAS_MPL = False
    print("⚠ matplotlib not found — generating text-based output instead")

try:
    import numpy as np
    HAS_NP = True
except ImportError:
    HAS_NP = False
    print("⚠ numpy not found — using pure Python math")


# ═══════════════════════════════════════════════════════════════
# §1: NUMBER-THEORETIC PRIMITIVES
# ═══════════════════════════════════════════════════════════════

def factorize(n):
    """Return prime factorization as {prime: exponent} dict."""
    if n <= 1:
        return {}
    factors = {}
    d = 2
    while d * d <= n:
        while n % d == 0:
            factors[d] = factors.get(d, 0) + 1
            n //= d
        d += 1
    if n > 1:
        factors[n] = factors.get(n, 0) + 1
    return factors


def divisor_sum(n):
    """Compute σ(n) = sum of all divisors of n."""
    if n <= 0:
        return 0
    factors = factorize(n)
    result = 1
    for p, e in factors.items():
        result *= (p ** (e + 1) - 1) // (p - 1)
    return result


def divisor_count(n):
    """Compute d(n) = number of divisors of n."""
    if n <= 0:
        return 0
    factors = factorize(n)
    result = 1
    for e in factors.values():
        result *= (e + 1)
    return result


def collatz_stopping_time(n, max_steps=10000):
    """Compute the Collatz stopping time (steps until reaching 1)."""
    if n <= 1:
        return 0
    steps = 0
    while n != 1 and steps < max_steps:
        if n % 2 == 0:
            n //= 2
        else:
            n = 3 * n + 1
        steps += 1
    return steps


def arithmetic_derivative(n):
    """Compute the arithmetic derivative n'."""
    if n <= 1:
        return 0
    factors = factorize(n)
    return sum(n // p * e for p, e in factors.items())


def euler_totient(n):
    """Compute Euler's totient φ(n)."""
    if n <= 1:
        return max(n, 0)
    factors = factorize(n)
    result = n
    for p in factors:
        result = result * (p - 1) // p
    return result


# ═══════════════════════════════════════════════════════════════
# §2: ENERGY FUNCTIONS
# ═══════════════════════════════════════════════════════════════

def energy_abundance(n):
    """E1: Abundance ratio σ(n)/n — measures divisor richness."""
    if n <= 0:
        return 0.0
    return divisor_sum(n) / n


def energy_factorization_entropy(n):
    """E2: Entropy of the prime factorization exponent distribution."""
    if n <= 1:
        return 0.0
    factors = factorize(n)
    exponents = list(factors.values())
    total = sum(exponents)
    if total <= 1:
        return 0.0
    entropy = 0.0
    for e in exponents:
        p = e / total
        if p > 0:
            entropy -= p * math.log2(p)
    return entropy


def energy_arithmetic_derivative(n):
    """E3: Logarithmic arithmetic derivative n'/n."""
    if n <= 1:
        return 0.0
    factors = factorize(n)
    return sum(e / p for p, e in factors.items())


def energy_divisor_count(n):
    """E4: Normalized divisor count d(n) / n^(1/3)."""
    if n <= 1:
        return 0.0
    return divisor_count(n) / (n ** (1/3))


def energy_collatz(n):
    """E5: Normalized Collatz stopping time."""
    if n <= 1:
        return 0.0
    return collatz_stopping_time(n) / math.log(n)


def energy_total(n, weights=(1.5, 1.0, 1.0, 1.2, 0.5)):
    """Combined energy: weighted geometric mean of all energy measures."""
    e1 = max(energy_abundance(n), 1e-10)
    e2 = max(energy_factorization_entropy(n), 1e-10)
    e3 = max(energy_arithmetic_derivative(n), 1e-10)
    e4 = max(energy_divisor_count(n), 1e-10)
    e5 = max(energy_collatz(n), 1e-10)
    
    a, b, c, d, e = weights
    total_weight = a + b + c + d + e
    
    log_energy = (a * math.log(e1) + b * math.log(e2) + c * math.log(e3) +
                  d * math.log(e4) + e * math.log(e5)) / total_weight
    
    return math.exp(log_energy)


# ═══════════════════════════════════════════════════════════════
# §3: IDENTIFICATION OF ENERGY CHAMPIONS
# ═══════════════════════════════════════════════════════════════

def find_highly_composite(limit):
    """Find highly composite numbers up to limit."""
    hcns = []
    max_divisors = 0
    for n in range(1, limit + 1):
        d = divisor_count(n)
        if d > max_divisors:
            max_divisors = d
            hcns.append(n)
    return hcns


def find_superabundant(limit):
    """Find superabundant numbers up to limit."""
    sans = []
    max_abundance = 0.0
    for n in range(1, limit + 1):
        a = energy_abundance(n)
        if a > max_abundance:
            max_abundance = a
            sans.append(n)
    return sans


def find_energy_champions(limit, top_k=20):
    """Find integers with highest combined energy."""
    energies = [(n, energy_total(n)) for n in range(2, limit + 1)]
    energies.sort(key=lambda x: -x[1])
    return energies[:top_k]


# ═══════════════════════════════════════════════════════════════
# §4: VISUALIZATION
# ═══════════════════════════════════════════════════════════════

def ensure_output_dir():
    """Create output directory if needed."""
    os.makedirs("output", exist_ok=True)


def plot_energy_landscape(limit=500):
    """
    DEMO 1: The Energy Landscape of Integers
    Shows all five energy measures for integers 2..limit.
    """
    if not HAS_MPL:
        print("\n=== ENERGY LANDSCAPE (text mode) ===")
        for n in [2, 6, 12, 24, 60, 120, 360, 2520]:
            if n > limit:
                break
            print(f"  n={n:>5}: E1={energy_abundance(n):.3f}  "
                  f"E2={energy_factorization_entropy(n):.3f}  "
                  f"E3={energy_arithmetic_derivative(n):.3f}  "
                  f"E4={energy_divisor_count(n):.3f}  "
                  f"E5={energy_collatz(n):.3f}  "
                  f"E_total={energy_total(n):.3f}")
        return

    ns = list(range(2, limit + 1))
    e1 = [energy_abundance(n) for n in ns]
    e2 = [energy_factorization_entropy(n) for n in ns]
    e3 = [energy_arithmetic_derivative(n) for n in ns]
    e4 = [energy_divisor_count(n) for n in ns]
    e5 = [energy_collatz(n) for n in ns]
    et = [energy_total(n) for n in ns]

    fig, axes = plt.subplots(3, 2, figsize=(16, 18))
    fig.suptitle("The Energy Landscape of Integers", fontsize=20, fontweight='bold', y=0.98)

    titles = [
        "E₁: Abundance Ratio σ(n)/n",
        "E₂: Factorization Entropy",
        "E₃: Logarithmic Arithmetic Derivative",
        "E₄: Normalized Divisor Count",
        "E₅: Normalized Collatz Stopping Time",
        "E_total: Combined Energy"
    ]
    data = [e1, e2, e3, e4, e5, et]
    colors = ['#e74c3c', '#3498db', '#2ecc71', '#9b59b6', '#f39c12', '#1abc9c']

    # Find HCNs and superabundants for annotation
    hcns = set(find_highly_composite(limit))
    sans = set(find_superabundant(limit))
    
    for ax, title, vals, color in zip(axes.flat, titles, data, colors):
        ax.scatter(ns, vals, c=color, alpha=0.4, s=8, edgecolors='none')
        
        # Highlight HCNs
        hcn_ns = [n for n in ns if n in hcns]
        hcn_vals = [vals[n - 2] for n in hcn_ns]
        ax.scatter(hcn_ns, hcn_vals, c='gold', s=40, zorder=5, 
                   edgecolors='black', linewidths=0.5, label='HCN')
        
        # Annotate top 3
        paired = sorted(zip(vals, ns), reverse=True)[:3]
        for v, n in paired:
            ax.annotate(str(n), (n, v), fontsize=8, ha='center', va='bottom',
                       fontweight='bold', color='darkred')
        
        ax.set_title(title, fontsize=13, fontweight='bold')
        ax.set_xlabel('n', fontsize=11)
        ax.set_ylabel('Energy', fontsize=11)
        ax.grid(True, alpha=0.3)
        ax.legend(fontsize=9)

    plt.tight_layout(rect=[0, 0, 1, 0.96])
    plt.savefig("output/01_energy_landscape.png", dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Saved output/01_energy_landscape.png")


def plot_energy_champions(limit=1000):
    """
    DEMO 2: The Energy Champions — Top integers by combined energy
    """
    champions = find_energy_champions(limit, top_k=30)
    
    if not HAS_MPL:
        print("\n=== ENERGY CHAMPIONS (top 30 up to {}) ===".format(limit))
        for rank, (n, e) in enumerate(champions, 1):
            factors = factorize(n)
            fstr = " · ".join(f"{p}^{e}" if e > 1 else str(p) 
                             for p, e in sorted(factors.items()))
            print(f"  #{rank:>2}: n={n:>5} ({fstr})  E_total={e:.4f}  "
                  f"d(n)={divisor_count(n)}")
        return

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(18, 8))
    fig.suptitle("Energy Champions: Integers with Maximum Mathematical Energy",
                 fontsize=18, fontweight='bold')

    # Bar chart of champions
    ns = [c[0] for c in champions]
    es = [c[1] for c in champions]
    
    colors = plt.cm.hot(np.linspace(0.2, 0.8, len(ns)))
    ax1.barh(range(len(ns)), es, color=colors, edgecolor='black', linewidth=0.5)
    ax1.set_yticks(range(len(ns)))
    ax1.set_yticklabels([str(n) for n in ns], fontsize=9)
    ax1.set_xlabel('Combined Energy E_total', fontsize=12)
    ax1.set_title('Top 30 Integers by Combined Energy', fontsize=14, fontweight='bold')
    ax1.invert_yaxis()
    
    # Annotate with factorizations
    for i, n in enumerate(ns):
        factors = factorize(n)
        fstr = "·".join(f"{p}^{e}" if e > 1 else str(p) 
                        for p, e in sorted(factors.items()))
        ax1.text(es[i] + max(es) * 0.01, i, f" = {fstr}", va='center', fontsize=7)

    # Energy decomposition radar for top 5
    from math import pi as PI
    
    categories = ['E₁\nAbundance', 'E₂\nEntropy', 'E₃\nDerivative', 
                   'E₄\nDivisors', 'E₅\nCollatz']
    N_cats = len(categories)
    angles = [n / float(N_cats) * 2 * PI for n in range(N_cats)]
    angles += angles[:1]

    ax2 = plt.subplot(122, polar=True)
    ax2.set_title('Energy Decomposition: Top 5 Champions', fontsize=14, 
                   fontweight='bold', pad=20)

    top5_colors = ['#e74c3c', '#3498db', '#2ecc71', '#9b59b6', '#f39c12']
    
    for idx in range(min(5, len(ns))):
        n = ns[idx]
        vals = [
            energy_abundance(n) / 4.0,  # normalize
            energy_factorization_entropy(n) / 2.5,
            energy_arithmetic_derivative(n) / 2.0,
            energy_divisor_count(n) / 8.0,
            energy_collatz(n) / 20.0,
        ]
        vals += vals[:1]
        ax2.plot(angles, vals, 'o-', linewidth=2, color=top5_colors[idx], 
                label=f'n={n}', markersize=4)
        ax2.fill(angles, vals, alpha=0.1, color=top5_colors[idx])

    ax2.set_xticks(angles[:-1])
    ax2.set_xticklabels(categories, fontsize=10)
    ax2.legend(loc='upper right', bbox_to_anchor=(1.3, 1.1), fontsize=10)

    plt.tight_layout()
    plt.savefig("output/02_energy_champions.png", dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Saved output/02_energy_champions.png")


def plot_energy_spectrum(limit=300):
    """
    DEMO 3: Energy Spectrum — Heatmap of integer energy by measure
    """
    ns = list(range(2, limit + 1))
    
    if not HAS_MPL or not HAS_NP:
        print("\n=== ENERGY SPECTRUM (text mode) ===")
        print("  Skipping heatmap (requires matplotlib + numpy)")
        return

    # Build energy matrix
    matrix = np.zeros((5, len(ns)))
    for i, n in enumerate(ns):
        matrix[0, i] = energy_abundance(n)
        matrix[1, i] = energy_factorization_entropy(n)
        matrix[2, i] = energy_arithmetic_derivative(n)
        matrix[3, i] = energy_divisor_count(n)
        matrix[4, i] = energy_collatz(n)
    
    # Normalize each row to [0, 1]
    for row in range(5):
        mx = matrix[row].max()
        if mx > 0:
            matrix[row] /= mx

    fig, ax = plt.subplots(figsize=(20, 5))
    im = ax.imshow(matrix, aspect='auto', cmap='inferno', interpolation='nearest')
    
    ax.set_yticks(range(5))
    ax.set_yticklabels(['E₁ Abundance', 'E₂ Entropy', 'E₃ Derivative', 
                        'E₄ Divisors', 'E₅ Collatz'], fontsize=11)
    
    # Mark every 20th integer
    tick_positions = list(range(0, len(ns), 20))
    ax.set_xticks(tick_positions)
    ax.set_xticklabels([str(ns[i]) for i in tick_positions], fontsize=8, rotation=45)
    ax.set_xlabel('Integer n', fontsize=12)
    
    ax.set_title("Energy Spectrum: Normalized Energy by Measure and Integer",
                 fontsize=16, fontweight='bold')
    
    plt.colorbar(im, ax=ax, label='Normalized Energy', shrink=0.8)
    
    # Mark superabundants
    sans = find_superabundant(limit)
    for sa in sans:
        if sa >= 2:
            idx = sa - 2
            ax.axvline(x=idx, color='cyan', alpha=0.3, linewidth=1)
    
    plt.tight_layout()
    plt.savefig("output/03_energy_spectrum.png", dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Saved output/03_energy_spectrum.png")


def plot_energy_vs_solver(limit=200):
    """
    DEMO 4: Simulated Solver Performance vs Integer Energy
    
    Simulates how proof search efficiency correlates with the energy
    of witness integers. Higher-energy witnesses provide more 
    factorizations, more divisors, more modular handles.
    """
    ns = list(range(2, limit + 1))
    
    # "Solver efficiency" model: more divisors = more proof strategies
    # We model this as: efficiency ~ d(n) * (number of distinct prime factors)
    def solver_efficiency(n):
        factors = factorize(n)
        d = divisor_count(n)
        omega = len(factors)  # number of distinct primes
        return d * omega / math.log(n + 1)
    
    if not HAS_MPL:
        print("\n=== SOLVER ENERGY CORRELATION (text mode) ===")
        champions = [(n, energy_total(n), solver_efficiency(n)) for n in ns]
        champions.sort(key=lambda x: -x[1])
        print("  Top integers by energy and their solver efficiency:")
        for n, e, s in champions[:15]:
            print(f"    n={n:>4}: E_total={e:.3f}, solver_eff={s:.3f}")
        return

    energies = [energy_total(n) for n in ns]
    efficiencies = [solver_efficiency(n) for n in ns]
    divisors = [divisor_count(n) for n in ns]

    fig, axes = plt.subplots(1, 3, figsize=(20, 7))
    fig.suptitle("Integer Energy vs Solver Performance (Simulated)",
                 fontsize=18, fontweight='bold')

    # Plot 1: Energy vs Solver Efficiency scatter
    sc = axes[0].scatter(energies, efficiencies, c=divisors, cmap='plasma',
                         s=30, alpha=0.7, edgecolors='none')
    axes[0].set_xlabel('Combined Energy E_total', fontsize=12)
    axes[0].set_ylabel('Simulated Solver Efficiency', fontsize=12)
    axes[0].set_title('Energy ↔ Solver Efficiency', fontsize=14, fontweight='bold')
    plt.colorbar(sc, ax=axes[0], label='d(n) = divisor count')
    axes[0].grid(True, alpha=0.3)
    
    # Highlight and label top energy points
    top_idx = sorted(range(len(energies)), key=lambda i: -energies[i])[:5]
    for i in top_idx:
        axes[0].annotate(str(ns[i]), (energies[i], efficiencies[i]),
                        fontsize=9, fontweight='bold', color='red')

    # Plot 2: Integer n vs solver efficiency, colored by energy
    sc2 = axes[1].scatter(ns, efficiencies, c=energies, cmap='hot',
                          s=20, alpha=0.6, edgecolors='none')
    axes[1].set_xlabel('Integer n', fontsize=12)
    axes[1].set_ylabel('Solver Efficiency', fontsize=12)
    axes[1].set_title('Solver Efficiency by Integer', fontsize=14, fontweight='bold')
    plt.colorbar(sc2, ax=axes[1], label='Combined Energy')
    axes[1].grid(True, alpha=0.3)

    # Plot 3: Cumulative energy injection effect
    # Sort integers by energy, show cumulative solver boost
    sorted_by_energy = sorted(zip(energies, efficiencies, ns), reverse=True)
    cum_eff = []
    running = 0
    for i, (e, s, n) in enumerate(sorted_by_energy):
        running += s
        cum_eff.append(running)
    
    axes[2].plot(range(1, len(cum_eff) + 1), cum_eff, color='#e74c3c', linewidth=2)
    axes[2].fill_between(range(1, len(cum_eff) + 1), cum_eff, alpha=0.2, color='#e74c3c')
    axes[2].set_xlabel('Number of Integers Injected (sorted by energy)', fontsize=12)
    axes[2].set_ylabel('Cumulative Solver Boost', fontsize=12)
    axes[2].set_title('Energy Injection: Cumulative Effect', fontsize=14, fontweight='bold')
    axes[2].grid(True, alpha=0.3)
    
    # Mark the "diminishing returns" point
    if len(cum_eff) > 10:
        # Find elbow: where second derivative changes sign
        gradients = [cum_eff[i+1] - cum_eff[i] for i in range(len(cum_eff)-1)]
        for i in range(1, len(gradients)):
            if gradients[i] < gradients[0] * 0.1:
                axes[2].axvline(x=i, color='blue', linestyle='--', alpha=0.5)
                axes[2].text(i + 2, cum_eff[i], f'Diminishing returns\n@ {i} integers',
                           fontsize=9, color='blue')
                break

    plt.tight_layout(rect=[0, 0, 1, 0.95])
    plt.savefig("output/04_energy_solver.png", dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Saved output/04_energy_solver.png")


def plot_prime_factorization_landscape(limit=200):
    """
    DEMO 5: Prime Factorization Landscape
    
    Visualizes the "shape" of each integer's prime factorization,
    showing why high-energy integers have the richest structure.
    """
    if not HAS_MPL or not HAS_NP:
        print("\n=== PRIME FACTORIZATION LANDSCAPE (text mode) ===")
        for n in [30, 60, 120, 180, 360, 720, 840, 2520]:
            if n > limit * 15:
                break
            f = factorize(n)
            print(f"  {n} = {f}, d(n)={divisor_count(n)}, σ(n)/n={energy_abundance(n):.3f}")
        return

    # Select interesting integers to display
    hcns = find_highly_composite(limit)
    primes = [n for n in range(2, limit+1) if len(factorize(n)) == 1 and list(factorize(n).values())[0] == 1]
    
    fig, axes = plt.subplots(2, 2, figsize=(16, 14))
    fig.suptitle("Prime Factorization Landscape", fontsize=20, fontweight='bold')

    # Plot 1: Number of distinct prime factors vs energy
    ns = list(range(2, limit + 1))
    omegas = [len(factorize(n)) for n in ns]
    Omegas = [sum(factorize(n).values()) for n in ns]
    energies = [energy_total(n) for n in ns]
    
    sc = axes[0, 0].scatter(omegas, energies, c=[math.log(n) for n in ns],
                            cmap='viridis', s=20, alpha=0.6)
    axes[0, 0].set_xlabel('ω(n) = distinct prime factors', fontsize=12)
    axes[0, 0].set_ylabel('Combined Energy', fontsize=12)
    axes[0, 0].set_title('Distinct Primes vs Energy', fontsize=14, fontweight='bold')
    plt.colorbar(sc, ax=axes[0, 0], label='log(n)')
    axes[0, 0].grid(True, alpha=0.3)

    # Plot 2: Total prime factor count vs energy
    sc2 = axes[0, 1].scatter(Omegas, energies, c=[divisor_count(n) for n in ns],
                              cmap='plasma', s=20, alpha=0.6)
    axes[0, 1].set_xlabel('Ω(n) = total prime factor count', fontsize=12)
    axes[0, 1].set_ylabel('Combined Energy', fontsize=12)
    axes[0, 1].set_title('Total Prime Factors vs Energy', fontsize=14, fontweight='bold')
    plt.colorbar(sc2, ax=axes[0, 1], label='d(n)')
    axes[0, 1].grid(True, alpha=0.3)

    # Plot 3: Factorization "fingerprints" for HCNs
    ax3 = axes[1, 0]
    display_hcns = [n for n in hcns if n <= limit][:12]
    max_prime = 23
    primes_list = [2, 3, 5, 7, 11, 13, 17, 19, 23]
    
    for idx, n in enumerate(display_hcns):
        factors = factorize(n)
        exponents = [factors.get(p, 0) for p in primes_list]
        x_positions = [i + idx * 0.07 for i in range(len(primes_list))]
        ax3.bar(x_positions, exponents, width=0.06, label=str(n), alpha=0.8)
    
    ax3.set_xticks(range(len(primes_list)))
    ax3.set_xticklabels([str(p) for p in primes_list], fontsize=10)
    ax3.set_xlabel('Prime', fontsize=12)
    ax3.set_ylabel('Exponent', fontsize=12)
    ax3.set_title('Factorization Fingerprints (HCNs)', fontsize=14, fontweight='bold')
    ax3.legend(fontsize=8, ncol=3, loc='upper right')

    # Plot 4: Energy density = energy / log(n)
    densities = [energy_total(n) / math.log(n) for n in ns]
    ax4 = axes[1, 1]
    ax4.scatter(ns, densities, c='#e74c3c', s=15, alpha=0.5, edgecolors='none')
    
    # Highlight HCNs
    display_hcns_valid = [n for n in display_hcns if n >= 2 and n <= limit]
    hcn_densities = [densities[n - 2] for n in display_hcns_valid]
    ax4.scatter(display_hcns_valid, hcn_densities, c='gold', s=60, zorder=5,
               edgecolors='black', linewidths=0.5, label='HCN')
    
    for n in display_hcns_valid:
        ax4.annotate(str(n), (n, densities[n - 2]), fontsize=8,
                    ha='center', va='bottom', fontweight='bold')
    
    ax4.set_xlabel('n', fontsize=12)
    ax4.set_ylabel('Energy Density (E / log n)', fontsize=12)
    ax4.set_title('Energy Density: Who Packs the Most?', fontsize=14, fontweight='bold')
    ax4.legend(fontsize=10)
    ax4.grid(True, alpha=0.3)

    plt.tight_layout(rect=[0, 0, 1, 0.96])
    plt.savefig("output/05_factorization_landscape.png", dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Saved output/05_factorization_landscape.png")


def plot_robin_inequality(limit=5040):
    """
    DEMO 6: Robin's Inequality and the Riemann Hypothesis
    
    Robin (1984) proved: RH ⟺ σ(n) < e^γ · n · ln(ln(n)) for all n ≥ 5041
    The boundary at 5040 = 7! is deeply connected to integer energy.
    """
    if not HAS_MPL:
        print("\n=== ROBIN'S INEQUALITY (text mode) ===")
        gamma = 0.5772156649
        for n in [12, 60, 120, 360, 2520, 5040]:
            if n >= 3:
                lnlnn = math.log(math.log(n))
                robin = math.exp(gamma) * n * lnlnn
                sigma = divisor_sum(n)
                print(f"  n={n:>5}: σ(n)={sigma:>8}, Robin bound={robin:.1f}, "
                      f"ratio={sigma/robin:.6f}")
        return

    gamma = 0.5772156649015329  # Euler-Mascheroni constant
    
    ns = list(range(3, limit + 1))
    ratios = []
    for n in ns:
        sigma = divisor_sum(n)
        lnlnn = math.log(max(math.log(n), 1e-10))
        robin_bound = math.exp(gamma) * n * lnlnn
        ratios.append(sigma / robin_bound if robin_bound > 0 else 0)
    
    fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(16, 12))
    fig.suptitle("Robin's Inequality and the Riemann Hypothesis",
                 fontsize=18, fontweight='bold')

    # Full view
    ax1.scatter(ns, ratios, c='steelblue', s=3, alpha=0.4, edgecolors='none')
    ax1.axhline(y=1.0, color='red', linewidth=2, linestyle='--', label='Robin boundary (RH ⟺ ratio < 1 for n ≥ 5041)')
    ax1.axvline(x=5040, color='gold', linewidth=2, linestyle='--', label='n = 5040 = 7! (last violator)')
    
    # Highlight superabundants
    sans = find_superabundant(limit)
    san_ratios = [(sa, ratios[sa - 3]) for sa in sans if sa >= 3]
    ax1.scatter([s[0] for s in san_ratios], [s[1] for s in san_ratios],
               c='red', s=30, zorder=5, label='Superabundant numbers')
    
    ax1.set_xlabel('n', fontsize=12)
    ax1.set_ylabel('σ(n) / (e^γ · n · ln(ln(n)))', fontsize=12)
    ax1.set_title('Robin\'s Ratio: The Riemann Hypothesis Lives at the Energy Boundary',
                  fontsize=14, fontweight='bold')
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.3)

    # Zoomed view near 5040
    zoom_start = max(3, 4500)
    zoom_end = min(limit, 5500)
    zoom_ns = list(range(zoom_start, zoom_end + 1))
    zoom_ratios = [ratios[n - 3] for n in zoom_ns]
    
    ax2.scatter(zoom_ns, zoom_ratios, c='steelblue', s=10, alpha=0.6)
    ax2.axhline(y=1.0, color='red', linewidth=2, linestyle='--')
    ax2.axvline(x=5040, color='gold', linewidth=2, linestyle='--', label='5040')
    ax2.axvline(x=5041, color='green', linewidth=2, linestyle='--', label='5041 (RH starts)')
    
    ax2.set_xlabel('n', fontsize=12)
    ax2.set_ylabel('Robin\'s Ratio', fontsize=12)
    ax2.set_title('Zoomed: The Phase Transition at 5040',
                  fontsize=14, fontweight='bold')
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)

    plt.tight_layout(rect=[0, 0, 1, 0.96])
    plt.savefig("output/06_robin_inequality.png", dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Saved output/06_robin_inequality.png")


def plot_energy_injection_experiment():
    """
    DEMO 7: Energy Injection Experiment
    
    Simulates injecting high-energy integers into a solver's witness pool
    and measures the effect on proof search performance.
    """
    if not HAS_MPL:
        print("\n=== ENERGY INJECTION EXPERIMENT (text mode) ===")
        print("  Simulating solver with various witness strategies...")
        
    # Define "theorems" as divisibility/modular constraints
    import random
    random.seed(42)
    
    def simulate_proof_search(witness_pool, constraints, max_tries=1000):
        """Simulate finding a witness satisfying multiple constraints."""
        for i, w in enumerate(witness_pool):
            if all(c(w) for c in constraints):
                return i + 1  # steps to find witness
        return max_tries
    
    # Generate random constraints
    def make_constraints(n_constraints=5):
        mods = random.sample(range(2, 20), min(n_constraints, 18))
        targets = [random.randint(0, m - 1) for m in mods]
        return [lambda w, m=m, t=t: w % m == t for m, t in zip(mods, targets)]
    
    # Strategy 1: Sequential search (1, 2, 3, ...)
    # Strategy 2: Energy-sorted search (highest energy first)
    # Strategy 3: Random search
    
    n_trials = 100
    limit = 500
    
    ns = list(range(1, limit + 1))
    energy_sorted = sorted(ns, key=lambda n: -energy_total(max(n, 2)))
    
    sequential_steps = []
    energy_steps = []
    random_steps = []
    
    for _ in range(n_trials):
        constraints = make_constraints(3)
        
        s1 = simulate_proof_search(ns, constraints)
        s2 = simulate_proof_search(energy_sorted, constraints)
        
        shuffled = ns.copy()
        random.shuffle(shuffled)
        s3 = simulate_proof_search(shuffled, constraints)
        
        sequential_steps.append(s1)
        energy_steps.append(s2)
        random_steps.append(s3)
    
    if not HAS_MPL:
        print(f"  Sequential: mean={sum(sequential_steps)/n_trials:.1f} steps")
        print(f"  Energy-first: mean={sum(energy_steps)/n_trials:.1f} steps")
        print(f"  Random: mean={sum(random_steps)/n_trials:.1f} steps")
        return

    fig, axes = plt.subplots(1, 3, figsize=(20, 7))
    fig.suptitle("Energy Injection Experiment: Solver Performance by Witness Strategy",
                 fontsize=18, fontweight='bold')

    # Histogram of steps
    bins = range(0, max(max(sequential_steps), max(energy_steps), max(random_steps)) + 20, 10)
    axes[0].hist(sequential_steps, bins=bins, alpha=0.6, color='#3498db', label='Sequential', density=True)
    axes[0].hist(energy_steps, bins=bins, alpha=0.6, color='#e74c3c', label='Energy-first', density=True)
    axes[0].hist(random_steps, bins=bins, alpha=0.6, color='#2ecc71', label='Random', density=True)
    axes[0].set_xlabel('Steps to Find Witness', fontsize=12)
    axes[0].set_ylabel('Density', fontsize=12)
    axes[0].set_title('Distribution of Search Steps', fontsize=14, fontweight='bold')
    axes[0].legend(fontsize=11)
    axes[0].grid(True, alpha=0.3)

    # Box plot comparison
    bp = axes[1].boxplot([sequential_steps, energy_steps, random_steps],
                         labels=['Sequential', 'Energy-first', 'Random'],
                         patch_artist=True)
    colors_box = ['#3498db', '#e74c3c', '#2ecc71']
    for patch, color in zip(bp['boxes'], colors_box):
        patch.set_facecolor(color)
        patch.set_alpha(0.6)
    axes[1].set_ylabel('Steps to Find Witness', fontsize=12)
    axes[1].set_title('Strategy Comparison', fontsize=14, fontweight='bold')
    axes[1].grid(True, alpha=0.3)

    # Cumulative success rate
    max_step = max(max(sequential_steps), max(energy_steps), max(random_steps))
    steps_range = range(1, max_step + 1)
    
    seq_cum = [sum(1 for s in sequential_steps if s <= t) / n_trials for t in steps_range]
    eng_cum = [sum(1 for s in energy_steps if s <= t) / n_trials for t in steps_range]
    rnd_cum = [sum(1 for s in random_steps if s <= t) / n_trials for t in steps_range]
    
    axes[2].plot(list(steps_range), seq_cum, color='#3498db', linewidth=2, label='Sequential')
    axes[2].plot(list(steps_range), eng_cum, color='#e74c3c', linewidth=2, label='Energy-first')
    axes[2].plot(list(steps_range), rnd_cum, color='#2ecc71', linewidth=2, label='Random')
    axes[2].set_xlabel('Maximum Steps Allowed', fontsize=12)
    axes[2].set_ylabel('Fraction of Problems Solved', fontsize=12)
    axes[2].set_title('Cumulative Success Rate', fontsize=14, fontweight='bold')
    axes[2].legend(fontsize=11)
    axes[2].grid(True, alpha=0.3)

    plt.tight_layout(rect=[0, 0, 1, 0.95])
    plt.savefig("output/07_energy_injection_experiment.png", dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Saved output/07_energy_injection_experiment.png")


def plot_5040_deep_dive():
    """
    DEMO 8: Deep Dive into 5040 — The Most Energetic Small Integer
    
    5040 = 7! = 2⁴ · 3² · 5 · 7 has extraordinary properties.
    """
    n = 5040
    factors = factorize(n)
    d_n = divisor_count(n)  # 60 divisors
    sigma_n = divisor_sum(n)
    phi_n = euler_totient(n)
    deriv_n = arithmetic_derivative(n)
    
    print(f"\n{'='*60}")
    print(f"  DEEP DIVE: 5040 = 7! = 2⁴ · 3² · 5 · 7")
    print(f"{'='*60}")
    print(f"  Divisors d(5040)     = {d_n}")
    print(f"  Divisor sum σ(5040)  = {sigma_n}")
    print(f"  Abundance σ/n        = {sigma_n/n:.6f}")
    print(f"  Euler totient φ(5040)= {phi_n}")
    print(f"  Arithmetic derivative= {deriv_n}")
    print(f"  Log derivative n'/n  = {deriv_n/n:.6f}")
    print(f"  E_total              = {energy_total(n):.6f}")
    
    # List all divisors
    divisors = [d for d in range(1, n + 1) if n % d == 0]
    print(f"\n  All {len(divisors)} divisors of 5040:")
    for i in range(0, len(divisors), 10):
        chunk = divisors[i:i+10]
        print(f"    {', '.join(str(d) for d in chunk)}")
    
    if not HAS_MPL:
        return

    fig = plt.figure(figsize=(18, 12))
    gs = gridspec.GridSpec(2, 3, figure=fig)
    fig.suptitle("5040 = 7! — The Most Energetic Small Integer",
                 fontsize=20, fontweight='bold')

    # Divisor lattice visualization (simplified)
    ax1 = fig.add_subplot(gs[0, 0])
    divs_small = [d for d in divisors if d <= 120]
    for d in divs_small:
        ax1.scatter(d, divisor_count(d), c='steelblue', s=50, zorder=5)
        ax1.annotate(str(d), (d, divisor_count(d)), fontsize=7, 
                    ha='center', va='bottom')
    ax1.set_xlabel('Divisor d', fontsize=11)
    ax1.set_ylabel('d(d) = divisors of divisor', fontsize=11)
    ax1.set_title('Divisor Structure (d ≤ 120)', fontsize=13, fontweight='bold')
    ax1.grid(True, alpha=0.3)

    # Energy comparison with nearby integers
    ax2 = fig.add_subplot(gs[0, 1])
    nearby = list(range(5000, 5081))
    nearby_energy = [energy_total(n) for n in nearby]
    colors = ['gold' if n == 5040 else 'steelblue' for n in nearby]
    ax2.bar(range(len(nearby)), nearby_energy, color=colors, alpha=0.7)
    ax2.set_xticks(range(0, len(nearby), 10))
    ax2.set_xticklabels([str(n) for n in nearby[::10]], fontsize=8)
    ax2.set_xlabel('n', fontsize=11)
    ax2.set_ylabel('E_total', fontsize=11)
    ax2.set_title('5040 Towers Over Its Neighbors', fontsize=13, fontweight='bold')

    # Factorization fingerprint
    ax3 = fig.add_subplot(gs[0, 2])
    primes_used = sorted(factors.keys())
    exponents = [factors[p] for p in primes_used]
    ax3.bar(range(len(primes_used)), exponents, color=['#e74c3c', '#3498db', '#2ecc71', '#9b59b6'],
            edgecolor='black', linewidth=1)
    ax3.set_xticks(range(len(primes_used)))
    ax3.set_xticklabels([str(p) for p in primes_used], fontsize=14)
    ax3.set_xlabel('Prime Factor', fontsize=11)
    ax3.set_ylabel('Exponent', fontsize=11)
    ax3.set_title('5040 = 2⁴ · 3² · 5¹ · 7¹', fontsize=13, fontweight='bold')

    # Historical significance
    ax4 = fig.add_subplot(gs[1, :])
    milestones = {
        2: "First prime",
        6: "First perfect #",
        12: "Dozen",
        24: "Hours/day",
        60: "Babylonian base",
        120: "5!",
        360: "Degrees/circle",
        720: "6!",
        2520: "lcm(1..10)",
        5040: "7! — Plato's ideal city"
    }
    x_pos = list(milestones.keys())
    y_pos = [energy_total(n) for n in x_pos]
    
    ax4.scatter(x_pos, y_pos, c='gold', s=100, zorder=5, edgecolors='black', linewidths=1)
    ax4.plot(x_pos, y_pos, 'r--', alpha=0.5)
    
    for x, y, label in zip(x_pos, y_pos, milestones.values()):
        ax4.annotate(f"{x}\n{label}", (x, y), fontsize=9,
                    ha='center', va='bottom', fontweight='bold',
                    bbox=dict(boxstyle='round,pad=0.3', facecolor='lightyellow', alpha=0.8))
    
    ax4.set_xlabel('n', fontsize=12)
    ax4.set_ylabel('Combined Energy', fontsize=12)
    ax4.set_title('The Ascent of Energy: From 2 to 5040', fontsize=14, fontweight='bold')
    ax4.set_xscale('log')
    ax4.grid(True, alpha=0.3)

    plt.tight_layout(rect=[0, 0, 1, 0.96])
    plt.savefig("output/08_5040_deep_dive.png", dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Saved output/08_5040_deep_dive.png")


# ═══════════════════════════════════════════════════════════════
# §5: MAIN
# ═══════════════════════════════════════════════════════════════

def main():
    print("=" * 70)
    print("  INTEGER ENERGY EXPLORER")
    print("  Oracle Team Research — Visualizing the Energy Landscape")
    print("=" * 70)
    
    ensure_output_dir()
    
    print("\n📊 Generating visualizations...\n")
    
    plot_energy_landscape(500)
    plot_energy_champions(1000)
    plot_energy_spectrum(300)
    plot_energy_vs_solver(200)
    plot_prime_factorization_landscape(200)
    plot_robin_inequality(5040)
    plot_energy_injection_experiment()
    plot_5040_deep_dive()
    
    print("\n" + "=" * 70)
    print("  All visualizations complete!")
    print("  Check the output/ directory for PNG files.")
    print("=" * 70)


if __name__ == "__main__":
    main()
