#!/usr/bin/env python3
"""
demo.py — Numerical demonstrations of non-standard arithmetic concepts.

Demonstrates:
1. Ultrafilter partition regularity (simulation)
2. Overspill principle behavior
3. GCD transfer through ultrapowers
4. Non-Archimedean element construction
"""

import random
from typing import List, Tuple, Dict, Callable
from collections import Counter


def simulate_ultrafilter_partition(
    n: int = 100, k: int = 3, num_trials: int = 1000
) -> Dict[int, float]:
    """Simulate partition regularity: in random k-colorings of {0,...,n-1},
    measure the probability that each color class dominates (would be U-large).

    In a genuine ultrafilter, EXACTLY one class is selected. Here we approximate
    by counting which class has the largest share.
    """
    color_wins = Counter()
    for _ in range(num_trials):
        coloring = [random.randint(0, k - 1) for _ in range(n)]
        counts = Counter(coloring)
        winner = counts.most_common(1)[0][0]
        color_wins[winner] += 1
    return {c: wins / num_trials for c, wins in sorted(color_wins.items())}


def demonstrate_overspill(
    property_fn: Callable[[int], bool], name: str = "P"
) -> None:
    """Demonstrate overspill: if P(n) holds for all standard n,
    it must hold for 'non-standard' (very large) n too.

    We test P on increasingly large values to show it doesn't stop.
    """
    print(f"\n--- Overspill Demonstration for {name} ---")
    test_values = [10, 100, 1000, 10_000, 100_000, 1_000_000]
    for n in test_values:
        result = all(property_fn(k) for k in range(n))
        symbol = "✓" if result else "✗"
        print(f"  ∀ k < {n:>10,}: {name}(k) holds: {symbol}")
    print(f"  → By overspill, {name} holds for some non-standard element too!")


def gcd_transfer_example() -> None:
    """Demonstrate GCD transfer: gcd(f(i), g(i)) = d(i) componentwise
    implies the GCD relation transfers to the ultrapower.
    """
    print("\n--- GCD Transfer Demonstration ---")
    # Define sequences
    f = lambda i: 12 * (i + 1)  # multiples of 12
    g = lambda i: 18 * (i + 1)  # multiples of 18
    d = lambda i: 6 * (i + 1)   # gcd should be 6*(i+1)

    print("  Sequences: f(i) = 12(i+1), g(i) = 18(i+1)")
    print("  Expected:  gcd(f(i), g(i)) = 6(i+1) for all i")
    print()
    for i in range(8):
        fi, gi, di = f(i), g(i), d(i)
        actual_gcd = gcd(fi, gi)
        match = "✓" if actual_gcd == di else "✗"
        print(f"  i={i}: gcd({fi}, {gi}) = {actual_gcd} = {di} {match}")

    print("\n  In *ℕ: [d] | [f] via quotient q(i) = f(i)/d(i) = 2")
    print("  In *ℕ: [d] | [g] via quotient q(i) = g(i)/d(i) = 3")


def gcd(a: int, b: int) -> int:
    """Euclidean GCD."""
    while b:
        a, b = b, a % b
    return a


def non_archimedean_element() -> None:
    """Demonstrate that ω = [id] exceeds all standard elements.

    For any N, the set {i | i > N} is cofinite, hence in any
    non-principal ultrafilter U.
    """
    print("\n--- Non-Archimedean Element ω = [id] ---")
    print("  ω is represented by the sequence (0, 1, 2, 3, ...)")
    print()
    for N in [10, 100, 1000, 10**6, 10**9]:
        cofinite_size = "infinite"
        print(f"  N = {N:>12,}: |{{i | i > N}}| = {cofinite_size} "
              f"(cofinite → U-large)")
    print()
    print("  Therefore ω > std(N) for ALL standard N.")
    print("  ω is 'infinitely large' — a non-standard element of *ℕ.")


def polynomial_identity_transfer() -> None:
    """Demonstrate Łoś theorem for term equations.

    The identity (a+b)² = a² + 2ab + b² holds in ℕ,
    so it must hold in *ℕ.
    """
    print("\n--- Polynomial Identity Transfer (Łoś for Terms) ---")
    print("  Identity: (a + b)² = a² + 2ab + b²")
    print()

    # Represent as NatExpr and evaluate
    for a, b in [(3, 5), (7, 11), (100, 200), (0, 42)]:
        lhs = (a + b) ** 2
        rhs = a**2 + 2*a*b + b**2
        match = "✓" if lhs == rhs else "✗"
        print(f"  a={a}, b={b}: ({a}+{b})² = {lhs} = {a}²+2·{a}·{b}+{b}² = {rhs} {match}")

    print()
    print("  Since this holds for ALL (a,b) ∈ ℕ², by Łoś's theorem,")
    print("  it holds for ALL (α,β) ∈ *ℕ², including non-standard α,β.")


