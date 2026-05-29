"""
Visualization: 𝔽₁-Cardinality Across Lattice Families

Compares the 𝔽₁-cardinality (number of sup-irreducible elements) across
three families of finite distributive lattices:
1. Boolean lattices B_n (powerset): F1Card = n
2. Chain lattices C_n: F1Card = n (every non-bot element is sup-irred)  
3. Divisor lattices D_n: F1Card = Ω(n) (number of prime power divisors)

This visualizes how the 𝔽₁-cardinality captures the "essential complexity"
of each lattice family.
"""

import matplotlib.pyplot as plt
import numpy as np
from math import gcd
from itertools import combinations
from functools import reduce


def powerset(ground):
    elems = sorted(ground)
    result = []
    for r in range(len(elems) + 1):
        for c in combinations(elems, r):
            result.append(frozenset(c))
    return result


def f1card_boolean(n):
    """F1Card of B_n = n (singletons)."""
    return n


def f1card_chain(n):
    """F1Card of C_n = {0,1,...,n} under max.
    Every element except 0 is sup-irreducible in a chain."""
    return n


def f1card_divisor(n):
    """F1Card of the divisor lattice of n = #prime power divisors."""
    if n <= 1:
        return 0
    divs = [d for d in range(1, n + 1) if n % d == 0]
    lcm_fn = lambda a, b: a * b // gcd(a, b)
    count = 0
    for d in divs:
        if d == 1:
            continue
        is_irred = True
        for a in divs:
            for b in divs:
                if lcm_fn(a, b) == d and a != d and b != d:
                    is_irred = False
                    break
            if not is_irred:
                break
        if is_irred:
            count += 1
    return count


def main():
    fig, axes = plt.subplots(1, 3, figsize=(16, 5))

    # Panel 1: Boolean lattice
    ax = axes[0]
    ns = list(range(1, 11))
    f1cards = [f1card_boolean(n) for n in ns]
    sizes = [2**n for n in ns]

    ax.bar(ns, f1cards, color='#e74c3c', alpha=0.8, edgecolor='#c0392b',
           label='𝔽₁-cardinality')
    ax2 = ax.twinx()
    ax2.plot(ns, sizes, 'o--', color='#3498db', label='|B_n| = 2^n',
             markersize=6)
    ax2.set_ylabel('Lattice size |B_n|', color='#3498db', fontsize=11)
    ax2.tick_params(axis='y', labelcolor='#3498db')

    ax.set_xlabel('n', fontsize=12)
    ax.set_ylabel('F₁-cardinality', color='#e74c3c', fontsize=11)
    ax.tick_params(axis='y', labelcolor='#e74c3c')
    ax.set_title('Boolean Lattice B_n\nF₁Card = n', fontsize=13,
                 fontweight='bold')
    ax.set_xticks(ns)

    # Panel 2: Chain lattice
    ax = axes[1]
    ns = list(range(1, 11))
    f1cards = [f1card_chain(n) for n in ns]
    sizes = [n + 1 for n in ns]

    ax.bar(ns, f1cards, color='#2ecc71', alpha=0.8, edgecolor='#27ae60',
           label='𝔽₁-cardinality')
    ax2 = ax.twinx()
    ax2.plot(ns, sizes, 's--', color='#9b59b6', label='|C_n| = n+1',
             markersize=6)
    ax2.set_ylabel('Lattice size |C_n|', color='#9b59b6', fontsize=11)
    ax2.tick_params(axis='y', labelcolor='#9b59b6')

    ax.set_xlabel('n', fontsize=12)
    ax.set_ylabel('F₁-cardinality', color='#2ecc71', fontsize=11)
    ax.tick_params(axis='y', labelcolor='#2ecc71')
    ax.set_title('Chain Lattice C_n\nF₁Card = n', fontsize=13,
                 fontweight='bold')
    ax.set_xticks(ns)

    # Panel 3: Divisor lattice
    ax = axes[2]
    # Use highly composite numbers for interesting examples
    test_ns = [2, 4, 6, 8, 12, 16, 24, 30, 36, 48, 60, 72, 120, 180, 360]
    f1cards = [f1card_divisor(n) for n in test_ns]
    num_divs = [len([d for d in range(1, n + 1) if n % d == 0]) for n in test_ns]

    x_pos = range(len(test_ns))
    ax.bar(x_pos, f1cards, color='#f39c12', alpha=0.8, edgecolor='#e67e22',
           label='𝔽₁-cardinality')
    ax2 = ax.twinx()
    ax2.plot(x_pos, num_divs, 'D--', color='#1abc9c', label='#divisors',
             markersize=5)
    ax2.set_ylabel('#divisors', color='#1abc9c', fontsize=11)
    ax2.tick_params(axis='y', labelcolor='#1abc9c')

    ax.set_xlabel('n', fontsize=12)
    ax.set_ylabel('F₁-cardinality', color='#f39c12', fontsize=11)
    ax.tick_params(axis='y', labelcolor='#f39c12')
    ax.set_title('Divisor Lattice D_n\nF₁Card = Ω(n)', fontsize=13,
                 fontweight='bold')
    ax.set_xticks(x_pos)
    ax.set_xticklabels([str(n) for n in test_ns], rotation=45, fontsize=8)

    plt.suptitle('𝔽₁-Cardinality: The "Essential Dimension" of Finite Lattices',
                 fontsize=15, fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig('viz_f1card_comparison.png', dpi=150, bbox_inches='tight')
    print("Saved viz_f1card_comparison.png")


if __name__ == "__main__":
    main()
