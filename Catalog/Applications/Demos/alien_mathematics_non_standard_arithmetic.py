#!/usr/bin/env python3
"""
Non-Standard Arithmetic: Ultrapower Construction Demos

Demonstrates the key concepts of non-standard arithmetic via ultrapower
constructions, including:
- Simulated ultrafilter selection
- The non-Archimedean property of ℕ*
- The overspill principle
- Well-ordering failure
- Bounded-infinite dichotomy
"""

import random
from typing import Callable, List, Optional, Tuple
from collections import Counter


def simulate_ultrafilter(sets: List[set], n: int = 1000) -> dict:
    """Simulate a free ultrafilter on {0,...,n-1} using density.

    A free ultrafilter contains all cofinite sets. We approximate this
    by checking if a set has density > 0.5 in a large sample.
    """
    universe = set(range(n))
    results = {}
    for i, s in enumerate(sets):
        restricted = s & universe
        density = len(restricted) / n if n > 0 else 0
        results[f"S_{i}"] = {
            "size": len(restricted),
            "density": density,
            "in_ultrafilter": density > 0.5  # Approximate
        }
    return results


def nat_ultra_eq_check(f: Callable, g: Callable, n: int = 10000) -> float:
    """Check U-equivalence by computing the density of agreement."""
    agree = sum(1 for i in range(n) if f(i) == g(i))
    return agree / n


def demo_non_archimedean():
    """Demonstrate that ω = [id] exceeds every standard natural."""
    print("=" * 60)
    print("DEMO 1: Non-Archimedean Property of ℕ*")
    print("=" * 60)
    print()
    print("ω = [id] = (0, 1, 2, 3, 4, ...)")
    print("std(n) = [const_n] = (n, n, n, n, ...)")
    print()
    print("For each standard n, we check: {i | n ≤ id(i)} = {n, n+1, n+2, ...}")
    print("This is a cofinite set, hence in any free ultrafilter.")
    print()

    N = 10000
    for n in [0, 5, 100, 1000, 9999]:
        exceeds = sum(1 for i in range(N) if n <= i)
        density = exceeds / N
        print(f"  n = {n:5d}: density({{i | n ≤ i}}) = {density:.4f}  "
              f"({'U-large ✓' if density > 0.5 else 'not U-large'})")

    print()
    print("  → ω exceeds every standard natural in ℕ*")
    print()

    # Check that ω ≠ std(n) for any n
    print("  Checking ω ≠ std(n):")
    for n in [0, 42, 1000]:
        agree_density = nat_ultra_eq_check(lambda i: i, lambda i: n, N)
        print(f"  n = {n:5d}: density({{i | id(i) = n}}) = {agree_density:.6f}  "
              f"({'≠ in ℕ* ✓' if agree_density < 0.01 else '?'})")


def demo_overspill():
    """Demonstrate the overspill principle."""
    print()
    print("=" * 60)
    print("DEMO 2: The Overspill Principle")
    print("=" * 60)
    print()
    print("Property P(i, n) = 'i > n' holds for all standard n.")
    print("The overspill principle guarantees a non-standard bound.")
    print()

    N = 10000
    # For each n, A_n = {i | ∀ k ≤ n, i > k} = {i | i > n}
    print("  Simultaneous satisfaction sets A_n = {i | ∀ k ≤ n, i > k}:")
    for n in [0, 10, 100, 1000, 5000]:
        sat = sum(1 for i in range(N) if all(i > k for k in range(n + 1)))
        density = sat / N
        print(f"  n = {n:5d}: density(A_n) = {density:.4f}  "
              f"({'U-large ✓' if density > 0.5 else 'thin'})")

    print()
    print("  Overspill function f(i) = i (the diagonal):")
    print("  For each i, f(i) = i gives ∀ k ≤ i, P(i, k) ↔ ∀ k ≤ i, i > k")
    print("  This holds for all i > 0, so {i | ∀ k ≤ f(i), P(i,k)} has density ≈ 1")

    sat_all = sum(1 for i in range(N) if all(i > k for k in range(i + 1)) or i == 0)
    # Actually ∀ k ≤ i, i > k is false when k = i
    # Let's use P(i,n) = "i ≥ n" instead
    print()
    print("  Corrected: P(i, n) = 'i ≥ n'")
    sat_all = sum(1 for i in range(N) if all(i >= k for k in range(i + 1)))
    print(f"  density({{i | ∀ k ≤ i, i ≥ k}}) = {sat_all / N:.4f} ✓")