def main():
    print("=" * 60)
    print("NON-STANDARD ARITHMETIC: NUMERICAL DEMONSTRATIONS")
    print("=" * 60)

    # 1. Non-Archimedean element
    non_archimedean_element()

    # 2. Polynomial identity transfer
    polynomial_identity_transfer()

    # 3. GCD transfer
    gcd_transfer_example()

    # 4. Overspill with "every number has a successor"
    demonstrate_overspill(lambda n: n + 1 > n, "n+1 > n")

    # 5. Overspill with "every number is the sum of four squares"
    def is_sum_of_four_squares(n: int) -> bool:
        for a in range(int(n**0.5) + 1):
            for b in range(int((n - a*a)**0.5) + 1):
                for c in range(int((n - a*a - b*b)**0.5) + 1):
                    d2 = n - a*a - b*b - c*c
                    if d2 >= 0:
                        d = int(d2**0.5)
                        if d*d == d2:
                            return True
        return False

    demonstrate_overspill(is_sum_of_four_squares, "Lagrange 4-squares")

    # 6. Partition regularity simulation
    print("\n--- Partition Regularity Simulation ---")
    for k in [2, 3, 5]:
        probs = simulate_ultrafilter_partition(k=k)
        print(f"  {k}-coloring: winning probabilities = {probs}")
    print("  (In a true ultrafilter, exactly one color 'wins' with probability 1)")

    print("\n" + "=" * 60)
    print("All demonstrations complete.")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
visualize_ultrapower.py — Visualizations of non-standard arithmetic concepts.

