#!/usr/bin/env python3
"""
Non-Standard Arithmetic: Ultrafilter Transfer and Characteristic Zero Emergence

Demonstrates the key mathematical ideas from the Lean 4 formalization:
1. Ultrafilter combinatorics on finite sets
2. Characteristic zero emergence from finite characteristics
3. The non-Archimedean hierarchy in ultrapowers
"""

import random
from typing import List, Set, Callable


def simulate_ultrafilter_pigeonhole(n_indices: int, n_colors: int, seed: int = 42):
    """
    Simulate the ultrafilter pigeonhole principle.
    
    For any coloring of {0,...,n_indices-1} with n_colors colors,
    at least one color class must be "large" (in any ultrafilter).
    We simulate by showing that the largest color class always contains
    at least ceil(n_indices / n_colors) elements.
    """
    random.seed(seed)
    coloring = [random.randint(0, n_colors - 1) for _ in range(n_indices)]
    
    # Count color classes
    classes = {}
    for i, c in enumerate(coloring):
        classes.setdefault(c, []).append(i)
    
    print(f"=== Ultrafilter Pigeonhole ({n_colors} colors, {n_indices} indices) ===")
    for color, indices in sorted(classes.items()):
        print(f"  Color {color}: {len(indices)} elements")
    
    largest = max(classes.items(), key=lambda x: len(x[1]))
    print(f"  Largest class: color {largest[0]} with {len(largest[1])} elements")
    print(f"  (Lower bound: ceil({n_indices}/{n_colors}) = {(n_indices + n_colors - 1) // n_colors})")
    print()


def demonstrate_characteristic_zero():
    """
    Demonstrate how characteristic zero emerges from finite characteristics.
    
    Key idea: Consider fields Z/p_n Z for primes p_1 < p_2 < ...
    For any fixed N > 0, only finitely many p_i ≤ N.
    So {i | p_i > N} is cofinite, hence in any free ultrafilter.
    Therefore, the ultraproduct has characteristic 0.
    """
    print("=== Characteristic Zero from Finite Characteristics ===")
    
    # Generate first 20 primes
    primes = []
    candidate = 2
    while len(primes) < 20:
        if all(candidate % p != 0 for p in primes):
            primes.append(candidate)
        candidate += 1
    
    print(f"  Primes: {primes}")
    print()
    
    # For each N, show how many primes are > N
    for N in [1, 5, 10, 20, 50]:
        exceeding = [p for p in primes if p > N]
        print(f"  N = {N:3d}: {len(exceeding)}/{len(primes)} primes exceed N "
              f"(cofinite? {len(exceeding) > len(primes) // 2})")
    
    print()
    print("  → As N grows, {i | p_i > N} stays cofinite → in any free ultrafilter")
    print("  → The ultraproduct has char ≠ N for all N > 0 → char = 0")
    print()


def demonstrate_non_archimedean_hierarchy():
    """
    Demonstrate the hierarchy of non-standard elements.
    
    In the ultrapower, the functions id, id², id³, ... represent
    elements that are increasingly "infinite":
    - id(i) = i exceeds every constant for large i
    - id²(i) = i² exceeds id(i) for i ≥ 2
    - id^k(i) = i^k exceeds id^(k-1)(i) for i ≥ 2
    """
    print("=== Non-Archimedean Hierarchy ===")
    print("  Comparing growth rates (for i = 2, 3, 5, 10, 100):")
    print()
    
    indices = [2, 3, 5, 10, 100]
    powers = [1, 2, 3, 4, 5]
    
    # Header
    header = f"  {'i':>6s}" + "".join(f"  {'i^' + str(k):>12s}" for k in powers)
    print(header)
    print("  " + "-" * (6 + 14 * len(powers)))
    
    for i in indices:
        row = f"  {i:>6d}"
        for k in powers:
            row += f"  {i**k:>12d}"
        print(row)
    
    print()
    print("  Each column grows strictly faster than the previous")
    print("  → In the ultrapower, i^k > i^(k-1) > ... > i > n for any standard n")
    print("  → The ultrapower has infinitely many 'levels of infinity'")
    print()