def demo_well_ordering_failure():
    """Demonstrate that ℕ* is not well-ordered."""
    print()
    print("=" * 60)
    print("DEMO 3: Well-Ordering Failure in ℕ*")
    print("=" * 60)
    print()
    print("Starting from ω = [id], we construct a descending chain:")
    print("ω, ω-1, ω-2, ω-3, ...")
    print("Each element is still 'infinite' (exceeds all standards).")
    print()

    N = 10000
    for step in range(6):
        f = lambda i, s=step: max(i - s, 0)
        # Check: is this element still infinite?
        print(f"  ω - {step}: f(i) = max(i - {step}, 0)")
        for n in [0, 100, 1000]:
            exceeds = sum(1 for i in range(N) if f(i) > n)
            density = exceeds / N
            print(f"    {{i| f(i) > {n}}}: density = {density:.4f} "
                  f"({'U-large ✓' if density > 0.5 else '✗'})")
        print()

    print("  → Infinite descending chain: no minimum among infinite elements")
    print("  → ℕ* violates well-ordering (a second-order property)")


def demo_dichotomy():
    """Demonstrate the bounded-infinite dichotomy."""
    print()
    print("=" * 60)
    print("DEMO 4: Bounded-Infinite Dichotomy")
    print("=" * 60)
    print()

    N = 10000
    examples = [
        ("Constant: f(i) = 42", lambda i: 42, "bounded"),
        ("Periodic: f(i) = i mod 7", lambda i: i % 7, "bounded"),
        ("Diagonal: f(i) = i", lambda i: i, "infinite"),
        ("Quadratic: f(i) = i²", lambda i: i * i, "infinite"),
        ("Alternating: f(i) = 0 if even, i if odd",
         lambda i: 0 if i % 2 == 0 else i, "depends on U"),
    ]

    for name, f, expected in examples:
        print(f"  {name}")

        # Check boundedness
        vals = [f(i) for i in range(N)]
        counter = Counter(vals)
        most_common_val, most_common_count = counter.most_common(1)[0]

        # Check if some value dominates
        if most_common_count / N > 0.5:
            std_part = most_common_val
            print(f"    → BOUNDED, standard part = {std_part} "
                  f"(density = {most_common_count / N:.3f})")
        else:
            # Check if values grow
            max_val = max(vals)
            if max_val > 1000:
                print(f"    → INFINITE (max value = {max_val})")
            else:
                print(f"    → Ambiguous (max = {max_val}, "
                      f"top value {most_common_val} has density "
                      f"{most_common_count / N:.3f})")

        print(f"    Expected: {expected}")
        print()


def demo_transfer():
    """Demonstrate polynomial identity transfer."""
    print()
    print("=" * 60)
    print("DEMO 5: Polynomial Identity Transfer")
    print("=" * 60)
    print()
    print("The Gauss sum identity ∑_{k=0}^n k = n(n+1)/2")
    print("transfers to ℕ*: for any [a] ∈ ℕ*,")
    print("  [∑_{k=0}^{a(i)} k] = [a(i)·(a(i)+1)/2]")
    print()

    N = 100
    a_funcs = [
        ("a(i) = i", lambda i: i),
        ("a(i) = 2i + 1", lambda i: 2 * i + 1),
        ("a(i) = i²", lambda i: i * i),
    ]

    for name, a in a_funcs:
        agree = 0
        for i in range(N):
            n = a(i)
            gauss = n * (n + 1) // 2
            actual_sum = sum(range(n + 1))
            if gauss == actual_sum:
                agree += 1
        print(f"  {name}: agreement density = {agree / N:.4f} ✓")


def main():
    print("Non-Standard Arithmetic: Ultrapower Construction Demos")
    print("=" * 60)
    print()

    demo_non_archimedean()
    demo_overspill()
    demo_well_ordering_failure()
    demo_dichotomy()
    demo_transfer()

    print()
    print("=" * 60)
    print("All demos completed successfully.")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Non-Standard Arithmetic — Ultrapower Structure

Generates plots showing:
1. The non-Archimedean property: ω exceeds every standard natural
2. Descending chain among infinite elements
3. Bounded-infinite dichotomy density plots
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from collections import Counter


