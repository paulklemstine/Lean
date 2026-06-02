#!/usr/bin/env python3
"""
demo.py — Numerical demonstrations of neural network decision surface geometry.

Computes Zaslavsky bounds, Hodge ranks, and region counts for various
ReLU network architectures.
"""

import math
from typing import List, Tuple


def choose(n: int, k: int) -> int:
    """Binomial coefficient C(n, k)."""
    if k < 0 or k > n:
        return 0
    return math.comb(n, k)


def max_regions(n: int, d: int) -> int:
    """Zaslavsky bound: max regions from n hyperplanes in R^d."""
    return sum(choose(n, k) for k in range(d + 1))


def deep_region_bound(d: int, w: int, L: int) -> int:
    """Montufar et al. bound for L-layer width-w network in R^d."""
    return max_regions(w, d) * (2 ** w) ** max(0, L - 1)


def hodge_rank(widths: List[int], p: int, q: int) -> int:
    """Conjectured Hodge rank h^{p,q} for a network architecture."""
    if len(widths) < 2:
        return 0
    w1 = widths[0]
    wL = widths[-1] if len(widths) >= 3 else widths[0]
    return choose(w1, p) * choose(wL, q)


def arrangement_face_bound(n: int, d: int, k: int) -> int:
    """Upper bound on k-faces of n hyperplanes in R^d."""
    return choose(n, d - k) * choose(d, k)


def euler_characteristic(face_counts: List[int]) -> int:
    """Euler characteristic from face counts."""
    return sum((-1) ** i * f for i, f in enumerate(face_counts))


def relu(x: float) -> float:
    """The ReLU function."""
    return max(0.0, x)


# ==================== Demonstrations ====================

print("=" * 60)
print("NEURAL NETWORK DECISION SURFACE GEOMETRY")
print("=" * 60)

# Demo 1: Zaslavsky bounds
print("\n--- Zaslavsky Region Bounds ---")
print(f"{'Hyperplanes':>12} {'Dim':>4} {'Regions':>10}")
print("-" * 30)
for n in [0, 1, 2, 3, 5, 10]:
    for d in [1, 2, 3]:
        print(f"{n:>12} {d:>4} {max_regions(n, d):>10}")

# Demo 2: Deep network bounds
print("\n--- Deep Network Region Bounds (Montufar et al.) ---")
print(f"{'(d,w,L)':>15} {'Bound':>15}")
print("-" * 35)
for d, w, L in [(2, 3, 1), (2, 3, 2), (2, 3, 3), (2, 5, 2),
                 (3, 4, 2), (10, 10, 3)]:
    bound = deep_region_bound(d, w, L)
    print(f"({d},{w},{L}){' ' * (10 - len(f'({d},{w},{L})'))} {bound:>15,}")

# Demo 3: Hodge ranks
print("\n--- Hodge Rank Bounds h^{p,q} ---")
for arch_name, widths in [("[2,3,1]", [2, 3, 1]),
                           ("[3,5,1]", [3, 5, 1]),
                           ("[2,4,3,1]", [2, 4, 3, 1]),
                           ("[10,20,1]", [10, 20, 1])]:
    print(f"\nArchitecture {arch_name}:")
    max_p = min(widths[0], 4)
    max_q = min(widths[-1], 4)
    for p in range(max_p + 1):
        for q in range(max_q + 1):
            h = hodge_rank(widths, p, q)
            if h > 0:
                print(f"  h^{{{p},{q}}} = {h}")

# Demo 4: Face bounds
print("\n--- Arrangement Face Bounds ---")
d = 3
print(f"In R^{d} with varying hyperplanes:")
for n in [3, 5, 10, 20]:
    print(f"  n={n}: ", end="")
    for k in range(d):
        bound = arrangement_face_bound(n, d, k)
        print(f"f_{k}≤{bound}  ", end="")
    print()

# Demo 5: Euler characteristics
print("\n--- Euler Characteristics ---")
examples = [
    ("5 points", [5]),
    ("Triangle (3v, 3e)", [3, 3]),
    ("Cube skeleton (8v, 12e, 6f)", [8, 12, 6]),
    ("Tetrahedron (4v, 6e, 4f)", [4, 6, 4]),
]
for name, faces in examples:
    chi = euler_characteristic(faces)
    print(f"  {name}: χ = {chi}")