def demonstrate_compactness():
    """
    Demonstrate the ultrafilter proof of compactness.
    
    Key idea: if every finite subset of constraints is satisfiable,
    the whole set is satisfiable (via ultrafilter/ultraproduct).
    """
    print("=== Compactness via Ultrafilters ===")
    print()
    
    # Example: constraints "x > n" for each n
    # Every finite subset {x > n1, ..., x > nk} is satisfied by x = max(n1,...,nk) + 1
    # But no single x satisfies all of them (in standard ℕ)
    # In the ultraproduct, the diagonal element satisfies all!
    
    constraints = list(range(10))
    print("  Constraints: x > 0, x > 1, x > 2, ..., x > 9, ...")
    print()
    
    for size in [1, 3, 5, 8]:
        subset = constraints[:size]
        witness = max(subset) + 1
        print(f"  Finite subset {{x > {', x > '.join(str(n) for n in subset)}}}")
        print(f"    → Satisfied by x = {witness}")
    
    print()
    print("  Every finite subset is satisfiable!")
    print("  → By compactness (via ultrafilter), ∃ ultrafilter U witnessing all constraints")
    print("  → In the ultraproduct, the diagonal element id(i) = i satisfies all x > n")
    print()


def demonstrate_overspill():
    """
    Demonstrate the overspill principle.
    
    If S_0 ⊇ S_1 ⊇ S_2 ⊇ ... are all "large" and each element
    eventually leaves, there exists a function growing to infinity
    while staying inside the chain.
    """
    print("=== Overspill Principle ===")
    print()
    
    # Concrete example: S_n = {i | i ≥ n}
    N = 20
    print("  Decreasing chain: S_n = {i ∈ ℕ | i ≥ n}")
    print()
    
    for n in [0, 5, 10, 15]:
        elements = [i for i in range(N) if i >= n]
        print(f"  S_{n:2d} = {{{', '.join(str(x) for x in elements)}, ...}}")
    
    print()
    print("  Each S_n is cofinite (hence in any free ultrafilter)")
    print("  Each element i eventually leaves: i ∉ S_{i+1}")
    print()
    print("  Overspill function f(i) = i:")
    print("    - f(i) → ∞ (exceeds every standard bound)")
    print("    - i ∈ S_{f(i)} = S_i iff i ≥ i ✓")
    print()


def demonstrate_transfer():
    """
    Demonstrate algebraic transfer through ultraproducts.
    """
    print("=== Algebraic Transfer: Division Algorithm ===")
    print()
    
    # Show division algorithm transfers coordinatewise
    a_vals = [17, 23, 31, 42, 55]
    d_vals = [5, 7, 4, 6, 8]
    
    print("  Division algorithm in each coordinate:")
    for i, (a, d) in enumerate(zip(a_vals, d_vals)):
        q, r = divmod(a, d)
        assert a == d * q + r and r < d
        print(f"    i={i}: {a} = {d} × {q} + {r}  (r={r} < d={d} ✓)")
    
    print()
    print("  In the ultraproduct:")
    print(f"    a = ({', '.join(str(x) for x in a_vals)}, ...)")
    print(f"    d = ({', '.join(str(x) for x in d_vals)}, ...)")
    print(f"    q = ({', '.join(str(a//d) for a, d in zip(a_vals, d_vals))}, ...)")
    print(f"    r = ({', '.join(str(a%d) for a, d in zip(a_vals, d_vals))}, ...)")
    print("    a = d·q + r and r < d hold coordinatewise → hold in ultraproduct!")
    print()


if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════════╗")
    print("║  Non-Standard Arithmetic: Demonstrations                    ║")
    print("║  Ultrafilter Transfer & Characteristic Zero Emergence       ║")
    print("╚══════════════════════════════════════════════════════════════╝")
    print()
    
    simulate_ultrafilter_pigeonhole(100, 5)
    demonstrate_characteristic_zero()
    demonstrate_non_archimedean_hierarchy()
    demonstrate_compactness()
    demonstrate_overspill()
    demonstrate_transfer()