Creates three figures:
1. The ultrapower ordering: standard vs non-standard elements
2. Overspill principle: how properties "spill over"
3. GCD transfer: divisibility lattice preservation
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def plot_ultrapower_ordering():
    """Visualize the ordering of *ℕ showing standard and non-standard elements."""
    fig, ax = plt.subplots(1, 1, figsize=(14, 4))

    # Standard elements
    std_positions = np.arange(0, 8)
    ax.scatter(std_positions, [0]*8, c='blue', s=100, zorder=5, label='Standard elements')
    for i, pos in enumerate(std_positions):
        ax.annotate(str(i), (pos, 0), textcoords="offset points",
                   xytext=(0, 12), ha='center', fontsize=10, color='blue')

    # Gap indicator
    ax.annotate('...', (8.5, 0), fontsize=16, ha='center', va='center', color='gray')

    # Non-standard elements
    ns_positions = [10, 11, 12, 13]
    ns_labels = ['ω', 'ω+1', 'ω+2', 'ω²']
    colors = ['red', 'orangered', 'orange', 'darkred']
    ax.scatter(ns_positions, [0]*4, c=colors, s=150, zorder=5,
              marker='D', label='Non-standard elements')
    for label, pos, color in zip(ns_labels, ns_positions, colors):
        ax.annotate(label, (pos, 0), textcoords="offset points",
                   xytext=(0, 15), ha='center', fontsize=11, color=color, fontweight='bold')

    # More gap
    ax.annotate('...', (14, 0), fontsize=16, ha='center', va='center', color='gray')

    # Arrow showing ordering
    ax.annotate('', xy=(14.5, 0), xytext=(-0.5, 0),
               arrowprops=dict(arrowstyle='->', color='black', lw=1.5))

    # Bracket for standard part
    ax.annotate('', xy=(7.5, -0.3), xytext=(-0.5, -0.3),
               arrowprops=dict(arrowstyle='<->', color='blue', lw=1))
    ax.text(3.5, -0.5, 'Standard part (ℕ)', ha='center', fontsize=9, color='blue')

    # Bracket for non-standard part
    ax.annotate('', xy=(14, -0.3), xytext=(9.5, -0.3),
               arrowprops=dict(arrowstyle='<->', color='red', lw=1))
    ax.text(11.5, -0.5, 'Non-standard part', ha='center', fontsize=9, color='red')

    ax.set_xlim(-1, 15)
    ax.set_ylim(-0.8, 0.8)
    ax.set_yticks([])
    ax.set_xticks([])
    ax.set_title('The Ultrapower *ℕ: Standard and Non-Standard Elements', fontsize=14)
    ax.legend(loc='upper left', fontsize=9)
    ax.spines['top'].set_visible(False)
    ax.spines['right'].set_visible(False)
    ax.spines['left'].set_visible(False)

    plt.tight_layout()
    plt.savefig('ultrapower_ordering.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: ultrapower_ordering.png")


def plot_overspill():
    """Visualize the overspill principle."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    # Left: Property P holds for all standard n
    n_values = np.arange(0, 20)
    p_values = np.ones(20)  # P(n) = True for all n

    ax1.bar(n_values, p_values, color='steelblue', alpha=0.7, edgecolor='navy')
    ax1.set_xlabel('n (standard)', fontsize=11)
    ax1.set_ylabel('P(n)', fontsize=11)
    ax1.set_title('P(n) holds for all standard n', fontsize=12)
    ax1.set_yticks([0, 1])
    ax1.set_yticklabels(['False', 'True'])
    ax1.set_ylim(0, 1.3)

    # Right: Overspill shows P must hold for some non-standard element
    n_extended = np.arange(0, 25)
    p_extended = np.ones(25)
    colors = ['steelblue'] * 20 + ['crimson'] * 5

    bars = ax2.bar(n_extended, p_extended, color=colors, alpha=0.7,
                   edgecolor=['navy'] * 20 + ['darkred'] * 5)
    ax2.axvline(x=19.5, color='gray', linestyle='--', linewidth=2, label='Standard boundary')
    ax2.set_xlabel('n', fontsize=11)
    ax2.set_ylabel('P(n)', fontsize=11)
    ax2.set_title('Overspill: P "spills over" to non-standard realm', fontsize=12)
    ax2.set_yticks([0, 1])
    ax2.set_yticklabels(['False', 'True'])
    ax2.set_ylim(0, 1.3)

    # Legend
    std_patch = mpatches.Patch(color='steelblue', alpha=0.7, label='Standard')
    ns_patch = mpatches.Patch(color='crimson', alpha=0.7, label='Non-standard (overspill)')
    ax2.legend(handles=[std_patch, ns_patch], loc='upper right', fontsize=9)

    # Annotation arrow
    ax2.annotate('Overspill!', xy=(22, 1.0), xytext=(22, 1.2),
                fontsize=11, color='crimson', fontweight='bold',
                arrowprops=dict(arrowstyle='->', color='crimson'),
                ha='center')

    plt.tight_layout()
    plt.savefig('overspill_principle.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: overspill_principle.png")


def plot_gcd_transfer():
    """Visualize GCD transfer through the ultrapower."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    indices = np.arange(1, 16)

    # Sequences
    f_vals = 12 * indices
    g_vals = 18 * indices
    d_vals = 6 * indices
    qf_vals = f_vals // d_vals  # = 2 for all
    qg_vals = g_vals // d_vals  # = 3 for all

    # Plot f and g
    axes[0].plot(indices, f_vals, 'bo-', label='f(i) = 12i', markersize=5)
    axes[0].plot(indices, g_vals, 'rs-', label='g(i) = 18i', markersize=5)
    axes[0].plot(indices, d_vals, 'g^-', label='gcd(f,g) = 6i', markersize=5)
    axes[0].set_xlabel('Index i', fontsize=11)
    axes[0].set_ylabel('Value', fontsize=11)
    axes[0].set_title('Component Sequences', fontsize=12)
    axes[0].legend(fontsize=9)
    axes[0].grid(True, alpha=0.3)

    # Plot quotients (showing d | f and d | g)
    axes[1].bar(indices - 0.15, qf_vals, width=0.3, color='steelblue',
               label='f(i)/d(i) = 2', alpha=0.8)
    axes[1].bar(indices + 0.15, qg_vals, width=0.3, color='coral',
               label='g(i)/d(i) = 3', alpha=0.8)
    axes[1].set_xlabel('Index i', fontsize=11)
    axes[1].set_ylabel('Quotient', fontsize=11)
    axes[1].set_title('Divisibility Witnesses', fontsize=12)
    axes[1].legend(fontsize=9)
    axes[1].set_ylim(0, 4.5)
    axes[1].grid(True, alpha=0.3)

    # Divisibility lattice diagram
    ax3 = axes[2]
    ax3.set_xlim(-1, 5)
    ax3.set_ylim(-1, 5)

    # Draw lattice nodes
    nodes = {
        '[d]': (2, 0),
        '[f]': (1, 2),
        '[g]': (3, 2),
        '[f·g/d]': (2, 4),
    }

    for name, (x, y) in nodes.items():
        circle = plt.Circle((x, y), 0.3, color='lightblue', ec='navy', lw=2)
        ax3.add_patch(circle)
        ax3.text(x, y, name, ha='center', va='center', fontsize=9, fontweight='bold')

    # Draw edges (divisibility)
    ax3.annotate('', xy=(1, 1.7), xytext=(2, 0.3),
                arrowprops=dict(arrowstyle='->', color='green', lw=2))
    ax3.annotate('', xy=(3, 1.7), xytext=(2, 0.3),
                arrowprops=dict(arrowstyle='->', color='green', lw=2))
    ax3.annotate('', xy=(2, 3.7), xytext=(1, 2.3),
                arrowprops=dict(arrowstyle='->', color='green', lw=2))
    ax3.annotate('', xy=(2, 3.7), xytext=(3, 2.3),
                arrowprops=dict(arrowstyle='->', color='green', lw=2))

    ax3.text(1.2, 1.0, '|', fontsize=14, color='green', fontweight='bold')
    ax3.text(2.8, 1.0, '|', fontsize=14, color='green', fontweight='bold')

    ax3.set_title('Divisibility in *ℕ\n(GCD Transfer)', fontsize=12)
    ax3.set_xticks([])
    ax3.set_yticks([])
    ax3.set_aspect('equal')

    plt.tight_layout()
    plt.savefig('gcd_transfer.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: gcd_transfer.png")


if __name__ == "__main__":
    plot_ultrapower_ordering()
    plot_overspill()
    plot_gcd_transfer()
    print("\nAll visualizations generated.")