def plot_non_archimedean():
    """Plot the density of {i | n ≤ i} for various n, showing ω > std(n)."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    N = 10000
    ns = list(range(0, N, 100))
    densities = [(N - n) / N for n in ns]

    ax1.plot(ns, densities, 'b-', linewidth=2)
    ax1.axhline(y=0.5, color='r', linestyle='--', label='U-threshold (0.5)')
    ax1.fill_between(ns, densities, 0.5, where=[d > 0.5 for d in densities],
                     alpha=0.3, color='blue', label='{i | n ≤ i} ∈ U')
    ax1.set_xlabel('Standard natural n', fontsize=12)
    ax1.set_ylabel('Density of {i | n ≤ i}', fontsize=12)
    ax1.set_title('ω = [id] exceeds every standard n', fontsize=14)
    ax1.legend(fontsize=10)
    ax1.set_ylim(-0.05, 1.05)

    # Right: Agreement density for ω vs std(n)
    ns2 = list(range(0, 100))
    agree = [1 / N for _ in ns2]  # {i | i = n} has exactly 1 element

    ax2.bar(ns2, agree, color='red', alpha=0.7, width=0.8)
    ax2.axhline(y=0.5, color='b', linestyle='--', label='U-threshold')
    ax2.set_xlabel('Standard natural n', fontsize=12)
    ax2.set_ylabel('Density of {i | id(i) = n}', fontsize=12)
    ax2.set_title('ω ≠ std(n): singletons have zero density', fontsize=14)
    ax2.legend(fontsize=10)
    ax2.set_ylim(-0.001, 0.01)

    plt.tight_layout()
    plt.savefig('viz_non_archimedean.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: viz_non_archimedean.png")


def plot_descending_chain():
    """Plot the descending chain ω, ω-1, ω-2, ... showing well-ordering failure."""
    fig, ax = plt.subplots(figsize=(12, 6))

    N = 500
    indices = np.arange(N)

    colors = plt.cm.viridis(np.linspace(0, 0.8, 8))

    for step in range(8):
        values = np.maximum(indices - step, 0)
        ax.plot(indices, values, color=colors[step], linewidth=1.5,
                label=f'ω - {step}', alpha=0.8)

    ax.set_xlabel('Index i', fontsize=12)
    ax.set_ylabel('Value f(i)', fontsize=12)
    ax.set_title('Infinite Descending Chain in ℕ*: Well-Ordering Fails', fontsize=14)
    ax.legend(loc='upper left', fontsize=9)

    # Add annotation
    ax.annotate('All elements are "infinite"\n(exceed every standard n)',
                xy=(350, 200), fontsize=11,
                bbox=dict(boxstyle='round,pad=0.3', facecolor='lightyellow'))

    plt.tight_layout()
    plt.savefig('viz_descending_chain.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: viz_descending_chain.png")


def plot_dichotomy():
    """Plot the bounded-infinite dichotomy for various elements."""
    fig, axes = plt.subplots(2, 3, figsize=(16, 10))

    N = 1000
    indices = np.arange(N)

    examples = [
        ("Bounded: f(i) = 42", lambda i: 42),
        ("Bounded: f(i) = i mod 7", lambda i: i % 7),
        ("Bounded: f(i) = min(i, 10)", lambda i: min(i, 10)),
        ("Infinite: f(i) = i (ω)", lambda i: i),
        ("Infinite: f(i) = i²", lambda i: i * i),
        ("Infinite: f(i) = 2^(i/100)", lambda i: int(2 ** (i / 100))),
    ]

    for idx, (name, f) in enumerate(examples):
        ax = axes[idx // 3][idx % 3]

        values = [f(i) for i in range(N)]
        counter = Counter(values)

        if max(values) < 100:
            # Histogram for bounded
            bins = range(min(values), max(values) + 2)
            ax.hist(values, bins=bins, color='steelblue', alpha=0.7,
                    edgecolor='white', density=True)
            ax.axhline(y=0.5, color='r', linestyle='--', alpha=0.5,
                       label='U-threshold')
        else:
            # Line plot for infinite
            ax.plot(indices, values, 'steelblue', linewidth=0.5, alpha=0.7)
            ax.set_ylabel('f(i)')

        ax.set_title(name, fontsize=11)
        ax.set_xlabel('Index i' if max(values) >= 100 else 'Value')

    plt.suptitle('Bounded-Infinite Dichotomy in ℕ*', fontsize=16, y=1.02)
    plt.tight_layout()
    plt.savefig('viz_dichotomy.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: viz_dichotomy.png")


if __name__ == "__main__":
    plot_non_archimedean()
    plot_descending_chain()
    plot_dichotomy()
    print("\nAll visualizations generated.")