#!/usr/bin/env python3
"""
Visualization: Non-Archimedean Hierarchy in Ultrapowers

Shows how the functions i, i², i³, i⁴ grow, demonstrating the
hierarchy of "infinities" in the ultrapower.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def plot_power_hierarchy():
    """Plot the power hierarchy i^k for k = 1, 2, 3, 4."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Left: linear scale
    ax = axes[0]
    x = np.arange(2, 20)
    colors = ['#2196F3', '#FF5722', '#4CAF50', '#9C27B0']
    labels = ['i', 'i²', 'i³', 'i⁴']

    for k, (color, label) in enumerate(zip(colors, labels), 1):
        ax.plot(x, x**k, 'o-', color=color, label=label,
                markersize=4, linewidth=2)

    ax.set_xlabel('Index i', fontsize=12)
    ax.set_ylabel('Value', fontsize=12)
    ax.set_title('Power Hierarchy (Linear Scale)', fontsize=14)
    ax.legend(fontsize=11)
    ax.set_yscale('linear')
    ax.set_ylim(0, 5000)
    ax.grid(True, alpha=0.3)

    # Right: log scale
    ax = axes[1]
    x = np.arange(2, 50)
    for k, (color, label) in enumerate(zip(colors, labels), 1):
        ax.plot(x, x**k, '-', color=color, label=label, linewidth=2)

    ax.set_xlabel('Index i', fontsize=12)
    ax.set_ylabel('Value (log scale)', fontsize=12)
    ax.set_title('Power Hierarchy (Log Scale)', fontsize=14)
    ax.legend(fontsize=11)
    ax.set_yscale('log')
    ax.grid(True, alpha=0.3)

    # Add annotation
    ax.annotate('Each level strictly dominates\nthe previous for i ≥ 2',
                xy=(30, 30**3), fontsize=10,
                bbox=dict(boxstyle='round,pad=0.3', facecolor='lightyellow'))

    plt.suptitle('Non-Archimedean Hierarchy in Ultrapowers',
                 fontsize=16, fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig('viz_hierarchy.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved viz_hierarchy.png")


def plot_char_zero_emergence():
    """Visualize characteristic zero emergence."""
    fig, ax = plt.subplots(figsize=(10, 6))

    # Generate primes
    primes = []
    candidate = 2
    while len(primes) < 100:
        if all(candidate % p != 0 for p in primes):
            primes.append(candidate)
        candidate += 1

    # For each N, compute fraction of primes > N
    N_values = range(1, 200)
    fractions = []
    for N in N_values:
        frac = sum(1 for p in primes if p > N) / len(primes)
        fractions.append(frac)

    ax.plot(list(N_values), fractions, 'b-', linewidth=2)
    ax.axhline(y=0.5, color='red', linestyle='--', alpha=0.5,
               label='50% threshold')

    # Mark key points
    for N_mark in [10, 50, 100]:
        frac = sum(1 for p in primes if p > N_mark) / len(primes)
        ax.plot(N_mark, frac, 'ro', markersize=8)
        ax.annotate(f'N={N_mark}: {frac:.0%}', xy=(N_mark, frac),
                    xytext=(N_mark+10, frac+0.05), fontsize=9,
                    arrowprops=dict(arrowstyle='->', color='red'))

    ax.set_xlabel('Threshold N', fontsize=12)
    ax.set_ylabel('Fraction of primes p > N', fontsize=12)
    ax.set_title('Characteristic Zero Emergence:\nFraction of primes exceeding each threshold',
                 fontsize=14)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('viz_char_zero.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved viz_char_zero.png")


def plot_overspill_function():
    """Visualize the overspill function."""
    fig, ax = plt.subplots(figsize=(10, 6))

    # S_n = {i | i >= n}, overspill function f(i) = i
    N = 30
    x = np.arange(0, N)

    # Plot membership regions
    for n in range(0, 10, 2):
        ax.fill_between(x, n, 0, where=(x >= n),
                         alpha=0.1, color=plt.cm.viridis(n/10))
        ax.axhline(y=n, color=plt.cm.viridis(n/10), alpha=0.3,
                   linestyle=':', linewidth=1)
        if n < 8:
            ax.text(N-1, n+0.3, f'S_{n}', fontsize=9,
                    color=plt.cm.viridis(n/10))

    # Plot f(i) = i (diagonal)
    ax.plot(x, x, 'r-', linewidth=3, label='f(i) = i (overspill function)')
    ax.plot(x, x, 'ro', markersize=4)

    ax.set_xlabel('Index i', fontsize=12)
    ax.set_ylabel('Level n / f(i)', fontsize=12)
    ax.set_title('Overspill Principle: f(i) grows while staying in S_{f(i)}',
                 fontsize=14)
    ax.legend(fontsize=11)
    ax.set_xlim(-0.5, N)
    ax.set_ylim(-0.5, N)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('viz_overspill.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved viz_overspill.png")


if __name__ == "__main__":
    plot_power_hierarchy()
    plot_char_zero_emergence()
    plot_overspill_function()
    print("All visualizations generated.")
