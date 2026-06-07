#!/usr/bin/env python3
"""
visualize_orbits.py — Visualization of substitution orbit structure.

Plots orbit sizes and the orbit-diversity correspondence for small Babel spaces.
"""
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import itertools
import math
from collections import Counter

def compute_orbit_size(book: tuple, alpha: int) -> int:
    """Compute the substitution orbit size of a book."""
    orbit = set()
    for sub in itertools.product(range(alpha), repeat=alpha):
        sigma = dict(enumerate(sub))
        orbit.add(tuple(sigma[c] for c in book))
    return len(orbit)

def symbol_diversity(book: tuple) -> int:
    return len(set(book))

fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# For alpha = 2, 3, 4
for idx, alpha in enumerate([2, 3, 4]):
    ax = axes[idx]
    N = 4 if alpha <= 3 else 3
    books = list(itertools.product(range(alpha), repeat=N))

    diversities = []
    orbit_sizes = []
    predicted = []

    for book in books:
        d = symbol_diversity(book)
        o = compute_orbit_size(book, alpha)
        p = math.perm(alpha, d)
        diversities.append(d)
        orbit_sizes.append(o)
        predicted.append(p)

    ax.scatter(diversities, orbit_sizes, alpha=0.5, s=40, label='Actual orbit size')
    # Plot predicted line
    unique_d = sorted(set(diversities))
    pred_line = [math.perm(alpha, d) for d in unique_d]
    ax.plot(unique_d, pred_line, 'r--', linewidth=2, label='Predicted α^(d)')

    all_match = all(o == p for o, p in zip(orbit_sizes, predicted))
    ax.set_xlabel('Symbol Diversity d', fontsize=11)
    ax.set_ylabel('Orbit Size', fontsize=11)
    ax.set_title(f'Book(α={alpha}, N={N})\nConjecture {"✓" if all_match else "✗"}',
                 fontsize=12)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('babel_orbits.png', dpi=150, bbox_inches='tight')
print("Saved: babel_orbits.png")