# Demo 6: ReLU idempotence verification
print("\n--- ReLU Properties Verification ---")
import random
random.seed(42)
test_values = [random.uniform(-10, 10) for _ in range(1000)]
print(f"  Idempotence: relu(relu(x)) == relu(x) for all 1000 samples: "
      f"{all(relu(relu(x)) == relu(x) for x in test_values)}")
print(f"  Nonnegativity: relu(x) >= 0 for all 1000 samples: "
      f"{all(relu(x) >= 0 for x in test_values)}")
lip_pairs = [(random.uniform(-10, 10), random.uniform(-10, 10))
             for _ in range(1000)]
print(f"  1-Lipschitz: |relu(x)-relu(y)| <= |x-y| for all 1000 pairs: "
      f"{all(abs(relu(x) - relu(y)) <= abs(x - y) + 1e-15 for x, y in lip_pairs)}")
print(f"  Half-abs decomposition: relu(x) == (x+|x|)/2 for all samples: "
      f"{all(abs(relu(x) - (x + abs(x))/2) < 1e-15 for x in test_values)}")


#!/usr/bin/env python3
"""
visualize_regions.py — Visualization of how ReLU network linear region
counts grow with depth, width, and input dimension.
"""

import math
import matplotlib.pyplot as plt
import numpy as np


def choose(n: int, k: int) -> int:
    if k < 0 or k > n:
        return 0
    return math.comb(n, k)


def max_regions(n: int, d: int) -> int:
    return sum(choose(n, k) for k in range(d + 1))


def deep_region_bound(d: int, w: int, L: int) -> int:
    return max_regions(w, d) * (2 ** w) ** max(0, L - 1)


fig, axes = plt.subplots(1, 3, figsize=(15, 5))

# Plot 1: Regions vs number of hyperplanes for different dimensions
ax1 = axes[0]
for d in [1, 2, 3, 5]:
    ns = list(range(0, 21))
    regions = [max_regions(n, d) for n in ns]
    ax1.plot(ns, regions, 'o-', label=f'd={d}', markersize=3)
ax1.set_xlabel('Number of hyperplanes')
ax1.set_ylabel('Maximum regions')
ax1.set_title('Zaslavsky Bound: Regions vs Hyperplanes')
ax1.legend()
ax1.set_yscale('log')
ax1.grid(True, alpha=0.3)

# Plot 2: Deep network bounds vs depth
ax2 = axes[1]
d = 2
for w in [3, 5, 8]:
    layers = list(range(1, 8))
    bounds = [deep_region_bound(d, w, L) for L in layers]
    ax2.plot(layers, bounds, 's-', label=f'w={w}', markersize=5)
ax2.set_xlabel('Number of hidden layers')
ax2.set_ylabel('Max linear regions')
ax2.set_title(f'Deep Network Bound (d={d})')
ax2.legend()
ax2.set_yscale('log')
ax2.grid(True, alpha=0.3)

# Plot 3: Hodge rank table heatmap
ax3 = axes[2]
widths = [5, 10, 1]
max_pq = 5
hodge_table = np.zeros((max_pq + 1, max_pq + 1))
for p in range(max_pq + 1):
    for q in range(max_pq + 1):
        w1 = widths[0]
        wL = widths[-1]
        hodge_table[p, q] = choose(w1, p) * choose(wL, q)

im = ax3.imshow(hodge_table, cmap='YlOrRd', aspect='equal',
                origin='lower')
ax3.set_xlabel('q')
ax3.set_ylabel('p')
ax3.set_title(f'Hodge Rank h^{{p,q}} for {widths}')
for p in range(max_pq + 1):
    for q in range(max_pq + 1):
        val = int(hodge_table[p, q])
        if val > 0:
            ax3.text(q, p, str(val), ha='center', va='center',
                     fontsize=8, color='black' if val < 5 else 'white')
plt.colorbar(im, ax=ax3, shrink=0.8)

plt.tight_layout()
plt.savefig('neural_hodge_regions.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved: neural_hodge_regions.png")
